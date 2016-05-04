//
//  ImageModalViewController.m
//  Neediator Admin
//
//  Created by Vinod Rathod on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "ImageModalViewController.h"

@interface ImageModalViewController ()

@end

@implementation ImageModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.imageContentView = [[UIView alloc] init];
    self.bigImageView = [[UIImageView alloc] init];
    
    self.imageContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    self.bigImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    self.imageContentView.backgroundColor = [UIColor blackColor];
    self.imageContentView.alpha = 0.7;
    
    [self.view addSubview:self.imageContentView];
    [self.imageContentView addSubview:self.bigImageView];
    
    
    
    
    
    self.bigImageView.image = self.image;



    UIGestureRecognizer *touchGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(didTouch:)];
    [self.view addGestureRecognizer:touchGR];



    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];


    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];

    UISwipeGestureRecognizer *upSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss:)];
    upSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:upSwipe];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didTouch:(UIGestureRecognizer *)recognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dismiss:(UIGestureRecognizer*)gesture {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
