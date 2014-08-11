//
//  GMCLocationManager.m
//  LocalTreats
//
//  Created by Mikhail Larionov on 3/14/13.
//
//

#import "GMCLocationManager.h"
#import <Parse/Parse.h>

@implementation GMCLocationManager

@synthesize locationManager;

static GMCLocationManager *sharedInstance = nil;
static NSUInteger fireLocationEnabledNotification = 0;

// Get the shared instance and create it if necessary.
+ (GMCLocationManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// Initialization
- (id)init
{
    self = [super init];
    
    if (self) {
        geoPoint = geoPointOld = nil;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.distanceFilter = 100.0f;
    }
    
    return self;
}

-(void)startUpdating
{
    geoPointOld = nil;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (newLocation.horizontalAccuracy < 0) return;
    
    if ( ! currentUserData ) return;
    
    // New location
    CLLocationCoordinate2D coord = newLocation.coordinate;
    geoPoint = [PFGeoPoint geoPointWithLatitude:coord.latitude longitude:coord.longitude];
    
    // Store in PFUser and get the result
    [currentUserData setObject:geoPoint forKey:@"location"];
    
    // Distance calculation
    float fDistance;
    if ( geoPointOld )
        fDistance = [geoPoint distanceInKilometersTo:geoPointOld];
    else
        fDistance = 10000000.0f;
    
    // If location was saved and distance is quite big, save data
    if ( fDistance > GMCLocationUpdateKilometers )
    {
        geoPointOld = geoPoint;
        [currentUserData saveInBackground];
        [[NSNotificationCenter defaultCenter]postNotificationName:kLocationUpdated object:nil];
        NSLog(@"Location updated");
    }
}

- (void)locationManager: (CLLocationManager *)manager
       didFailWithError: (NSError *)error {
    
    NSString *errorString;
    [manager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter]postNotificationName:kLocationUpdated object:nil];
    NSLog(@"Location manager did fail with error: %@",[error localizedDescription]);
    UIAlertView *alert;
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = @"You denied access to location services. It will affect the functionality you will be able to use. We advise to turn it on in settings.";
            [locationManager stopUpdatingLocation];
            alert = [[UIAlertView alloc] initWithTitle:@"Important notice" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            NSLog(@"Location data unavailable");
            break;
        default:
            NSLog(@"An unknown error has occurred");
            break;
    }
}

-(PFGeoPoint*)getDefaultPosition
{
    return [PFGeoPoint geoPointWithLatitude:37.7750 longitude:-122.4183];
}

-(PFGeoPoint*)getPosition
{
    return geoPoint;
}

-(Boolean) getLocationStatus
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        return TRUE;
    return FALSE;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized && fireLocationEnabledNotification == 0 )
        fireLocationEnabledNotification = 1;
}

@end
