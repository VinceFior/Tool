//
//  AppDelegate.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "AppDelegate.h"
#import "TextInputWindowController.h"
#import "FileManager.h"
#include <Carbon/Carbon.h> // for key codes

@interface AppDelegate ()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) TextInputWindowController *controllerWindow;

@end

@implementation AppDelegate

#pragma mark - Public methods

- (void)restorePreviousApplication {
    [self.previousApplication activateWithOptions:NSApplicationActivateIgnoringOtherApps];
}

#pragma mark - Private methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.isSearchWindowOpen = false;
    
    // set up status item (icon)
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"GearIcon"];
    [_statusItem setAction:@selector(itemClicked:)];
    
    [self setUpShortcuts];
    
    // set up file manager
    [FileManager sharedManager];
}

- (void)setUpShortcuts {
    // TODO: use CGEventTapCreate() to block the event from other applications.
    //       see http://stackoverflow.com/a/4754241/1976584
    
    void (^monitorHandlerGlobal)(NSEvent *);
    monitorHandlerGlobal = ^(NSEvent *theEvent){
        const int cmdKeyModifier = 1 << 20; // holding down the Command key
        const int keycode = kVK_ANSI_Backslash; // pressing the '\' key
        if (([theEvent modifierFlags] & cmdKeyModifier) && [theEvent keyCode] == keycode) {
            self.previousApplication = [[NSWorkspace sharedWorkspace] frontmostApplication];
            
            [NSApp activateIgnoringOtherApps:YES]; // bring app to front
            [self openSearchWindow];
            [NSApp activateIgnoringOtherApps:NO]; // reset flag (just in case; this seems okay)
        }
    };
    
    NSEvent *(^monitorHandlerLocal)(NSEvent *);
    monitorHandlerLocal = ^NSEvent *(NSEvent *theEvent) {
        monitorHandlerGlobal(theEvent);
        return theEvent;
    };
    
    self.localEventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
                                                                   handler:monitorHandlerLocal];
    self.globalEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask
                                                                     handler:monitorHandlerGlobal];
    
    if (!AXIsProcessTrusted()) {
        NSLog(@"Application has not been given accessibility trust and cannot use keyboard shortcuts.");
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)itemClicked:(id)sender {
    [self openSearchWindow];
}

- (void)openSearchWindow {
    if (self.isSearchWindowOpen) {
        // just bring window to the front
        [self.controllerWindow.window orderFrontRegardless];
    } else {
        self.isSearchWindowOpen = true;
        // Note: We (currently) never set isSearchWindowOpen to false, but the window seems to stick
        // around even after the user presses the 'x' button, so this works.
        self.controllerWindow = [[TextInputWindowController alloc] initWithWindowNibName:@"TextInputWindowController"];
        [self.controllerWindow showWindow:self];
    }
}

@end
