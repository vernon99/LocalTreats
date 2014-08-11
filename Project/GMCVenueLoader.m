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
#import "GMCLocationManager.h"

@implementation GMCVenueLoader

static GMCVenueLoader *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (GMCVenueLoader *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

static NSInteger treatsCounter = 0;
static id oldTarget;
static SEL oldCallback;
static NSMutableArray* treatsResult = nil;

-(void) nextStepForTreats:(NSDictionary*)result
{
    if ( ! treatsResult )
        treatsResult = [NSMutableArray array];
    NSArray* venues = [result objectForKey:[NSNumber numberWithInt:GMC_QUERY_TREATS]];
    
    // Removing bad venues
    NSArray* categoriesTreatsOnly = [NSArray arrayWithObjects:GMCTreatsOnlyCategories count:GMCTreatsOnlyCategoriesCount];
    NSMutableArray* venuesToFix = [NSMutableArray arrayWithArray:venues];
    BOOL found;
    do {
        found = NO;
        for ( GMCVenue* venue1 in treatsResult )
        {
            for ( GMCVenue* venue2 in venuesToFix )
            {
                if ( [venue1.venueId isEqualToString:venue2.venueId] || ! [categoriesTreatsOnly containsObject:venue2.venueType] )
                {
                    found = YES;
                    [venuesToFix removeObject:venue2];
                    break;
                }
            }
            if ( found )
                break;
        }
    } while (found);
    
    [treatsResult addObjectsFromArray:venuesToFix];
    if ( treatsCounter < GMCTreatsOnlyCategoriesCount - 1 )
    {
        treatsCounter++;
        [self loadVenueListByType:GMC_QUERY_TREATS withTarget:oldTarget andSelector:oldCallback];
    }
    else
    {
        [oldTarget performSelector:oldCallback withObject:[NSDictionary dictionaryWithObject:treatsResult forKey:[NSNumber numberWithInt:GMC_QUERY_TREATS]]];
        treatsResult = nil;
        treatsCounter = 0;
    }
}

-(void) loadVenueListByType:(GMCQueryType)type withTarget:(id)target andSelector:(SEL)callback
{
    CLLocation* location = locManager.getPosition;
    if ( ! location )
    {
        NSLog(@"Error: no location provided for venue loader!");
        [target performSelector:callback withObject:nil];
        return;
    }
    
    NSNumber* latitude = @(location.coordinate.latitude);
    NSNumber* longitude = @(location.coordinate.longitude);
    NSString* section;
    NSString* query = nil;
    switch (type)
    {
        case GMC_QUERY_NONE: case GMC_QUERIES_COUNT: NSLog(@"Wrong query type!"); return;
        case GMC_QUERY_COFFEE: section = @"coffee"; break;
        case GMC_QUERY_LUNCH: section = @"food"; break;
        case GMC_QUERY_DRINKS: section = @"drinks"; break;
        case GMC_QUERY_TREATS: section = nil;
            query = GMCTreatsOnlyCategories[treatsCounter];
            oldTarget = target;
            oldCallback = callback;
            target = self;
            callback = @selector(nextStepForTreats:);
            break;
    }
    // One of food, drinks, coffee, shops, arts, outdoors, sights, trending or specials, nextVenues (venues frequently visited after a given venue), or topPicks
    
    [Foursquare2 setupFoursquareWithClientId:@"0BMX0XFXUCYZSWBODLKE3I0MVJENME2TKMIEMXQSPKMC4CHS" secret:@"5IQYLZVYI51JR2URBUMFR1QCLTZDX4WJAESTTY1YIYIRSEBE" callbackURL:@""];
    
    [Foursquare2 venueExploreRecommendedNearByLatitude:latitude
                                             longitude:longitude
                                                  near:nil
                                            accuracyLL:nil
                                              altitude:nil
                                           accuracyAlt:nil
                                                 query:query
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
                            if ( venue )
                            {
                                venue.venueCategory = type;
                                if ( /*( ([venue.venueRating floatValue] > 7.5 && type == GMC_QUERY_TREATS ) ||*/
                                        ( [venue.venueRating floatValue] > 9.0 ) /*) &&
                                        ( [venue.venueDistance floatValue] < 5.0 )*/ )
                                    [resultArray addObject:venue];
                            }
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

- (void) getVenuePhotos:(NSString*)venue withTarget:(id)target andSelector:(SEL)callback
{
    [Foursquare2 venueGetPhotos:venue limit:nil offset:nil callback:^(BOOL success, id result) {
        if ( success )
        {
            NSDictionary* photos = result[@"response"][@"photos"];
            NSNumber* count = [photos objectForKey:@"count"];
            NSArray* items = [photos objectForKey:@"items"];
            
            NSMutableArray* result = [NSMutableArray arrayWithCapacity:[count integerValue]];
            for ( NSDictionary* item in items )
            {
                NSString* prefix = [item objectForKey:@"prefix"];
                NSString* suffix = [item objectForKey:@"suffix"];
                if ( prefix && suffix )
                {
                    NSString* photoURL = [NSString stringWithFormat:@"%@500x500%@", prefix, suffix];
                    [result addObject:photoURL];
                }
            }
            [target performSelector:callback withObject:result];
        }
        else
            [target performSelector:callback withObject:nil];
    }];
}

@end
