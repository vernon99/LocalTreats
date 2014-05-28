//
//  GMCMainViewController.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import "GMCMainViewController.h"
#import "GMCVenueLoader.h"
#import "GMCVenueCard.h"
#import "ULLocationManager.h"

static CGPoint venueCardPosition = {10, 30};

@implementation GMCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _locationUpdated = FALSE;
        _currentQuery = GMC_QUERY_NONE;
        _nowLoading = GMC_QUERY_COFFEE;
        _venueArrays = [NSMutableDictionary dictionaryWithCapacity:GMC_QUERIES_COUNT];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:kLocationUpdated object:nil];
    [locManager startUpdating];
    _statusLabel.text = @"Updating location...";
    _statusLabel.alpha = 0.0;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedCard:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeGesture];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedCard:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:swipeGesture];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp);
    [self.view addGestureRecognizer:swipeGesture];
}

- (void) updateAdviceText
{
    NSArray* venueArray = [self venueArrayByType:_currentQuery];
    if ( ! venueArray )
        _adviceLabel.text = @"";
    if ( venueArray.count == 1 )
        _adviceLabel.text = @"We found only one venue\nSwipe down to go back";
    if ( venueArray.count > 1 )
        _adviceLabel.text = [NSString stringWithFormat:@"Showing %d of %d venues\nSwipe sideways to scroll\nSwipe down to go back", (int)_currentCardNumber+1, (int)venueArray.count];
}

- (void)swipedCard:(UIGestureRecognizer*)gestureRecognizer
{
    NSArray* venueArray = [self venueArrayByType:_currentQuery];
    if ( ! venueArray )
        return;
    
    BOOL left;
    if ( ( (UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight && _currentCardNumber > 0 )
    {
        _currentCardNumber--;
        left = FALSE;
    }
    else if ( ( (UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft && _currentCardNumber < venueArray.count - 1 )
    {
        _currentCardNumber++;
        left = TRUE;
    }
    else return;
    
    GMCVenueCard* oldCard = _currentCard;
    _currentCard = [GMCVenueCard cardWithVenue:venueArray[_currentCardNumber]];
    [self.view addSubview:_currentCard];
    _currentCard.origin = venueCardPosition;
    if ( left )
        _currentCard.originX = self.view.width;
    else
        _currentCard.originX = - _currentCard.width;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ( left )
            oldCard.originX = - _currentCard.width;
        else
            oldCard.originX = self.view.width;
        _currentCard.origin = venueCardPosition;
        [self updateAdviceText];

    } completion:^(BOOL finished) {
        
        [oldCard removeFromSuperview];
    }];
}

- (void)hideSelection
{
    _buttonsView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        _buttonsView.alpha = 0.0;
        _adviceLabel.alpha = 1.0;
        _statusLabel.alpha = 1.0;
        
    } completion:nil];
}

- (void)swipedDown:(UIGestureRecognizer*)gestureRecognizer
{
    if ( _buttonsView.userInteractionEnabled )
        return;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ( _currentCard )
            _currentCard.alpha = 0.0;
        _adviceLabel.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        if ( _currentCard )
            [_currentCard removeFromSuperview];
        _currentCard = nil;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _buttonsView.alpha = 1.0;
        } completion:^(BOOL finished) {
            _buttonsView.userInteractionEnabled = YES;
        }];
    }];
}

- (void)locationUpdated
{
    if ( ! _locationUpdated || ! locManager.getPosition )
    {
        _locationUpdated = TRUE;
        [_activityIndicator stopAnimating];
        if ( ! locManager.getPosition )
        {
            _buttonsView.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _buttonsView.alpha = 0.0;
                _statusLabel.alpha = 1.0;
                _statusLabel.text = @"How can we find you the best coffee nearby if you have just disabled location services for this app? Hint: go to Settings -> Privacy -> Location Services to enable.";
            } completion:^(BOOL finished) {
                _buttonsView.userInteractionEnabled = YES;
            }];
        }
        else
        {
            [GMCVenueLoader loadVenueListByType:_nowLoading withTarget:self andSelector:@selector(venuesLoaded:)];
        }
    }
}

- (void)venuesLoaded:(NSDictionary*)venuesDictionary
{
    GMCQueryType venueType = GMC_QUERY_NONE;
    NSArray* venueArray = nil;
    NSNumber* venueKey = nil;
    if ( venuesDictionary && venuesDictionary.count > 0 )
    {
        venueKey = [venuesDictionary allKeys][0];
        venueType = (GMCQueryType)[venueKey integerValue];
        venueArray = [venuesDictionary objectForKey:venueKey];
    }
    
    // Update venues arrays
    if ( venueArray )
    {
        NSArray* sortedArray = [venueArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            GMCVenue *first = (GMCVenue*)a;
            GMCVenue *second = (GMCVenue*)b;
            if ([first.venueDistance floatValue] < [second.venueDistance floatValue])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }];
        [_venueArrays setObject:sortedArray forKey:venueKey];
        
        //UIImageView* image = (UIImageView*)[self.view viewWithTag:venueType+20];
        //image.hidden = FALSE;
    }
    
    // Try to find next unloaded and load it
    BOOL found = FALSE;
    for ( GMCQueryType type = 0; type < GMC_QUERIES_COUNT; type++ )
        if ( ! [self venueArrayByType:type] && _nowLoading != type )
        {
            _nowLoading = type;
            [GMCVenueLoader loadVenueListByType:_nowLoading withTarget:self andSelector:@selector(venuesLoaded:)];
            found = TRUE;
            break;
        }
    if ( ! found )
        _nowLoading = GMC_QUERY_NONE;
    
    // If mode is already selected, update card
    if ( _currentQuery == venueType )
    {
        [_activityIndicator stopAnimating];
        if ( ! _currentCard )
            [self showFirstCard];
    }
}

- (void) showFirstCard
{
    // Clear old stuff
    GMCVenueCard* oldCard = _currentCard;
    if ( oldCard )
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            oldCard.alpha = 0.0;
        } completion:^(BOOL finished) {
            [oldCard removeFromSuperview];
        }];
    }
    _adviceLabel.text = @"";
    _statusLabel.text = @"";
    
    // Get venue array
    NSArray* venueArray = [self venueArrayByType:_currentQuery];
    
    // Load best venue
    if ( venueArray )
    {
        if ( venueArray.count > 0 )
        {
            // Load card
            _currentCard = [GMCVenueCard cardWithVenue:venueArray[0]];
            _currentCard.origin = venueCardPosition;
            _currentCard.alpha = 0.0;
            _adviceLabel.alpha = 0.0;
            [self.view addSubview:_currentCard];
            [self updateAdviceText];
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _currentCard.alpha = 1.0;
                _adviceLabel.alpha = 1.0;
            } completion:nil];
        }
        else
        {
            _statusLabel.text = @"There's nothing worth your attention in the nearest radius of 5km. And yes, we won't show you nearest McDonalds or Starbucks, sorry.";
        }
    }
    else
    {
        _statusLabel.text = @"We were unable to fetch locations. Possible reasons include no connection, Foursquare servers failuer or just some karmic turbulations.";
    }
}

- (NSArray*)venueArrayByType:(GMCQueryType)type
{
    return [_venueArrays objectForKey:[NSNumber numberWithInt:type]];
}

- (IBAction)buttonTap:(id)sender {
    
    UIButton* tappedButton = sender;
    
    // Set current query
    _currentQuery = (GMCQueryType)(tappedButton.tag - 10);
    
    // Hide menu
    [self hideSelection];
    
    // Location is still loading
    if ( ! _locationUpdated || ! locManager.getPosition )
    {
        [_activityIndicator startAnimating];
        _nowLoading = _currentQuery;
    }
    else
        [self updateQueryResult];
}

- (void) updateQueryResult
{
    _currentCardNumber = 0;
    if ( ! [self venueArrayByType:_currentQuery] )
    {
        [_activityIndicator startAnimating];
        _statusLabel.text = @"Loading venues...";
        _adviceLabel.text = @"";
        if ( _nowLoading != _currentQuery )
        {
            _nowLoading = _currentQuery;
            [GMCVenueLoader loadVenueListByType:_nowLoading withTarget:self andSelector:@selector(venuesLoaded:)];
        }
    }
    else
    {
        _statusLabel.text = @"";
        [self showFirstCard];
    }
}

@end
