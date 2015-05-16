//
//  ReactionImageList.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReactionImage;

@interface ReactionImageList : NSObject

@property (strong, nonatomic) NSMutableArray *imageList; // todo: make this property private

- (ReactionImage *) getBestImageFromKeyword:(NSString *)keyword;
- (NSString *) getImageListInfo;

@end
