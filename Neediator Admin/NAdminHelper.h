//
//  NAdminHelper.h
//  Neediator Admin
//
//  Created by adverto on 30/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#ifndef NAdminHelper_h
#define NAdminHelper_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"

static void __logm(id msg) {
    NSLog(@"%@", msg);
}

static void loge(id err) {
    NSLog(@"Error: %@", err);
}

#ifdef NO_DEBUG
#define logm(...)
#else
#define logm __logm
#endif


typedef void (^LoginBlock)(BOOL isLoggedIn, id data);



static NSDate *JSDateToNSDate(NSString *dateTimeString) {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    NSDate *convertDate = [dateFormat dateFromString:dateTimeString];
    
    return convertDate;
}

static NSString *convertToRupees(NSInteger amount) {
    NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    
    return [headerCurrencyFormatter stringFromNumber:@(amount)];
}



#endif /* NAdminHelper_h */
