
#import "GMCAppDelegate.h"
#import "GMCMainViewController.h"
#import "ULLocationManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation GMCAppDelegate

#pragma mark - UIApplicationDelegate

static NSDictionary* notificationData = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ( launchOptions )
        NSLog(@"Launch options: %@", launchOptions);
    
    bFirstActivation = true;
    
    [FBProfilePictureView class];
    
    // Testflight
    @try {
        [TestFlight takeOff:APP_TESTFLIGHT_TOKEN];
    }
    @catch (NSException *exception) {
        NSLog(@"TestFlight error: %@",exception);
    }
    
    // Parse and crashlytics
    [Parse setApplicationId:@"Xd2Y10TTxXQdcxPbLoGdssuxDJvT9OB0b0k0oXa9"
                  clientKey:@"1QWN3AlI0iZaCGJsHpx5BxrhYI437cbDr1eOzYX8"];
    [Crashlytics startWithAPIKey:@"05bf10b64dd5e5dbbe55dfb384d01abad7bba586"];
    
    // Navigation controller
    GMCMainViewController *mainViewController = [[GMCMainViewController alloc] initWithNibName:@"GMCMainViewController" bundle:nil];
    //UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:loadingViewController];
    //[controller setNavigationBarHidden:TRUE];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    // Launch notification
    notificationData = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Analytics
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

@end
