//
//  AppDelegate.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "AppDelegate.h"
#import "TextInputWindowController.h"

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) TextInputWindowController *controllerWindow;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // set up status item (icon)
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"GearIcon"];
    [_statusItem setAction:@selector(itemClicked:)];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)itemClicked:(id)sender {
    self.controllerWindow = [[TextInputWindowController alloc] initWithWindowNibName:@"TextInputWindowController"];
    [self.controllerWindow showWindow:self];
}

@end
