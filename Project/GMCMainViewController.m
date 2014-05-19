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

@implementation GMCMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_activityIndicator startAnimating];
    [GMCVenueLoader loadVenueListWithTarget:self andSelector:@selector(venuesLoaded:)];
}

- (void)venuesLoaded:(NSArray*)venues
{
    [_activityIndicator stopAnimating];
    if ( venues && venues.count > 0 )
    {
        GMCVenue* bestVenue = nil;
        for ( GMCVenue* venue in venues )
            if ( ! bestVenue || [bestVenue.venueRating floatValue] < [venue.venueRating floatValue] )
                bestVenue = venue;
        GMCVenueCard* card = [GMCVenueCard cardWithVenue:bestVenue];
        card.origin = CGPointMake(10, 30);
        [self.view addSubview:card];
    }
    else
    {
        // TODO: show nothing nearby or try to reload for better
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
