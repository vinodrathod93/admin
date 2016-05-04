//
//  ImagesRealm.h
//  Neediator Admin
//
//  Created by adverto on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <Realm/Realm.h>

@interface ImagesRealm : RLMObject

@property NSData *thumbImage;

@end

RLM_ARRAY_TYPE(ImagesRealm)