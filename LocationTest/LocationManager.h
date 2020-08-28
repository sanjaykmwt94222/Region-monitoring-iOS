//
//  LocationManager.h
//  LocationTest
//
//  Created by sanjay kumawat on 28/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Utils.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate>
-(void)startLocUpdatesForBackground;
-(void)startGettingLocationForTerminatedApp;
-(void)removeAllRegions;
-(void)stopGettingLocationUpdates;
+(LocationManager*)getInstance;
-(void)setDelegate:(id<LocationDelegate>)del;
-(void)generateNotif:(NSString*)title;
@end
