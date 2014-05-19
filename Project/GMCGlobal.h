//
//  GMCGlobal.h
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "TestFlight.h"

#undef NSLog
#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define globalVariables [LFDGlobal sharedInstance]

#define currentUserData [PFUser currentUser]
#define isCurrentUserAdmin [globalVariables isUserAdmin]

// App store path
#define APP_STORE_PATH              @"http://itunes.apple.com/app/id662139655"
#define APP_TESTFLIGHT_TOKEN        @"a1488a9d-5019-4883-8487-26df42ea5f2c"

@interface LFDGlobal : NSObject
{
    Boolean bNewUser;
    NSDictionary*       globalSettings;         // Global settings (from settings object)
    Boolean             bLoaded;    // True if initial loading passed
}

+ (id)sharedInstance;

- (void)setGlobalSettings:(NSDictionary*)settings;
- (id)getGlobalParam:(NSString*)key;
- (NSUInteger)globalParam:(NSString*)key default:(NSUInteger)defaultResult;

- (Boolean)isNewUser;
- (void)setNewUser;

- (NSNumber*)currentVersion;
- (PFGeoPoint*) currentLocation;

- (void)setLoaded;
- (void)setUnloaded;
- (Boolean)isLoaded;

@end
