//
//  ViewController.h
//  LocationTest
//
//  Created by sanjay kumawat on 28/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Utils.h"

@interface ViewController : UIViewController <LocationDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


@end

