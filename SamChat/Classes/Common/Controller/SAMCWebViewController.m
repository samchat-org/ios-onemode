//
//  SAMCWebViewController.m
//  SamChat
//
//  Created by HJ on 11/4/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCWebViewController.h"

@interface SAMCWebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *navtitle;
@property (nonatomic, copy) NSString *htmlName;

@end

@implementation SAMCWebViewController

- (instancetype)initWithTitle:(NSString *)title htmlName:(NSString *)htmlName
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _navtitle = title;
        _htmlName = htmlName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = SAMC_COLOR_LIGHTGREY;
    self.navigationItem.title = _navtitle;
    [self setupNavItem];
    
    _webView = [[UIWebView alloc] init];
    _webView.backgroundColor = SAMC_COLOR_LIGHTGREY;
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_webView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_webView)]];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:_htmlName ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)setupNavItem
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(onDone:)];
    self.navigationItem.rightBarButtonItem.tintColor = SAMC_COLOR_INGRABLUE;
}

- (void)onDone:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
