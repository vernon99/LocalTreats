//
//  FSVenue.h
//  SecondCircle
//
//  Created by Constantine Fry on 1/17/13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FSVenue : NSObject<MKAnnotation>{
    CLLocationCoordinate2D _coordinate;
}
- (id)initWithDictionary:(NSDictionary*)dic;

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *venueId;

@property(nonatomic,strong)NSNumber *lat;
@property(nonatomic,strong)NSNumber *lon;


@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSString *city;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSString *country;
@property(nonatomic,strong)NSString *cc;
@property(nonatomic,strong)NSString *postalCode;
@property(nonatomic,assign)CLLocationDistance dist;

@property(nonatomic,strong)NSDictionary *fsVenue;

-(NSString*)iconURL;
@end
