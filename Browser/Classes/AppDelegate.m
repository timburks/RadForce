//
//  AppDelegate.m
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "BrowserViewController.h"
#import "SignInViewController.h"
#import "RadHTTP.h"
#import "RadURLProtocol.h"
#import "SFConnection.h"

static NSString *consumerKey = @"";
static NSString *consumerSecret = @"";

@interface AppDelegate ()
@property (nonatomic, strong) BrowserViewController *warehouseViewController;
@property (nonatomic, strong) SignInViewController *signInViewController;
@end

@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        [NSURLProtocol registerClass:[RadURLProtocol class]];
    }
    return self;
}

#pragma mark - App delegate lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SFConnection sharedInstance]
     setConsumerKey:consumerKey secret:consumerSecret];
    [SFConnection sharedInstance].consumerName = @"Force Browser";
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.warehouseViewController = [[BrowserViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc]
                                      initWithRootViewController:self.warehouseViewController];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    self.signInViewController = [[SignInViewController alloc] init];
    [self.warehouseViewController presentViewController:self.signInViewController
                                               animated:YES
                                             completion:^{}];
    return YES;
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSArray *parts = [[url resourceSpecifier] componentsSeparatedByString:@"?"];
    if ([parts count] < 2) {
        parts = [[url resourceSpecifier] componentsSeparatedByString:@"#"];
    }
    if ([parts count] > 1) {
        NSDictionary *response = [[parts objectAtIndex:1] rad_URLQueryDictionary];
        NSLog(@"response: %@", response);
        if ([[SFConnection sharedInstance]
             finishAuthenticatingWithOAuthResponse:response]) {
            [self.warehouseViewController dismissViewControllerAnimated:YES completion:^{}];
            [self.warehouseViewController refreshContents];
        }
    }
    return YES;
}

@end
