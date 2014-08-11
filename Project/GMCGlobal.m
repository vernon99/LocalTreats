//
//  GMCGlobal.m
//  GimmeCoffee
//
//  Created by Mikhail Larionov on 3/01/14.
//
//

#import "GMCGlobal.h"
#import <Parse/Parse.h>
#import "GMCLocationManager.h"

@implementation LFDGlobal

static LFDGlobal *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (LFDGlobal *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        bNewUser = FALSE;
        globalSettings = nil;
        bLoaded = false;
    }
    
    return self;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (Boolean)isNewUser
{
    return sharedInstance->bNewUser;
}

- (void)setNewUser
{
    sharedInstance->bNewUser = TRUE;
}

- (NSNumber*)currentVersion
{
    NSString* strData = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSNumber numberWithFloat:[strData floatValue]];
}

- (PFGeoPoint*) currentLocation
{
    // Get current position
    PFGeoPoint* ptUser = [locManager getPosition];
    
    // Get last saved position
    if ( ! ptUser && currentUserData )
        ptUser = [currentUserData objectForKey:@"location"];
    
    // Get default position
    if ( ! ptUser )
        ptUser = [locManager getDefaultPosition];
    
    return ptUser;
}

- (void)setGlobalSettings:(NSDictionary*)settings
{
    globalSettings = settings;
}

- (id)getGlobalParam:(NSString*)key
{
    // We have the key stored in global data
    if ( globalSettings )
        if ( [globalSettings objectForKey:key] )
            return [globalSettings objectForKey:key];
    
    // Show error
    NSString* strError = [NSString stringWithFormat:@"The following key is missing in settings object! Key: %@", key];
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error, bad settings key" message:strError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    
    return nil;
}

- (NSUInteger)globalParam:(NSString*)key default:(NSUInteger)defaultResult
{
    NSNumber* num = [globalVariables getGlobalParam:key];
    if ( ! num )
        return defaultResult;
    return [num integerValue];
}

- (void)setLoaded
{
    bLoaded = true;
}

- (void)setUnloaded
{
    bLoaded = false;
}

- (Boolean)isLoaded
{
    return bLoaded;
}

@end