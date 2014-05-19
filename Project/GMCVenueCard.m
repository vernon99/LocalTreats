//
//  GMCVenueCard.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import "GMCVenueCard.h"

@implementation GMCVenueCard

- (void) loadData:(GMCVenue*)venue
{
    _venueName.text = venue.venueName;
    _venueType.text = venue.venueType;
    _venueAddress.text = venue.venueAddress;
    _venueCity.text = venue.venueCity;
    _venueCrossroads.text = venue.venueAddressTip;
    _venueRating.text = [NSString stringWithFormat:@"%@", venue.venueRating];
    _venueHereNow.text = [NSString stringWithFormat:@"%@", venue.hereNowCount];
    _venuePrice.text = venue.priceDescription;
}

+ (GMCVenueCard*) cardWithVenue:(GMCVenue*)venue
{
    GMCVenueCard* result = [[[NSBundle mainBundle] loadNibNamed:@"GMCVenueCard" owner:self options:nil] objectAtIndex:0];
    [result loadData:venue];
    return result;
}

@end
