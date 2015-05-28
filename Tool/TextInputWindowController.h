//
//  TextInputWindowController.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextInputWindowController : NSWindowController

@property (assign) IBOutlet NSSearchField *searchField;
@property (assign) IBOutlet NSTextView *textView;

- (IBAction)searchEntered:(id)sender;

@end
