//
//  models.h
//  LocationTest
//
//  Created by sanjay kumawat on 30/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import <CoreLocation/CoreLocation.h>

@interface Location: RLMObject
@property NSDate *ts;
@property double lat;
@property double lng;
@end

@interface Logs: RLMObject
@property NSDate *ts;
@property NSString *msg;
@end
