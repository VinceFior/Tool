//
//  CentralTools.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/19/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef NS_ENUM(int, CommandReturn) {
    CommandReturnNothing,
    CommandReturnClose,
    CommandReturnCloseReopen,
};

@interface CentralTools : NSObject

+ (void)clearPrintedMessages;
+ (void)logMessage:(NSString *)text;
+ (void)printMessage:(NSString *)text;
+ (void)copyToClipboard:(NSString *)text;
+ (CommandReturn)runCommand:(NSString *)command withKeyword:(NSString *)keyword;
+ (void)saveStringToDesktop:(NSString *)contentString asFile:(NSString *)fileNameString;
+ (void)printHelpMessage;

@end
