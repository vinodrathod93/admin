//
//  WebViewController.h
//  Neediator Admin
//
//  Created by adverto on 04/05/16.
//  Copyright © 2016 Vinod Rathod. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *pdfName;
@end
