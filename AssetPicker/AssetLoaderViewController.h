//
//  AssetLoaderViewController.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

@import UIKit;
@import AssetsLibrary;

@interface AssetLoaderViewController : UINavigationController

/** @brief initializer to initialize from XIB or Storyboard
 *
 *  @param[in] aDecoder the decoder
 *  @returns initialized instance of AssetLoaderViewController
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/** @brief initializer for plain initialization
 *
 *  @returns initialized instance of AssetLoaderViewController
 */
- (instancetype)init;

/** @brief finish block that is called if an asset was loaded successfully
 *  @param image the CGImage that has been loaded, valid until end of block
 */
@property (nonatomic, copy) void (^finishBlock)(CGImageRef image);

/** @brief cancel block that is called if the user cancelled the image picker */
@property (nonatomic, copy) void (^cancelBlock)(void);

/** @brief maximum length of long side of the asset, other side is scaled in aspect */
@property (nonatomic, assign) CGFloat maxSize;

@end
