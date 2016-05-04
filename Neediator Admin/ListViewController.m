//
//  ListViewController.m
//  Neediator Admin
//
//  Created by adverto on 30/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "ListViewController.h"
#import "ViewController.h"
#import "WebViewController.h"

@interface ListViewController ()

@property (nonatomic, strong) RLMResults *listings;

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    RLMRealm *realmMainThread = [RLMRealm defaultRealm];
    RLMResults *allData = [StoreDataRealm allObjectsInRealm:realmMainThread];
    
    self.listings = allData;
    
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addnewListing:)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addnewListing:)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    RLMRealm *realmMainThread = [RLMRealm defaultRealm];
    RLMResults *allData = [StoreDataRealm allObjectsInRealm:realmMainThread];
    
    self.listings = allData;
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listings.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listingCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    
    StoreDataRealm *listModel = self.listings[indexPath.row];
    
    cell.textLabel.text = listModel.name;
    cell.detailTextLabel.text = listModel.notedPoints;
    
    return cell;
}



-(void)addnewListing:(id)sender {
    ViewController *viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"addNewListingVC"];
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:viewcontroller];
    [self presentViewController:navigationVC animated:YES completion:nil];
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    StoreDataRealm *listModel = self.listings[indexPath.row];
    
    
    NSString *pdfname = [NSString stringWithFormat:@"%@-%ld.pdf", listModel.name, indexPath.row];
    
    NSArray * documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString    * documentDirectory = [documentDirectories objectAtIndex:0];
    NSString *pdfFileName = [documentDirectory stringByAppendingPathComponent:pdfname];
    
    
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 480, 792), nil);
    
    CGFloat pageOffset = 30;
    
    
    NSString *coordinate = [NSString stringWithFormat:@"Coordinates: %@,%@", listModel.latitude, listModel.longitude];
    NSString *name = [NSString stringWithFormat:@"Name: %@", listModel.name];
    NSString *ratings = [NSString stringWithFormat:@"Rating: %@", listModel.ratings.stringValue];
    NSString *notes = [NSString stringWithFormat:@"Notes: %@", listModel.notedPoints];
    NSString *image = @"Images";
    
    [name drawInRect:CGRectMake(20, pageOffset, 400, 34) withAttributes:@{
                                                                          NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:13]
                                                                          
                                                                          }];
    [coordinate drawInRect:CGRectMake(20, 70, 400, 34) withAttributes:@{
                                                                        NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:13]
                                                                        
                                                                        }];
    [ratings drawInRect:CGRectMake(20, 100, 400, 34) withAttributes:@{
                                                                                          NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:13]
                                                                                          }];
    
    [notes drawInRect:CGRectMake(20, 150, 400, 50) withAttributes:@{
                                                                                   NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:13]
                                                                                   }];
    
    
    [image drawInRect:CGRectMake(20, 200, 400, 34) withAttributes:@{
                                                                    NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Medium" size:13]
                                                                    
                                                                    }];
    
    int i = 0;
    
    for (ImagesRealm *imagesRealm in listModel.images) {
        
        if (i == listModel.images.count) {
            NSLog(@"Filled");
        }
        else {
            UIImage *image = [UIImage imageWithData:imagesRealm.thumbImage];
            
            int xOffset = (i == 0) ? 20 : image.size.width * i + 50;
            
            [image drawInRect:CGRectMake(xOffset, 230, image.size.width, image.size.height)];
            
            
        }
        i++;
        
    }
    
    
    UIGraphicsEndPDFContext();
    
    
    NSLog(@"finalpath--%@",pdfFileName);
    
    NSError *error;
    
    NSData *datapdf = [NSData dataWithContentsOfFile:pdfFileName options:0 error:&error]; //add url string here
    
    if(datapdf)
        [datapdf writeToFile:pdfFileName atomically:YES];
    
    
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
    webView.urlString = pdfFileName;
    webView.pdfName = pdfname;
    
    [self.navigationController pushViewController:webView animated:YES];
    
    
    
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
