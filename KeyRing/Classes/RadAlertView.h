//
//  RadAlertView.h
//
//  Created by Tim Burks on 09/24/11
//  Copyright 2011 Radtastical Inc. All rights reserved.
//

@interface RadAlertView : UIAlertView
@property (nonatomic, copy) void (^_alertView_clickedButtonAtIndex)(RadAlertView *, NSInteger);

+ (id) alertWithTitle:(NSString *) title
              message:(NSString *) message
    cancelButtonTitle:(NSString *) cancelButtonTitle
    otherButtonTitles:(NSString *) otherButtonTitles, ...;

+ (void) dismissAllAlerts;

@end
