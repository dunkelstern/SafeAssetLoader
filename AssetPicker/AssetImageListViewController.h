//
//  AssetImageListViewController.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface AssetImageListViewController : UICollectionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)init;

@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic, copy) void (^finishBlock)(CGImageRef image);
@property (nonatomic, assign) CGFloat maxSize;

@end
