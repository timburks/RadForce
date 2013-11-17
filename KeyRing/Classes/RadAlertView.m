//
//  RadAlertView.m
//
//  Created by Tim Burks on 09/24/11
//  Copyright 2011 Radtastical Inc. All rights reserved.
//

#import "RadAlertView.h"

static NSMutableArray *alerts;

@implementation RadAlertView
@synthesize _alertView_clickedButtonAtIndex = _alertView_clickedButtonAtIndex;

+ (RadAlertView *) alertWithTitle:(NSString *)title 
                          message:(NSString *)message 
                cancelButtonTitle:(NSString *)cancelButtonTitle 
                otherButtonTitles:(NSString *)otherButtonTitles, ... {
    RadAlertView *alert = [[RadAlertView alloc] initWithTitle:title 
                                                      message:message 
                                                     delegate:nil 
                                            cancelButtonTitle:cancelButtonTitle 
                                            otherButtonTitles:nil];
    if (!alerts) {
        alerts = [NSMutableArray array];
    }
    [alerts addObject:alert];
    if (alert) {
        alert.delegate = alert;
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
        {
            [alert addButtonWithTitle:arg];
        }
        va_end(args); 
    }
    return alert;
}

+ (void) dismissAllAlerts
{
    for (RadAlertView *alert in alerts) {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
    }
    [alerts removeAllObjects];
}

- (void) dealloc {
    self._alertView_clickedButtonAtIndex = nil;
}

#pragma mark UIAlertView delegate methods

- (void)alertView:(RadAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {    
    if (self._alertView_clickedButtonAtIndex) {
        self._alertView_clickedButtonAtIndex(alertView, buttonIndex);
    }
}

@end