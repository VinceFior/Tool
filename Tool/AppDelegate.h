//
//  AppDelegate.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, nonatomic) NSEvent *localEventMonitor;
@property (strong, nonatomic) NSEvent *globalEventMonitor;
@property (nonatomic) BOOL isSearchWindowOpen;
@property (strong, nonatomic) NSRunningApplication *previousApplication;

@property (strong) NSTextView *outputTextView;

- (void) restorePreviousApplication;

@end

