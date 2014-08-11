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

static float const GMCLocationUpdateKilometers = 0.5;
static NSString* const kLocationUpdated = @"kLocationUpdated";

@class PFGeoPoint;

@interface GMCLocationManager : NSObject <CLLocationManagerDelegate>
{
    CLLocationManager*  locationManager;
    PFGeoPoint          *geoPoint;
    PFGeoPoint          *geoPointOld;
}

+ (GMCLocationManager*)sharedInstance;

@property (nonatomic, retain) CLLocationManager* locationManager;

-(void)startUpdating;
-(PFGeoPoint*)getPosition;
-(PFGeoPoint*)getDefaultPosition;
-(Boolean) getLocationStatus;

@end
