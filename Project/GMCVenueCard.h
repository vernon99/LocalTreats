//
//  GMCVenueCard.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <UIKit/UIKit.h>
#import "GMCVenue.h"

@interface GMCVenueCard : UIView
{
    IBOutlet UILabel *_venueName;
    IBOutlet UILabel *_venueType;
    IBOutlet UILabel *_venueAddress;
    IBOutlet UILabel *_venueCity;
    IBOutlet UILabel *_venueCrossroads;
    IBOutlet UILabel *_venueRating;
    IBOutlet UILabel *_venueHereNow;
    IBOutlet UILabel *_venuePrice;
}

+ (GMCVenueCard*) cardWithVenue:(GMCVenue*)venue;

@end
