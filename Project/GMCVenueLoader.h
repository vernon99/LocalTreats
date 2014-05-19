//
//  GMCVenueLoader.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 5/18/14.
//
//

#import <Foundation/Foundation.h>

@interface GMCVenueLoader : NSObject

+(void) loadVenueListWithTarget:(id)target andSelector:(SEL)callback;

@end
