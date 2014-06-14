//
//  GMCVenueLoader.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <Foundation/Foundation.h>

#define venueLoader [GMCVenueLoader sharedInstance]

@interface GMCVenueLoader : NSObject

+ (GMCVenueLoader*) sharedInstance;

- (void) loadVenueListByType:(GMCQueryType)type withTarget:(id)target andSelector:(SEL)callback;

- (void) getVenuePhotos:(NSString*)venue withTarget:(id)target andSelector:(SEL)callback;

@end
