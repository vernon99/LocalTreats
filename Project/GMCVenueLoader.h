//
//  GMCVenueLoader.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <Foundation/Foundation.h>

@interface GMCVenueLoader : NSObject

+(void) loadVenueListByType:(GMCQueryType)type withTarget:(id)target andSelector:(SEL)callback;

@end
