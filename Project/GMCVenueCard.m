//
//  GMCVenueCard.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import "GMCVenueCard.h"
#import "GMCLocationManager.h"
#import "GMCVenueLoader.h"

@implementation GMCVenueCard

- (void) loadData:(GMCVenue*)venue
{
    _venue = venue;
    
    switch (venue.venueCategory)
    {
        case GMC_QUERY_COFFEE: _cardView.backgroundColor = [UIColor colorWithHexString:@"fd8f2d"]; break;
        case GMC_QUERY_LUNCH: _cardView.backgroundColor = [UIColor colorWithHexString:@"fa5c5c"]; break;
        case GMC_QUERY_DRINKS: _cardView.backgroundColor = [UIColor colorWithHexString:@"3393ff"]; break;
        case GMC_QUERY_TREATS: _cardView.backgroundColor = [UIColor colorWithHexString:@"18cc5c"]; break;
        default: _cardView.backgroundColor = [UIColor colorWithHexString:@"000000"];
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
    _venuePrice.text = [NSString stringWithFormat:@"%@", venue.priceDescription];
    _venueDistance.text = [NSString stringWithFormat:@"%.2fkm away", [venue.venueDistance floatValue]];
    
    // Misc
    _venueMap.showsUserLocation = TRUE;
    [_venueMap setUserInteractionEnabled:NO];
    
    // Set map region
    double userLat = locManager.getPosition.coordinate.latitude;
    double userLon = locManager.getPosition.coordinate.longitude;
    double venueLat = venue.venueLocation.coordinate.latitude;
    double venueLon = venue.venueLocation.coordinate.longitude;
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
    annotation.coordinate = venue.venueLocation.coordinate;
    [_venueMap addAnnotation:annotation];
    
    // Images
    [_venueIcon loadImageFromURL:venue.venueIconURL];
    [_venuePhotoIndicator startAnimating];
    if ( _venue.photoUrls )
        [_venuePhoto loadImageFromURL:_venue.photoUrls[_venue.currentPhotoNumber] withTarger:self selector:@selector(photoLoaded)];
    else
        [_venuePhoto loadImageFromURL:venue.venuePhotoURL withTarger:self selector:@selector(photoLoaded)];
}

- (void) photoLoaded
{
    [_venuePhotoIndicator stopAnimating];
    //[UIView animateWithDuration:0.15 animations:^{
    //    _venuePhoto.imageView.alpha = 1.0;
    //} completion:nil];
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

- (IBAction)openPhotos:(id)sender {
    
    _mapButton.enabled = NO;
    _photosButton.enabled = NO;
    _oldPhotoRect = _venuePhoto.frame;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _venuePhoto.backgroundColor = _cardView.backgroundColor;
        _venuePhoto.frame = CGRectMake( 0, 0, _cardView.width, _cardView.width );
        _venueMap.alpha = 0.0;
    } completion:nil];
    
    if ( _venue.photoUrls )
        [self photosLoaded:_venue.photoUrls];
    else
    {
        [_venuePhotoIndicator startAnimating];
        [venueLoader getVenuePhotos:_venue.venueId withTarget:self andSelector:@selector(photosLoaded:)];
        [self updatePhotoNumberText:NO];
    }
}

- (void) updatePhotoNumberText:(BOOL)hide
{
    if ( ! _venue.photoUrls )
    {
        _photoNumberLabel.text = @"";
        return;
    }
        
    if ( ! hide )
        _photoNumberLabel.hidden = FALSE;
    _photoNumberLabel.text = [NSString stringWithFormat:@"%d of %d", (int)_venue.currentPhotoNumber+1, (int)_venue.photoUrls.count];
    [UIView animateWithDuration:0.3 animations:^{
        _photoNumberLabel.alpha = hide ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        if ( hide )
            _photoNumberLabel.hidden = TRUE;
    }];
}

- (void) photosLoaded:(NSArray*)arrayPhotos
{
    [_venuePhotoIndicator stopAnimating];
    _venue.photoUrls = arrayPhotos;
    [self updatePhotoNumberText:NO];
    
    _swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal:)];
    _swipeGestureLeft.numberOfTouchesRequired = 1;
    _swipeGestureLeft.direction = (UISwipeGestureRecognizerDirectionLeft);
    [self addGestureRecognizer:_swipeGestureLeft];
    _swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedHorizontal:)];
    _swipeGestureRight.numberOfTouchesRequired = 1;
    _swipeGestureRight.direction = (UISwipeGestureRecognizerDirectionRight);
    [self addGestureRecognizer:_swipeGestureRight];
    _swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown:)];
    _swipeGestureDown.numberOfTouchesRequired = 1;
    _swipeGestureDown.direction = (UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp);
    [self addGestureRecognizer:_swipeGestureDown];
}

- (void)swipedHorizontal:(UIGestureRecognizer*)gestureRecognizer
{
    if ( ! _venue.photoUrls )
        return;
    
    if ( ((UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionLeft )
    {
        if ( _venue.currentPhotoNumber < _venue.photoUrls.count - 1 )
            _venue.currentPhotoNumber++;
        else
            return;
    }
    if ( ((UISwipeGestureRecognizer*)gestureRecognizer).direction == UISwipeGestureRecognizerDirectionRight )
    {
        if ( _venue.currentPhotoNumber > 0 )
            _venue.currentPhotoNumber--;
        else
            return;
    }
    
    //[UIView animateWithDuration:0.15 animations:^{
    //    _venuePhoto.imageView.alpha = 0.0;
    //} completion:^(BOOL finished) {
        [_venuePhotoIndicator startAnimating];
        [_venuePhoto loadImageFromURL:_venue.photoUrls[_venue.currentPhotoNumber] withTarger:self selector:@selector(photoLoaded)];
    //}];
    [self updatePhotoNumberText:NO];
}

- (void)swipedDown:(UIGestureRecognizer*)gestureRecognizer
{
    _mapButton.enabled = YES;
    _photosButton.enabled = YES;
    
    [self removeGestureRecognizer:_swipeGestureLeft];
    [self removeGestureRecognizer:_swipeGestureRight];
    [self removeGestureRecognizer:_swipeGestureDown];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _venuePhoto.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
        _venuePhoto.frame = _oldPhotoRect;
        _venueMap.alpha = 1.0;
    } completion:nil];
    [self updatePhotoNumberText:YES];
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
        CLLocationCoordinate2D coordinate = _venue.venueLocation.coordinate;
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
