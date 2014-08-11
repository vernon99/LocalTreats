
#import "GMCAppDelegate.h"
#import "GMCMainViewController.h"
#import "GMCLocationManager.h"
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

@implementation GMCAppDelegate

#pragma mark - UIApplicationDelegate

static NSDictionary* notificationData = nil;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ( launchOptions )
        NSLog(@"Launch options: %@", launchOptions);
    
    bFirstActivation = true;
    
    // Testflight
    @try {
        [TestFlight takeOff:APP_TESTFLIGHT_TOKEN];
    }
    @catch (NSException *exception) {
        NSLog(@"TestFlight error: %@",exception);
    }
    
    // Parse and crashlytics
    [Crashlytics startWithAPIKey:@"05bf10b64dd5e5dbbe55dfb384d01abad7bba586"];
    
    // Navigation controller
    GMCMainViewController *mainViewController = [[GMCMainViewController alloc] initWithNibName:@"GMCMainViewController" bundle:nil];
    //UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    //[controller setNavigationBarHidden:TRUE];
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    // Launch notification
    notificationData = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Flurry
    [Flurry startSession:@"HKDB46NF9PBQGFSFH8WK"];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    GMCMainViewController* mainViewController;
    if ( self.window.rootViewController )
        if ( [self.window.rootViewController isKindOfClass:[GMCMainViewController class]] )
        {
            mainViewController = (GMCMainViewController*) self.window.rootViewController;
            if ( mainViewController.showingCard )
            {
                [mainViewController reloadData];
                return;
            }
        }
    
    mainViewController = [[GMCMainViewController alloc] initWithNibName:@"GMCMainViewController" bundle:nil];
    self.window.rootViewController = mainViewController;
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CFAsyncImageView applicationDidReceiveMemoryWarning];
            NSLog(@"cleaned");
        });
    });
}

@end
