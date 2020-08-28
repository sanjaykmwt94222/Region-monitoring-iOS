//
//  Utils.m
//  LocationTest
//
//  Created by sanjay kumawat on 30/06/20.
//  Copyright © 2020 sanjay kumawat. All rights reserved.
//

#import "Utils.h"
#import "models.h"
#import <Realm/Realm.h>

@implementation Utils
+(void)log:(NSString*)msg{

  Logs *rlmLog = [Logs new];
  rlmLog.ts = [NSDate date];
  rlmLog.msg = msg;
  RLMRealm *realm = [RLMRealm defaultRealm];
  [realm beginWriteTransaction];
  [realm addObject:rlmLog];
  [realm commitWriteTransaction];
  NSLog(@"(%@) =========> %@",[NSDate date], msg);
}
@end
