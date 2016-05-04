//
//  ListingCollectionViewCell.m
//  Neediator Admin
//
//  Created by Vinod Rathod on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "ListingCollectionViewCell.h"

@implementation ListingCollectionViewCell


-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.removeButton.layer.cornerRadius = self.removeButton.frame.size.width/2;
    self.removeButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.removeButton.layer.borderWidth = 0.7f;
    self.removeButton.layer.masksToBounds = YES;
    
    
    self.listingContentView.backgroundColor = [NeediatorAdminUtility defaultColor];
    self.listingContentView.userInteractionEnabled = YES;
    self.listingContentView.layer.cornerRadius = 5.f;
    self.listingContentView.layer.masksToBounds = YES;
}

-(void)hideRemoveButton:(BOOL)hide {
    self.removeButton.hidden = hide;
}
@end
