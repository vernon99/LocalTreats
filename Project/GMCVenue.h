//
//  GMCVenue.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

#import <Foundation/Foundation.h>

@interface GMCVenue : NSObject
{
    // Main object
    PFObject*   _data;
    BOOL        _isSaving;
    
    // Specific fields
    NSString*   _venueId;
    NSString*   _venueName;
    NSString*   _venueType;
    NSString*   _venueAddress;
    NSString*   _venueAddressTip;
    NSString*   _venueCity;
    PFGeoPoint* _venueLocation;
    NSNumber*   _venueRating;
    NSNumber*   _hereNowCount;
    NSNumber*   _priceTier;
    NSString*   _priceDescription;
    NSString*   _venuePhotoURL;
    NSString*   _venueIconURL;
    NSNumber*   _venueDistance;
}

@property (readonly) PFObject* data;
@property (readonly) BOOL isSaving;

@property (readonly) NSString*      venueId;
@property (readonly) NSString*      venueName;
@property (readonly) NSString*      venueType;
@property (readonly) NSString*      venueAddress;
@property (readonly) NSString*      venueAddressTip;
@property (readonly) NSString*      venueCity;
@property (readonly) PFGeoPoint*    venueLocation;
@property (readonly) NSNumber*      venueRating;
@property (readonly) NSNumber*      hereNowCount;
@property (readonly) NSNumber*      priceTier;
@property (readonly) NSString*      priceDescription;
@property (readonly) NSString*      venuePhotoURL;
@property (readonly) NSString*      venueIconURL;
@property (readonly) NSNumber*      venueDistance;

//+(id) venueWithData:(PFObject*)data;
+(id) venueWithFSVenue:(NSDictionary*)venue;

-(BOOL) save:(id)target selector:(SEL)selector;
-(BOOL) isSaved;
-(NSDate*) dateCreated;

@end
