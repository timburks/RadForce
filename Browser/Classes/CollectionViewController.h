//
//  CollectionViewController.h
//  GoNative
//
//  Created by Tim Burks on 11/16/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UITableViewController
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSString *entityName;
@property (nonatomic, strong) NSDictionary *schema;
@end
