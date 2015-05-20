//
//  CentralTools.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/19/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface CentralTools : NSObject

+ (void)printMessage:(NSString *)text;
+ (void)copyToClipboard:(NSString *)text;
+ (BOOL)runCommand:(NSString *)command withKeyword:(NSString *)keyword;
+ (void)saveStringToDesktop:(NSString *)contentString asFile:(NSString *)fileNameString;

@end
