//
//  OAuthSignInViewController.m
//  GoNative
//
//  Created by Tim Burks on 11/3/13.
//  Copyright (c) 2013 Radtastical Inc Inc. All rights reserved.
//

#import "OAuthSignInViewController.h"
#import "RadHTTPHelpers.h"
#import "AccountManager.h"
#import "RadAlertView.h"

@interface OAuthSignInViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation OAuthSignInViewController

- (void) loadView
{
    [super loadView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Cancel"
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(cancel:)];
    self.view.backgroundColor = [UIColor redColor];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth+UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void) cancel:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// consumer key
static NSString *consumer_key = @"";

// callback url
static NSString *callback_url = @"mysampleapp://auth/success";

- (void) viewWillAppear:(BOOL)animated
{
    id requester = [[AccountManager sharedInstance].query objectForKey:@"requester"];
    NSString *consumerKey = [requester objectForKey:@"consumer key"];
    
    if (!consumerKey) {
        // if none was provided, use this one for demonstration purposes.
        consumerKey = consumer_key;
    }
    
    NSString *path = @"https://login.salesforce.com/services/oauth2/authorize?";
    
    NSDictionary *arguments = @{@"response_type":@"token",
                                @"client_id":consumerKey,
                                @"redirect_uri":callback_url,
                                @"state":@"dreamy"};
    path = [path stringByAppendingString:[arguments rad_URLQueryString]];
    NSLog(@"PATH: %@", path);
    NSURL *URL = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [self.webView loadRequest:request];
}

- (BOOL)            webView:(UIWebView *)webView
 shouldStartLoadWithRequest:(NSURLRequest *)request
             navigationType:(UIWebViewNavigationType)navigationType
{
    id requester = [[AccountManager sharedInstance].query objectForKey:@"requester"];
    
    NSLog(@"loading %@", [request.URL absoluteString]);
    NSLog(@"METHOD: %@", [request HTTPMethod]);
    NSLog(@"URL: %@", [request URL]);
    
    NSString *path = [[request URL] absoluteString];
    NSArray *parts = [path componentsSeparatedByString:@"#"];
    NSString *base = [parts objectAtIndex:0];
    if ([base isEqualToString:callback_url]) {
        NSLog(@"RESPONSE HERE");
        NSString *queryString = [parts objectAtIndex:1];
        NSDictionary *query = [queryString rad_URLQueryDictionary];
        NSLog(@"QUERY %@", query);
        NSString *accessToken = [query objectForKey:@"access_token"];
        NSLog(@"ACCESS TOKEN: %@", accessToken);
        
        RadAlertView *alert = [RadAlertView
                               alertWithTitle:@"Your Access Token"
                               message:accessToken
                               cancelButtonTitle:@"Great, thanks!"
                               otherButtonTitles:nil];
        [alert show];
        
        [self dismissViewControllerAnimated:YES completion:^{
            id scheme = [requester objectForKey:@"scheme"];
            if (scheme && accessToken) {
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:
                  [NSString stringWithFormat:@"%@:?%@",
                   scheme,
                   queryString]]];
            }
        }];
        return NO;
    }
#ifdef PASSWORD_SPY
    else if ([base isEqualToString:@"https://login.salesforce.com/"] &&
             [[request HTTPMethod] isEqualToString:@"POST"]) {
        
        NSLog(@"HEADERS: %@", [request allHTTPHeaderFields]);
        if ([[request HTTPMethod] isEqualToString:@"POST"]) {
            NSData *data = [request HTTPBody];
            NSLog(@"POST LENGTH: %d", (int) [data length]);
            NSDictionary *post = [data rad_URLQueryDictionary];
            NSLog(@"POST DICTIONARY: %@", post);
            
            NSString *username = [post objectForKey:@"username"];
            NSString *password = [post objectForKey:@"pw"];
            RadAlertView *alert =
            [RadAlertView alertWithTitle:@"I spy"
                                 message:[NSString stringWithFormat:@"your username (%@) and password (%@).",
                                          username,
                                          password]
                       cancelButtonTitle:@"This is not cool."
                       otherButtonTitles:nil];
            [alert show];
        }
    }
#endif
    return YES;
}

@end
