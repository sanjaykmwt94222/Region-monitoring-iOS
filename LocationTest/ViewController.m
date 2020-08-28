//
//  ViewController.m
//  LocationTest
//
//  Created by sanjay kumawat on 28/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import "ViewController.h"
#import "LocationManager.h"
#import "Utils.h"
#import "models.h"
#import <Realm/Realm.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.mapView.showsUserLocation = YES;
}
- (IBAction)onStartPress:(id)sender {
  [[LocationManager getInstance] generateNotif:@"STARTED"];
  [[LocationManager getInstance] setDelegate:self];
  [Utils log:@"Started location task"];
  [[LocationManager getInstance] startLocUpdatesForBackground];
}

- (IBAction)onStopPress:(id)sender {
  [[LocationManager getInstance] generateNotif:@"STOPPED"];
  [Utils log:@"Stopped location task"];
  [[LocationManager getInstance] stopGettingLocationUpdates];
}
- (IBAction)deleteRegions:(id)sender {
  [[LocationManager getInstance] removeAllRegions];
}

- (IBAction)readLocationFromRealm:(id)sender {
  RLMRealm *realm = [RLMRealm defaultRealm];
  NSDate *readDate;

//  RLMResults *locations = [Location allObjects];
  RLMResults *logs = [Logs allObjects];
  for (Logs *log in logs) {
    RLMResults *locations;
    if(readDate) {
      locations = [Location objectsInRealm:realm where:@"ts < %@ && ts > %@", log.ts, readDate];
    } else {
      locations = [Location objectsInRealm:realm where:@"ts < %@", log.ts];
    }
    for (Location *loc in locations) {
      NSLog(@"%f %f %@", loc.lat, loc.lng, loc.ts);
    }
    NSLog(@"Log: %@ %@", log.ts, log.msg);
    readDate = log.ts;
  }

}

- (void)onLocation:(CLLocationCoordinate2D)location{
  [self.mapView setCenterCoordinate:location animated:YES];
}

- (void)onRegionCreate:(CLCircularRegion*)region{
  self.mapView.delegate = self;
  MKCircle *circle = [MKCircle circleWithCenterCoordinate:region.center radius:region.radius];
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(region.center, 250, 250 );
  MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
  [self.mapView setRegion:adjustedRegion animated:YES];
  [self.mapView addOverlay:circle];
  [self.mapView setCenterCoordinate:region.center animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
  MKCircleRenderer *cr = [[MKCircleRenderer alloc] initWithOverlay:overlay];
  cr.strokeColor = UIColor.redColor;
  CGFloat red = arc4random_uniform(256) / 255.0;
  CGFloat green = arc4random_uniform(256) / 255.0;
  CGFloat blue = arc4random_uniform(256) / 255.0;
  cr.fillColor = [UIColor colorWithRed:red green:green blue:blue alpha:0.2];
  cr.lineWidth = 1;
  return cr;
}


@end
