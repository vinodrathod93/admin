//
//  ViewController.h
//  Neediator Admin
//
//  Created by Vinod Rathod on 20/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NATextView.h"
#import "NATextfield.h"


@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    @private
        CLLocationManager *_locationManager;
        CLGeocoder *_geocoder;
        CLPlacemark *_placemark;
}
@property (weak, nonatomic) IBOutlet NATextfield *storenameTF;
@property (weak, nonatomic) IBOutlet NATextView *notesTF;
@property (weak, nonatomic) IBOutlet NATextView *pointNotedTF;

@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *latLngLabel;

@property(nonatomic, strong) CLLocationManager *locationManager;
@end
