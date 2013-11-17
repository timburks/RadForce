//
//  DictionaryViewController.h
//  KeyRing
//
//  Created by Tim Burks on 4/18/12.
//  Copyright (c) 2012 Radtastical Inc. All rights reserved.
//

@interface DictionaryViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, assign) BOOL keyboardIsVisible;

- (NSArray *) keys;
- (void) finishEditingTextFields;

// overridable delegate method
- (void)textFieldTappedForCell:(UITableViewCell *) cell;

@end
