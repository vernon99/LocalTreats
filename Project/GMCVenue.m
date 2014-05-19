//
//  GMCVenue.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

#import "GMCVenue.h"

@implementation GMCVenue

-(id) init
{
    if (self = [super init]) {
        _isSaving = NO;
    }
    return self;
}


/*+(id) venueWithData:(PFObject*)data
{
    return [[GMCVenue alloc] initWithData:data];
}

-(id) initWithData:(PFObject*)data
{
    if (self = [super init]) {
        _data = data;
        _venueId = [data objectForKey:@"venueId"];
        _venueName = [data objectForKey:@"venueName"];
        _venueAddress = [data objectForKey:@"venueAddress"];
        _venueLocation = [data objectForKey:@"venueLocation"];
    }
    
    return self;
}*/

+(id) venueWithFSVenue:(NSDictionary*)venue
{
    return [[GMCVenue alloc] initWithFSVenue:venue];
}

-(id) initWithFSVenue:(NSDictionary*)venue
{
    if (self = [super init]) {

        
        
    }
    
    return self;
}

-(BOOL) save:(id)target selector:(SEL)selector
{
    // TODO
    return FALSE;
}

-(BOOL) isSaved
{
    return (_data && _data.updatedAt != nil);
}

-(NSDate*) dateCreated
{
    if ( ! _data )
        return nil;
    return _data.createdAt;
}


@end
