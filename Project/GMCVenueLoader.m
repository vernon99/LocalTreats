//
//  GMCVenueLoader.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import "GMCVenueLoader.h"
#import "Foursquare2.h"
#import "GMCVenue.h"
#import "ULLocationManager.h"

@implementation GMCVenueLoader

+(void) loadVenueListByType:(GMCQueryType)type withTarget:(id)target andSelector:(SEL)callback
{
    PFGeoPoint* location = locManager.getPosition;
    NSNumber* latitude = @(location.latitude);
    NSNumber* longitude = @(location.longitude);
    NSString* section;
    switch (type)
    {
        case GMC_QUERY_NONE: case GMC_QUERIES_COUNT: NSLog(@"Wrong query type!"); return;
        case GMC_QUERY_COFFEE: section = @"coffee"; break;
        case GMC_QUERY_LUNCH: section = @"food"; break;
        case GMC_QUERY_DRINKS: section = @"drinks"; break;
    }
    // One of food, drinks, coffee, shops, arts, outdoors, sights, trending or specials, nextVenues (venues frequently visited after a given venue), or topPicks
    
    [Foursquare2 setupFoursquareWithClientId:@"0BMX0XFXUCYZSWBODLKE3I0MVJENME2TKMIEMXQSPKMC4CHS" secret:@"5IQYLZVYI51JR2URBUMFR1QCLTZDX4WJAESTTY1YIYIRSEBE" callbackURL:@""];
    
    [Foursquare2 venueExploreRecommendedNearByLatitude:latitude
                                             longitude:longitude
                                                  near:nil
                                            accuracyLL:nil
                                              altitude:nil
                                           accuracyAlt:nil
                                                 query:nil
                                                 limit:@(50)
                                                offset:nil
                                                radius:nil
                                               section:section
                                               novelty:nil
                                        sortByDistance:NO
                                               openNow:YES
                                           venuePhotos:YES
                                                 price:nil
                                              callback:^(BOOL success, id result) {
                                                
        BOOL callbackCalled = FALSE;
        if (success && result)
        {
            NSArray* groups = result[@"response"][@"groups"];
            if ( groups )
            {
                NSDictionary* main = groups[0];
                if ( main )
                {
                    NSArray* items = main[@"items"];
                    if ( items )
                    {
                        NSMutableArray* resultArray = [NSMutableArray array];
                        for ( NSDictionary* v in items )
                        {
                            GMCVenue* venue = [GMCVenue venueWithFSVenue:[v objectForKey:@"venue"]];
                            venue.venueCategory = type;
                            if ( venue )
                                [resultArray addObject:venue];
                        }
                        
                        NSDictionary* resultDictionary = [NSDictionary dictionaryWithObject:resultArray forKey:[NSNumber numberWithInt:type]];
                        [target performSelector:callback withObject:resultDictionary];
                        callbackCalled = TRUE;
                    }
                }
            }
        }
        else
            NSLog(@"Foursquare error: %@", result);
        
        if ( ! callbackCalled )
            [target performSelector:callback withObject:nil];
    }];
}

@end
