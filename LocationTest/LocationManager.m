//
//  LocationManager.m
//  Ajjas
//
//  Created by sanjay kumawat on 21/08/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LocationManager.h"
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "models.h"
#import <UserNotifications/UserNotifications.h>

@implementation LocationManager {
  CLLocationManager *locationManager;
  BOOL isBg;
  int count;
  id<LocationDelegate> delegate;
}
LocationManager *sharedLocManager;


+(LocationManager*)getInstance {
  if(!sharedLocManager) sharedLocManager = [[LocationManager alloc] init];
  return sharedLocManager;
}

-(void)setDelegate:(id<LocationDelegate>)del{
  delegate = del;
}

-(id)init{
  self = [super init];
  locationManager = [[CLLocationManager alloc] init];
  [locationManager setPausesLocationUpdatesAutomatically:false];
  isBg = false;
  count = 0;
  return self;
}

-(void)startLocUpdatesForBackground {
  isBg = true;
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  locationManager.delegate = self;
  [locationManager setAllowsBackgroundLocationUpdates:true];
  if (status == kCLAuthorizationStatusAuthorizedAlways) [locationManager startUpdatingLocation];
  else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) [locationManager requestAlwaysAuthorization];
  else if (status == kCLAuthorizationStatusNotDetermined) [locationManager requestWhenInUseAuthorization];
  else [self stopGettingLocationUpdates];
}

-(void)startGettingLocationForTerminatedApp {
  //  [self stopGettingLocationUpdates];
  locationManager.delegate = self;
  //  [locationManager setAllowsBackgroundLocationUpdates:true];
  locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
  locationManager.activityType = CLActivityTypeOtherNavigation;
  [locationManager startMonitoringSignificantLocationChanges];
  //  [locationManager startUpdatingLocation];
}

-(void)stopGettingLocationUpdates {
  [locationManager stopMonitoringSignificantLocationChanges];
  [locationManager setAllowsBackgroundLocationUpdates:NO];
  locationManager.delegate = nil;
  [locationManager stopUpdatingLocation];
}



-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
  [Utils log:[NSString stringWithFormat:@"Location Permission Status: %d",status]];
  [self startLocUpdatesForBackground];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  [Utils log:[NSString stringWithFormat:@"didFailWithError: %@",error.localizedDescription]];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
  CLLocation *location = [locations lastObject];
  [delegate onLocation:location.coordinate];

  [self createRegionWithCurrLocation:location];

  Location *rlmLocation = [Location new];
  rlmLocation.lat = location.coordinate.latitude;
  rlmLocation.lng = location.coordinate.longitude;
  rlmLocation.ts = location.timestamp;

  RLMRealm *realm = [RLMRealm defaultRealm];
  [realm beginWriteTransaction];
  [realm addObject:rlmLocation];
  [realm commitWriteTransaction];
  NSLog(@"loc ========> %f %f %@", rlmLocation.lat, rlmLocation.lng, rlmLocation.ts);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region{
  [self generateNotif: [NSString stringWithFormat:@"USER EXITED THE TEST REGION %@", region.identifier]];
  [locationManager stopMonitoringForRegion:region];
  [Utils log:[NSString stringWithFormat:@"Exited region %@",region.identifier]];
  if(UIApplication.sharedApplication.applicationState == UIApplicationStateBackground){
    [self startLocUpdatesForBackground];
  }
  [self createRegionWithCurrLocation:manager.location];
}

-(void)createRegionWithCurrLocation:(CLLocation*)location {
  NSDictionary *latestRegion = [[NSUserDefaults standardUserDefaults] objectForKey:@"latestRegion"];
  CLLocation *latestRegLoc;
  if(latestRegion)
    latestRegLoc = [[CLLocation alloc] initWithLatitude:[latestRegion[@"lat"] doubleValue] longitude:[latestRegion[@"lng"] doubleValue]];
  if(!latestRegLoc || [latestRegLoc distanceFromLocation:location] >= ([latestRegion[@"radius"] doubleValue] / 2)){
    [self startMonitoringRegionWithCenter:location.coordinate identifier:nil];
  }
}


-(void)startMonitoringRegionWithCenter:(CLLocationCoordinate2D)center identifier:(NSString*)identifier{
  int count = 0;
  NSDictionary *latestRegion = [[NSUserDefaults standardUserDefaults] objectForKey:@"latestRegion"];
  count = [latestRegion[@"count"] intValue];
  count++;
  if(locationManager.monitoredRegions.count > 15){
    NSArray<CLCircularRegion*> *monitoredRegions = [locationManager.monitoredRegions allObjects];
    monitoredRegions = [monitoredRegions sortedArrayUsingComparator:^NSComparisonResult(CLCircularRegion *obj1, CLCircularRegion *obj2) {
      return [obj1.identifier compare:obj2.identifier];
    }];
    for (int i = 0 ; i < 5; i++) {
      [locationManager stopMonitoringForRegion:monitoredRegions[i]];
      [Utils log:[NSString stringWithFormat:@"regionToRemove: %@", monitoredRegions[i].identifier]];
    }
  }
  CLCircularRegion *regionToMonitor = [[CLCircularRegion alloc] initWithCenter:center radius:100 identifier: (identifier ? identifier : [NSString stringWithFormat:@"test_%d", count])];
  regionToMonitor.notifyOnExit = true;
  regionToMonitor.notifyOnEntry = false;
  if([CLLocationManager isMonitoringAvailableForClass:CLCircularRegion.class]) {
    [locationManager startMonitoringForRegion:regionToMonitor];
  }
  [[NSUserDefaults standardUserDefaults] setObject:@{
    @"lat": [NSNumber numberWithDouble: regionToMonitor.center.latitude],
    @"lng": [NSNumber numberWithDouble: regionToMonitor.center.longitude],
    @"identifier": regionToMonitor.identifier,
    @"radius": [NSNumber numberWithDouble: regionToMonitor.radius],
    @"count": [NSNumber numberWithInt:count],
  } forKey:@"latestRegion"];
  [Utils log:[NSString stringWithFormat:@"Created region %@",regionToMonitor.identifier]];
  [delegate onRegionCreate:regionToMonitor];
}

-(void)removeAllRegions{
  for (CLCircularRegion *region in locationManager.monitoredRegions) {
    [locationManager stopMonitoringForRegion:region];
  }
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"latestRegion"];
}

-(void)generateNotif:(NSString*)title{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
  content.title = title;
  content.sound = UNNotificationSound.defaultSound;

  UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
  UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"identifier" content:content trigger:trigger];

  [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
    if(error) NSLog(@"Error %@",error.localizedDescription);
  }];
}


@end
