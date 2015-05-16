//
//  ReactionImage.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReactionImage : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *title;
@property (nonatomic) BOOL animated;

- (double) getKeywordScore:(NSString *)keyword;
- (NSString *) getInfo;

@end
