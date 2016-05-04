//
//  ListingCollectionViewCell.h
//  Neediator Admin
//
//  Created by Vinod Rathod on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *listingContentView;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIImageView *listingImageView;

-(void)hideRemoveButton:(BOOL)hide;

@end
