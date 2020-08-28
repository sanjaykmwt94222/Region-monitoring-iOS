//
//  AppDelegate.m
//  LocationTest
//
//  Created by sanjay kumawat on 28/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManager.h"
#import "Utils.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
  }];
//  [[LocationManager getInstance] stopGettingLocationUpdates];
  if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]){
    [Utils log:@"Launched with location key"];
    [[LocationManager getInstance] generateNotif:@"You have got the location in background"];
    [[LocationManager getInstance] startGettingLocationForTerminatedApp];
    [[LocationManager getInstance] startLocUpdatesForBackground];
  } else {
    [Utils log:@"Launched by user"];
  }
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application{
  [Utils log:@"App will terminate"];
    [[LocationManager getInstance] generateNotif:@"You have killed the application"];
  [[LocationManager getInstance] startGettingLocationForTerminatedApp];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
  completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

@end
