//
//  GMCLocationManager.h
//  LocalTreats
//
//  Created by Mikhail Larionov on 3/14/13.
//
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocationManager.h"
#import <CoreLocation/CoreLocation.h>

#define locManager [GMCLocationManager sharedInstance]

static CLLocationDistance const GMCLocationUpdateMeters = 500.0;
static NSString* const kLocationUpdated = @"kLocationUpdated";

@interface GMCLocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager*   locationManager;
    CLLocation*          geoPoint;
    CLLocation*          geoPointOld;
}

+ (GMCLocationManager*)sharedInstance;

@property (nonatomic, retain) CLLocationManager* locationManager;

-(void)startUpdating;
-(CLLocation*)getPosition;
-(CLLocation*)getDefaultPosition;
-(Boolean) getLocationStatus;

@end
