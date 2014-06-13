//
//  ALAssetRepresentation+SafeLoading.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 12.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

@import AssetsLibrary;

@interface ALAssetRepresentation (SafeLoading)

/** @brief load the asset representation in reduced size to save RAM
 *
 *  @param[in] maxLongSide maximum length of the long side of the asset
 *  @returns new CGImageRef with loaded asset, all EXIF and XMP adjustments
 *           applied in upright rotation. Image has to be freed by caller.
 */
- (CGImageRef)loadImageOfSize:(CGFloat)maxLongSide CF_RETURNS_RETAINED;
@end

@interface NSDictionary (AssetLoading)
/** @brief calculate the size of the original asset from a metadata dictionary
 *
 *  @returns pixel size of the asset this dictionary belongs to after all
 *           EXIF rotations and XMP adjustments have been applied.
 */
- (CGSize)assetSize;
@end