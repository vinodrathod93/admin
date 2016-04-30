//
//  ViewController.m
//  Neediator Admin
//
//  Created by Vinod Rathod on 20/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ADD";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissVC:)];
    
    self.locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
    [self.view addSubview:_activityView];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    
    
    self.notesTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.notesTF.layer.borderWidth = 0.5f;
    self.notesTF.layer.masksToBounds = YES;
    
    self.notesTF.enablesReturnKeyAutomatically = YES;
    
    
    self.pointNotedTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pointNotedTF.layer.borderWidth = 0.5f;
    self.pointNotedTF.layer.masksToBounds = YES;

    
    [self.currentLocationButton addTarget:self action:@selector(selectCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton addTarget:self action:@selector(saveData:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dismissVC:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectCurrentLocation {
    
    [self.currentLocationButton setTitle:@"Tap to Capture Location" forState:UIControlStateNormal];
    
    
    [self.locationManager startUpdatingLocation];
    [_activityView startAnimating];
    
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    
    [_activityView stopAnimating];
    
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [self alertLocationPermission];
                
                break;
                
            case kCLErrorLocationUnknown:
                NSLog(@"Location Unknown");
                
            default:
                [NeediatorAdminUtility alert:@"Neediator" withMessage:@"Something Went Wrong. Failed to get the location" onController:self];
                break;
        }
    } else {
        
        [NeediatorAdminUtility alert:@"Neediator" withMessage:@"Failed to Get your Location" onController:self];
    }
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"%.8f", currentLocation.coordinate.longitude);
        NSLog(@"%.8f", currentLocation.coordinate.latitude);
        
    }
    
    
    
    
    // Reverse Geocoding
    [_geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            NSLog(@"%@ %@\n%@ %@\n%@\n%@",
                  _placemark.subLocality, _placemark.locality,
                  _placemark.postalCode, _placemark.addressDictionary,
                  _placemark.administrativeArea,
                  _placemark.country);
            
            
            [_activityView stopAnimating];
            
            self.latLngLabel.text = [NSString stringWithFormat:@"%f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
            
            [_locationManager stopUpdatingLocation];
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

-(void)alertLocationPermission {
    
    
    UIAlertController *alertLocationController = [UIAlertController alertControllerWithTitle:@"Location not Enabled" message:@"Location services are not enabled on your device. Please go to settings and enable location service to use this feature." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (UIApplicationOpenSettingsURLString != NULL) {
            NSURL *settingURL         = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingURL];
        }
        else {
            [NeediatorAdminUtility alert:@"Go to Settings" withMessage:@"Location services are not enabled on your device. Please go to settings and enable location service to use this feature." onController:self];
        }
        
    }];
    
    [alertLocationController addAction:cancelAction];
    [alertLocationController addAction:settingsAction];
    
    [self presentViewController:alertLocationController animated:YES completion:nil];
    
    
}


-(void)saveData:(id)sender {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        [realm beginWriteTransaction];
        
        StoreDataRealm *storeRealm = [[StoreDataRealm alloc] init];
        storeRealm.name = self.storenameTF.text;
        storeRealm.latitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
        storeRealm.longitude = [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
        storeRealm.notedPoints = self.pointNotedTF.text;
        storeRealm.notes = self.notesTF.text;
        
        [realm addObject:storeRealm];
        [realm commitWriteTransaction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            RLMRealm *realmMainThread = [RLMRealm defaultRealm];
            
            RLMResults *allData = [StoreDataRealm allObjectsInRealm:realmMainThread];
            
            logm(allData);
            logm(@"Data Saved");
        });
        
    });
}





@end
