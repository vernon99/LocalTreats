
#import "JMImageCache.h"

#define AppDelegate ((LFDAppDelegate*)[[UIApplication sharedApplication]delegate])

@interface GMCAppDelegate : NSObject <UIApplicationDelegate> {

    Boolean bFirstActivation;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, retain) JMImageCache *imageCache;

@end
