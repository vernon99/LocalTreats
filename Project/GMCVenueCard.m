//
//  GMCVenueCard.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import "GMCVenueCard.h"
#import "ULLocationManager.h"

@implementation GMCVenueCard

- (void) loadData:(GMCVenue*)venue
{
    _venueName.text = venue.venueName;
    _venueType.text = venue.venueType;
    _venueAddress.text = [NSString stringWithFormat:@"Address: %@", venue.venueAddress];
    _venueCity.text = venue.venueCity;
    _venueCrossroads.text = venue.venueAddressTip;
    if ( [venue.venueRating floatValue] < 9.3 )
        _venueRatingBg.image = [UIImage imageNamed:@"ratingBad"];
    else if ( [venue.venueRating floatValue] < 9.6 )
        _venueRatingBg.image = [UIImage imageNamed:@"ratingMid"];
    else
        _venueRatingBg.image = [UIImage imageNamed:@"ratingGood"];
    _venueRating.text = [NSString stringWithFormat:@"%.1f", [venue.venueRating floatValue]];
    _venueHereNow.text = [NSString stringWithFormat:@"%@ visitors", venue.hereNowCount];
    _venuePrice.text = [NSString stringWithFormat:@"%@ prices", venue.priceDescription];
    _venueDistance.text = [NSString stringWithFormat:@"%.2fkm away", [venue.venueDistance floatValue]];
    
    // Misc
    _venueMap.showsUserLocation = TRUE;
    [_venueMap setUserInteractionEnabled:NO];
    
    // Set map region
    double userLat = locManager.getPosition.latitude;
    double userLon = locManager.getPosition.longitude;
    double venueLat = venue.venueLocation.latitude;
    double venueLon = venue.venueLocation.longitude;
    MKCoordinateSpan locationSpan;
    locationSpan.latitudeDelta = fabs(venueLat - userLat);
    locationSpan.longitudeDelta = fabs(venueLon - userLon);
    CLLocationCoordinate2D locationCenter;
    locationCenter.latitude = (venueLat + userLat) / 2;
    locationCenter.longitude = (venueLon + userLon) / 2;
    MKCoordinateRegion region = MKCoordinateRegionMake(locationCenter, locationSpan);
    region.span.latitudeDelta = region.span.longitudeDelta = fmax(region.span.latitudeDelta, region.span.longitudeDelta) * 1.5;
    //if ( region.span.longitudeDelta < 0.05f || region.span.latitudeDelta < 0.05f )
    //{
    //    region.span.longitudeDelta = 0.05f;
    //    region.span.latitudeDelta = 0.05f;
    //}
    [_venueMap setRegion:region animated:YES];
    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(venue.venueLocation.latitude, venue.venueLocation.longitude);
    [_venueMap addAnnotation:annotation];
    
    // Images
    [_venueIcon loadImageFromURL:venue.venueIconURL];
    [_venuePhotoIndicator startAnimating];
    [_venuePhoto loadImageFromURL:venue.venuePhotoURL withTarger:self selector:@selector(photoLoaded)];
}

- (void) photoLoaded
{
    [_venuePhotoIndicator stopAnimating];
}

+ (GMCVenueCard*) cardWithVenue:(GMCVenue*)venue
{
    GMCVenueCard* result = [[[NSBundle mainBundle] loadNibNamed:@"GMCVenueCard" owner:self options:nil] objectAtIndex:0];
    [result loadData:venue];
    return result;
}

@end
