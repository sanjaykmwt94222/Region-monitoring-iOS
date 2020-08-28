//
//  Utils.h
//  LocationTest
//
//  Created by sanjay kumawat on 30/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>
-(void)onLocation:(CLLocationCoordinate2D)location;
-(void)onRegionCreate:(CLCircularRegion*)region;
@end

@interface Utils : NSObject
+(void)log:(NSString*)msg;
@end
