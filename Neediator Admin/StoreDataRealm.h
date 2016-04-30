//
//  StoreDataRealm.h
//  Neediator Admin
//
//  Created by adverto on 30/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <Realm/Realm.h>

@interface StoreDataRealm : RLMObject

@property  NSString *name;
@property  NSString *latitude;
@property  NSString *longitude;
@property  NSString *notedPoints;
@property  NSString *notes;

@end
