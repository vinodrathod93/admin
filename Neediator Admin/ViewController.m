//
//  ViewController.m
//  Neediator Admin
//
//  Created by Vinod Rathod on 20/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "ViewController.h"
#import "ListingCollectionViewCell.h"
#import "ImageModalViewController.h"


@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,MWPhotoBrowserDelegate ,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;

@property (nonatomic, strong) NSMutableArray *cameraCapturedArray;
@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
@property (nonatomic, strong) NSMutableArray *finalDisplayArray;

@property (nonatomic, strong) NSMutableArray *cameraThumbnails;
@property (nonatomic, strong) NSMutableArray *galleryThumbnails;

@end

@implementation ViewController {
    MWPhotoBrowser *browser;
    NSMutableArray *_selections;
    NSMutableArray *_allThumbnails;
    UIImage *_cameraImage;
}

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
    
    [self.cameraButton addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.libraryButton addTarget:self action:@selector(openLibrary:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.selectedImagesArray = [[NSMutableArray alloc] init];
    self.finalDisplayArray = [[NSMutableArray alloc] init];
    self.cameraCapturedArray = [[NSMutableArray alloc] init];
    
    self.cameraThumbnails = [[NSMutableArray alloc] init];
    self.galleryThumbnails = [[NSMutableArray alloc] init];
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please give this app permission to access your photo library in your settings app!" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }
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
    
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
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




#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    NSLog(@"Selections %@", _selections);
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([_selections containsObject:[NSNumber numberWithBool:YES]]) {
            
            [self.selectedImagesArray removeAllObjects];
            [self.galleryThumbnails removeAllObjects];
            
            [self.selectedImagesArray addObjectsFromArray:[self largeSelectedImages]];
            [self.galleryThumbnails addObjectsFromArray:[self thumbnailSelectedImages]];
            
            
            if (self.finalDisplayArray.count > 0) {
                [self.finalDisplayArray removeAllObjects];
                [_allThumbnails removeAllObjects];
            }
            
            [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
            [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
            [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
            
            [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
            [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
            [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
            
            [self hideCollectionView:NO];
            [self hideButtons:YES];
            [self.collectionView reloadData];
        }
        
        
        
    }];
    
}


#pragma mark - ImagePicker Delegates

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    
    NSLog(@"%@", info);
    _cameraImage = info[UIImagePickerControllerOriginalImage];
    
    
    
    [self.cameraCapturedArray addObject:_cameraImage];
    [self.cameraThumbnails addObject:[self imageWithImage:_cameraImage scaledToSize:CGSizeMake(100, 150)]];
    
    if (self.finalDisplayArray.count > 0) {
        [self.finalDisplayArray removeAllObjects];
        [_allThumbnails removeAllObjects];
    }
    
    
    
    [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
    [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
    [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
    
    [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
    [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
    [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
    
    // Show Image in collection view
    [self hideCollectionView:NO];
    [self hideButtons:YES];
    [self.collectionView reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}





-(NSArray *)positionArray {
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    
    
    [_selections enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.intValue == 1) {
            [positions addObject:@(idx)];
        }
    }];
    
    return positions;
    
}


-(UIImage *)getAssetThumbnail:(PHAsset *)asset withTargetSize:(CGSize)size {
    PHImageManager *manager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    __block UIImage *thumbnail = [[UIImage alloc] init];
    options.synchronous = TRUE;
    
    [manager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        thumbnail = result;
    }];
    
    return thumbnail;
}

-(void)removeImageSelectionAtIndex:(int)itemIndex {
    
    
    NSArray *positions = [self positionArray];
    
    if (positions.count == 0) {
        ;
    }
    else {
        NSNumber *index = positions[itemIndex];
        NSLog(@"Index, %d", index.intValue);
        
        
        [_selections replaceObjectAtIndex:index.intValue withObject:@0];
        
        NSLog(@"%@", _selections);
    }
}


-(NSArray *)commonSelectedImagesWithSize:(CGSize)size {
    NSMutableArray *selectedImagesArray = [[NSMutableArray alloc] init];
    NSArray *positions = [self positionArray];
    
    
    [positions enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull index, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *photo = _assets[index.intValue];
        UIImage *image = [self getAssetThumbnail:photo withTargetSize:size];
        
        
        [selectedImagesArray addObject:image];
        
    }];
    
    
    
    return selectedImagesArray;
}


-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


-(NSArray *)thumbnailSelectedImages {
    
    NSMutableArray *thumbnails = [NSMutableArray array];
    
    thumbnails = (NSMutableArray *)[self commonSelectedImagesWithSize:CGSizeMake(100, 150)];
    
    
    return thumbnails;
}


-(NSArray *)largeSelectedImages {
    
    return [self commonSelectedImagesWithSize:self.view.frame.size];
}






#pragma mark - UICollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    
    NSArray *thumbnailImages = self.finalDisplayArray;
    
    if (thumbnailImages.count != 0) {
        return [thumbnailImages count];
    }
    else
        return 0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"selectedImagesCellIdentifier";
    
    ListingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell.removeButton addTarget:self action:@selector(removeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    if ([_allThumbnails count] >= 1) {
        NSLog(@"Entered the loop");
        
        
        cell.imageView.image = (UIImage *)_allThumbnails[indexPath.item];
        
        
        if (indexPath.item == [_allThumbnails count] -1) {
            NSLog(@"Removed Delete Button");
            
            cell.imageView.frame = CGRectMake(cell.frame.size.width/2 - (25/2), cell.frame.size.height/2 - (25/2), 25, 25);
            [cell hideRemoveButton:YES];
        }
        else
        {
            cell.imageView.frame = CGRectMake(0, 0, 90, 110);
            [cell hideRemoveButton:NO];
        }
        
    }
    
    return cell;
}




-(void)removeImage:(UIButton *)sender {
    
    ListingCollectionViewCell *cell = (ListingCollectionViewCell *)[[[sender superview] superview] superview];
    
    UIImage *tappedImage = [cell.imageView image];
    
    
    if ([self.cameraThumbnails containsObject:tappedImage]) {
        
        int index = [self.cameraThumbnails indexOfObject:tappedImage];
        [self.cameraThumbnails removeObject:tappedImage];
        
        
        [self.cameraCapturedArray removeObjectAtIndex:index];
        
    }
    else if ([self.galleryThumbnails containsObject:tappedImage]) {
        
        int index = [self.galleryThumbnails indexOfObject:tappedImage];
        [self removeImageSelectionAtIndex:index];
    }
    
    
    self.selectedImagesArray = (NSMutableArray *)[self largeSelectedImages];
    self.galleryThumbnails = (NSMutableArray *)[self thumbnailSelectedImages];
    
    if (self.finalDisplayArray.count > 0) {
        [self.finalDisplayArray removeAllObjects];
        [_allThumbnails removeAllObjects];
    }
    
    [self.finalDisplayArray addObjectsFromArray:self.selectedImagesArray];
    [self.finalDisplayArray addObjectsFromArray:self.cameraCapturedArray];
    [self.finalDisplayArray addObject:[UIImage imageNamed:@"addPlus"]];
    
    [_allThumbnails addObjectsFromArray:self.galleryThumbnails];
    [_allThumbnails addObjectsFromArray:self.cameraThumbnails];
    [_allThumbnails addObject:[UIImage imageNamed:@"addPlus"]];
    
    [self.collectionView reloadData];
    
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.item == [self.finalDisplayArray indexOfObject:self.finalDisplayArray.lastObject]) {
        // New Image
        
        
        ListingCollectionViewCell *cell = (ListingCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        [self showNewActionSheet:cell];
        
    }
    else {
        
        NSArray *images = self.finalDisplayArray;
        
        ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
        imageModalVC.image  = images[indexPath.item];
        
        imageModalVC.transitioningDelegate = self;
        imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:imageModalVC animated:YES completion:nil];
    }
    
}



-(void)showNewActionSheet:(ListingCollectionViewCell *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Send Prescription" message:@"Select Mode to Add Images" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera:nil];
    }];
    
    UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openLibrary:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    
    [controller addAction:cameraAction];
    [controller addAction:galleryAction];
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    
    [self presentViewController:controller animated:YES completion:nil];
}


@end
