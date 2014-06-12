//
//  AssetImageCell.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import "AssetImageCell.h"

@implementation AssetImageCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:image];
        self.image = image;
        [image setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [image setContentMode:UIViewContentModeScaleToFill];
    }
    return self;
}

@end
