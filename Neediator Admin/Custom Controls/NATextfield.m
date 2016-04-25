//
//  NATextfield.m
//  Neediator Admin
//
//  Created by Vinod Rathod on 20/04/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "NATextfield.h"

static CGFloat leftMargin = 10;

@implementation NATextfield

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib {
    self.layer.borderColor    = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius   = 2.f;
    self.layer.borderWidth    = 0.5f;
    [self setTintColor:[UIColor whiteColor]];
}


-(CGRect)textRectForBounds:(CGRect)bounds {
    bounds.origin.x += leftMargin;
    
    return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    bounds.origin.x += leftMargin;
    
    return bounds;
}


@end
