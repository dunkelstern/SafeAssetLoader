//
//  AssetLoaderViewController.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import "AssetLoaderViewController.h"
#import "AssetFolderViewController.h"

@implementation AssetLoaderViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (instancetype)init {
    AssetFolderViewController *folderViewController = [[AssetFolderViewController alloc] init];
    self = [super initWithRootViewController:folderViewController];
    if (self) {
    }
    return self;
}

#pragma mark - Setter

- (void)setCancelBlock:(void (^)(void))cancelBlock {
    _cancelBlock = cancelBlock;
    AssetFolderViewController *root = (AssetFolderViewController *)self.viewControllers[0];
    [root setCancelBlock:self.cancelBlock];
}

- (void)setFinishBlock:(void (^)(CGImageRef))finishBlock {
    _finishBlock = finishBlock;
    AssetFolderViewController *root = (AssetFolderViewController *)self.viewControllers[0];
    [root setFinishBlock:finishBlock];
}

- (void)setMaxSize:(CGFloat)maxSize {
    _maxSize = maxSize;
    AssetFolderViewController *root = (AssetFolderViewController *)self.viewControllers[0];
    [root setMaxSize:maxSize];
}

@end
