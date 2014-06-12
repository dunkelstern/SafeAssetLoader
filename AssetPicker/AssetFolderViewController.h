//
//  AssetFolderViewController.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetFolderViewController : UITableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)init;

@property (nonatomic, copy) void (^finishBlock)(CGImageRef image);
@property (nonatomic, copy) void (^cancelBlock)(void);
@property (nonatomic, assign) CGFloat maxSize;

@end
