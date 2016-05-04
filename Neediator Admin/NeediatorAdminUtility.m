//
//  NeediatorAdminUtility.m
//  Neediator Admin
//
//  Created by adverto on 30/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "NeediatorAdminUtility.h"

@implementation NeediatorAdminUtility

+ (void)alert:(NSString *)title withMessage:(NSString *)message onController:(UIViewController *)controller {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertVC dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertVC addAction:cancelAction];
    
    [controller presentViewController:alertVC animated:YES completion:nil];
}


+(UIColor *)defaultColor {
    return [UIColor colorWithRed:235/255.f green:235/255.f blue:240/255.f alpha:1.0];
}

@end
