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

/** @brief initializer to initialize from XIB or Storyboard
 *
 *  @param[in] aDecoder the decoder
 *  @returns initialized instance of AssetImageListViewController
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/** @brief initializer for plain initialization
 *
 *  @returns initialized instance of AssetImageListViewController
 */
- (instancetype)init;

/** @brief the asset group this view controller acts on */
@property (nonatomic, strong) ALAssetsGroup *group;

/** @brief finish block that is called if an asset was loaded successfully
 *  @param image the CGImage that has been loaded, valid until end of block
 */
@property (nonatomic, copy) void (^finishBlock)(CGImageRef image);

/** @brief maximum length of long side of the asset, other side is scaled in aspect */
@property (nonatomic, assign) CGFloat maxSize;

@end
