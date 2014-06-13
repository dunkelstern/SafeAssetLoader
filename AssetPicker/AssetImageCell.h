//
//  AssetImageCell.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetImageCell : UICollectionViewCell

/** @brief image view of the cell, fills the cell, stretches the image */
@property (weak, nonatomic) IBOutlet UIImageView *image;

/** @brief initializer to initialize from XIB or Storyboard
 *
 *  @param[in] aDecoder the decoder
 *  @returns initialized instance of AssetImageCell
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/** @brief initializer for plain initialization
 *
 *  @returns initialized instance of AssetImageCell
 */
- (instancetype)initWithFrame:(CGRect)frame;

@end
