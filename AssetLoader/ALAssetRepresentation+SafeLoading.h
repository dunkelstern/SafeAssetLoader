//
//  ALAssetRepresentation+SafeLoading.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 12.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

@import AssetsLibrary;

@interface ALAssetRepresentation (SafeLoading)

- (CGImageRef)loadImageOfSize:(CGFloat)maxLongSide CF_RETURNS_RETAINED;
@end

@interface NSDictionary (AssetLoading)
- (CGSize)assetSize;
@end