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
    NSString*   _venueAddress;
    PFGeoPoint* _venueLocation;
}

@property (readonly) PFObject* data;
@property (readonly) BOOL isSaving;

@property (readonly) NSString*      venueId;
@property (readonly) NSString*      venueName;
@property (readonly) NSString*      venueAddress;
@property (readonly) PFGeoPoint*    venueLocation;

//+(id) venueWithData:(PFObject*)data;
+(id) venueWithFSVenue:(NSDictionary*)venue;

-(BOOL) save:(id)target selector:(SEL)selector;
-(BOOL) isSaved;
-(NSDate*) dateCreated;

@end
