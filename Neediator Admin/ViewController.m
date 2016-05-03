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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData:)];
    
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
    
    [self hideCollectionView:YES];
    
    [self.cameraButton addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpOutside];
    [self.libraryButton addTarget:self action:@selector(openLibrary:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)openCamera:(UIButton *)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)openLibrary:(UIButton *)sender {
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                MWPhoto *photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                [photos addObject:photo];
                MWPhoto *thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                [thumbs addObject:thumb];
                if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = true;
                }
            }
        }
        
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    browser = [[NeediatorPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.displayNavArrows = NO;
    browser.displaySelectionButtons = YES;
    browser.alwaysShowControls = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = NO;
    [browser setCurrentPhotoIndex:0];
    
    
    if (_selections != nil) {
        NSLog(@"Already Selected");
    }
    else if (browser.displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
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
            
            
            [self dismissVC:nil];
        });
        
    });
}



-(void)hideButtons:(BOOL)hide {
    self.cameraButton.hidden = hide;
    self.libraryButton.hidden = hide;
}

-(void)hideCollectionView:(BOOL)hide {
    self.collectionView.hidden = hide;
}



@end
