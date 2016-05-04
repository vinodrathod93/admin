//
//  WebViewController.m
//  Neediator Admin
//
//  Created by adverto on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import "WebViewController.h"
#import <MessageUI/MessageUI.h>

@interface WebViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(prepareMail:)];
    
    
    
    // Do any additional setup after loading the view.
    
    self.webView.delegate = self;
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    
        NSURL *url = [NSURL fileURLWithPath:self.urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
//        self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    
        self.webView.autoresizesSubviews = YES;
        self.webView.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
        [self.webView loadRequest:req];
    
    
}



-(void)prepareMail:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Listing Detail";
    // Email Content
    NSString *messageBody = @"Hi Neediator Team, I'm sending: \n"; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"care@neediator.in"];
    
    MFMailComposeViewController *mailComposerVC = [[MFMailComposeViewController alloc] init];
    
    if ([MFMailComposeViewController canSendMail]) {
        mailComposerVC.mailComposeDelegate = self;
        [mailComposerVC setSubject:emailTitle];
        [mailComposerVC setMessageBody:messageBody isHTML:YES];
        [mailComposerVC setToRecipients:toRecipents];
        
        [mailComposerVC addAttachmentData:[NSData dataWithContentsOfFile:self.urlString] mimeType:@"application/pdf" fileName:self.pdfName];
        
        // Present mail view controller on screen
        [self presentViewController:mailComposerVC animated:YES completion:NULL];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [_activityView removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
