//
//  GMCVenueCard.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <UIKit/UIKit.h>
#import "GMCVenue.h"
#import <MapKit/MapKit.h>
#import "AsyncImageView.h"

@interface GMCVenueCard : UIView
{
    GMCVenue* _venue;
    IBOutlet UIView *_cardView;
    
    IBOutlet UILabel *_venueName;
    IBOutlet UILabel *_venueType;
    IBOutlet UILabel *_venueAddress;
    IBOutlet UILabel *_venueCrossroads;
    IBOutlet UILabel *_venueRating;
    IBOutlet UIImageView *_venueRatingBg;
    IBOutlet UILabel *_venueHereNow;
    IBOutlet UILabel *_venuePrice;
    IBOutlet MKMapView *_venueMap;
    IBOutlet AsyncImageView *_venuePhoto;
    IBOutlet AsyncImageView *_venueIcon;
    IBOutlet UIActivityIndicatorView *_venuePhotoIndicator;
    IBOutlet UILabel *_venueDistance;
    
    IBOutlet UIButton *_mapButton;
    IBOutlet UIButton *_photosButton;
    
    UISwipeGestureRecognizer *_swipeGestureLeft;
    UISwipeGestureRecognizer *_swipeGestureRight;
    UISwipeGestureRecognizer *_swipeGestureDown;
    CGRect _oldPhotoRect;
    IBOutlet UILabel *_photoNumberLabel;
}

+ (GMCVenueCard*) cardWithVenue:(GMCVenue*)venue;
- (IBAction)openMaps:(id)sender;
- (IBAction)openPhotos:(id)sender;

@end
