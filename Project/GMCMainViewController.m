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

@implementation GMCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _locationUpdated = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_activityIndicator startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:kLocationUpdated object:nil];
    [locManager startUpdating];
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedCard:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self.view addGestureRecognizer:swipeGesture];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedCard:)];
    swipeGesture.numberOfTouchesRequired = 1;
    swipeGesture.direction = (UISwipeGestureRecognizerDirectionRight);
    [self.view addGestureRecognizer:swipeGesture];
}

- (void) updateAdviceText
{
    if ( ! _venueArray.count )
        _adviceLabel.text = @"";
    if ( _venueArray.count == 1 )
        _adviceLabel.text = @"Showing the single place we found";
    if ( _venueArray.count > 1 )
        _adviceLabel.text = [NSString stringWithFormat:@"Showing %d of the %d places we found", (int)_currentCardNumber+1, (int)_venueArray.count];
}

- (void)swipedCard:(UIGestureRecognizer*)gestureRecognizer
{
    if ( ! _venueArray )
        return;
    
    BOOL left;
    if ( ( (UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight && _currentCardNumber > 0 )
    {
        _currentCardNumber--;
        left = FALSE;
    }
    else if ( ( (UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft && _currentCardNumber < _venueArray.count - 1 )
    {
        _currentCardNumber++;
        left = TRUE;
    }
    else return;
    
    GMCVenueCard* oldCard = _currentCard;
    _currentCard = [GMCVenueCard cardWithVenue:_venueArray[_currentCardNumber]];
    [self.view addSubview:_currentCard];
    _currentCard.origin = CGPointMake(10, 30);
    if ( left )
        _currentCard.originX = self.view.width;
    else
        _currentCard.originX = - _currentCard.width;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if ( left )
            oldCard.originX = - _currentCard.width;
        else
            oldCard.originX = self.view.width;
        _currentCard.origin = CGPointMake(10, 30);
        [self updateAdviceText];

    } completion:^(BOOL finished) {
        
        [oldCard removeFromSuperview];
    }];
}

- (void)locationUpdated
{
    if ( ! _locationUpdated || ! locManager.getPosition )
    {
        _locationUpdated = TRUE;
        if ( ! locManager.getPosition )
        {
            [_activityIndicator stopAnimating];
            _statusLabel.text = @"How can we find you the best coffee nearby if you have just disabled location services for this app? Hint: go to Settings -> Privacy -> Location Services to enable.";
        }
        else
        {
            _statusLabel.text = @"";
            [GMCVenueLoader loadVenueListWithTarget:self andSelector:@selector(venuesLoaded:)];
        }
    }
}

- (void)venuesLoaded:(NSArray*)venues
{
    [_activityIndicator stopAnimating];
    
    _adviceLabel.text = @"";
    _statusLabel.text = @"";
    _currentCardNumber = 0;
    
    // Load best venue
    if ( venues && venues.count > 0 )
    {
        // Sort venues
        _venueArray = [venues sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            GMCVenue *first = (GMCVenue*)a;
            GMCVenue *second = (GMCVenue*)b;
            if ([first.venueDistance floatValue] < [second.venueDistance floatValue])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }];
        
        // Load card
        _currentCard = [GMCVenueCard cardWithVenue:_venueArray[_currentCardNumber]];
        _currentCard.origin = CGPointMake(10, 30);
        [self.view addSubview:_currentCard];
        
        [self updateAdviceText];
    }
    else
    {
        _statusLabel.text = @"There's nothing worth your attention in the nearest radius of 5km. And yes, we won't show you nearest Starbucks, sorry.";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
