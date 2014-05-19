
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

        _venueId = [venue objectForKey:@"id"];
        _venueName = [venue objectForKey:@"name"];
        _venueRating = [venue objectForKey:@"rating"];
        if ( ! _venueRating )
            return nil;
        
        NSDictionary* hereNow = [venue objectForKey:@"hereNow"];
        if ( hereNow )
            _hereNowCount = [hereNow objectForKey:@"count"];
        
        NSArray* categories = [venue objectForKey:@"categories"];
        if ( categories && categories.count > 0 )
        {
            for ( NSDictionary* primary in categories )
            {
                if ( ! [primary objectForKey:@"primary"] )
                    break;
                NSDictionary* icon = [primary objectForKey:@"icon"];
                if ( icon )
                {
                    NSString* prefix = [icon objectForKey:@"prefix"];
                    NSString* suffix = [icon objectForKey:@"suffix"];
                }
                _venueType = [primary objectForKey:@"name"]; // shortName works too
                
                for ( NSString* key in icon.allKeys )
                {
                    id temp3 = [icon objectForKey:key];
                    temp3 = nil;
                }
            }
        }
        
        NSDictionary* price = [venue objectForKey:@"price"];
        if ( price )
        {
            _priceTier = [price objectForKey:@"tier"];
            _priceDescription = [price objectForKey:@"message"];
        }
        
        NSDictionary* photos = [venue objectForKey:@"photos"];
        if ( photos )
        {
            NSArray* groups = [photos objectForKey:@"groups"];
            NSDictionary* gr = groups[0];
            NSArray* photo = [gr objectForKey:@"items"];
            NSDictionary* p = photo[0];
            for ( NSString* key in p.allKeys )
            {
                id temp3 = [p objectForKey:key];
                temp3 = nil;
                // prefix, suffix, width, height
            }
        }
        
        // Hours to be requested by https://api.foursquare.com/v2/venues/VENUE_ID/hours
        // https://developer.foursquare.com/docs/venues/hours
        
        NSDictionary* location = [venue objectForKey:@"location"];
        if ( location )
        {
            _venueAddress = [location objectForKey:@"address"];
            _venueAddressTip = [location objectForKey:@"crossStreet"];
            _venueCity = [location objectForKey:@"city"];
            NSNumber* lat = [location objectForKey:@"lat"];
            NSNumber* lon = [location objectForKey:@"lng"];
            _venueLocation = [PFGeoPoint geoPointWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
        }
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
