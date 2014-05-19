//
//  FSVenue.m
//  SecondCircle
//
//  Created by Constantine Fry on 1/17/13.
//
//

#import "FSVenue.h"

@implementation FSVenue

- (id)initWithDictionary:(NSDictionary*)dic
{
    self = [super init];
    if (self) {
        NSDictionary *location = dic[@"location"];

        [self setCoordinate:CLLocationCoordinate2DMake([location[@"lat"] doubleValue],
                                                        [location[@"lng"] doubleValue])];
        self.dist = 0;
        self.name = dic[@"name"];
        self.venueId = dic[@"id"];
        
        
        self.lon = location[@"lng"];
        self.lat = location[@"lat"];
        
        self.city = location[@"city"];
        self.state = location[@"state"];
        self.country = location[@"country"];
        self.cc = location[@"cc"];
        self.postalCode = location[@"postalCode"];
        self.address = location[@"address"];
        self.fsVenue = dic;
    }
    return self;
}
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

-(CLLocationCoordinate2D)coordinate{
    return _coordinate;
}

-(NSString*)title{
    return self.name;
}


-(NSString*)iconURL{
    if ([self.fsVenue[@"categories"] count]) {
        NSDictionary *iconDic = self.fsVenue[@"categories"][0][@"icon"];
        NSString* url = [NSString stringWithFormat:@"%@bg_88%@",iconDic[@"prefix"],iconDic[@"suffix"]];
        return url;
    }else{
        return nil;
    }
}
@end
