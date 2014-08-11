//
//  GMCVenue.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GMCVenue : NSObject
{
    // Main object
    GMCQueryType    _venueCategory;
    
    // Specific fields
    NSString*   _venueId;
    NSString*   _venueName;
    NSString*   _venueType;
    NSString*   _venueAddress;
    NSString*   _venueAddressTip;
    NSString*   _venueCity;
    CLLocation* _venueLocation;
    NSNumber*   _venueRating;
    NSNumber*   _hereNowCount;
    NSNumber*   _priceTier;
    NSString*   _priceDescription;
    NSString*   _venuePhotoURL;
    NSString*   _venueIconURL;
    NSNumber*   _venueDistance;
    
    NSArray*    _photoUrls;
    NSInteger   _currentPhotoNumber;
}

@property (readonly) BOOL isSaving;

@property (readwrite) GMCQueryType  venueCategory;

@property (readonly) NSString*      venueId;
@property (readonly) NSString*      venueName;
@property (readonly) NSString*      venueType;
@property (readonly) NSString*      venueAddress;
@property (readonly) NSString*      venueAddressTip;
@property (readonly) NSString*      venueCity;
@property (readonly) CLLocation*    venueLocation;
@property (readonly) NSNumber*      venueRating;
@property (readonly) NSNumber*      hereNowCount;
@property (readonly) NSNumber*      priceTier;
@property (readonly) NSString*      priceDescription;
@property (readonly) NSString*      venuePhotoURL;
@property (readonly) NSString*      venueIconURL;
@property (readonly) NSNumber*      venueDistance;

@property (readwrite) NSArray*      photoUrls;
@property (readwrite) NSInteger     currentPhotoNumber;

+(id) venueWithFSVenue:(NSDictionary*)venue;

@end
