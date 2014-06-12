//
//  AssetImageCell.h
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssetImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (instancetype)initWithFrame:(CGRect)frame;

@end
