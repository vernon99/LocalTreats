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
    _venue = venue;
    
    switch (venue.venueCategory)
    {
        case GMC_QUERY_COFFEE: self.backgroundColor = [UIColor colorWithHexString:@"fd8f2d"]; break;
        case GMC_QUERY_LUNCH: self.backgroundColor = [UIColor colorWithHexString:@"fa5c5c"]; break;
        case GMC_QUERY_DRINKS: self.backgroundColor = [UIColor colorWithHexString:@"3393ff"]; break;
        default: self.backgroundColor = [UIColor colorWithHexString:@"000000"];
    }
    
    _venueName.text = venue.venueName;
    _venueType.text = venue.venueType;
    _venueAddress.text = [NSString stringWithFormat:@"Address: %@", venue.venueAddress];
    //_venueCity.text = venue.venueCity;
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

- (IBAction)openMaps:(id)sender {
    
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Directions" message:@"Open directions to this location in Maps?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [message show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 )
        return;
    
    // Open map on click
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate =
        CLLocationCoordinate2DMake(_venue.venueLocation.latitude, _venue.venueLocation.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:_venue.venueName];
        
        // Set the directions mode to "Walking"
        // Can use MKLaunchOptionsDirectionsModeDriving instead
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

@end
