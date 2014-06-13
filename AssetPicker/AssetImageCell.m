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
        // all done in storyboard, do not forget to connect self.image to anything on storyboard
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // just setup single image cell that fills the cell and resizes with the cell
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:image];
        self.image = image;
        [image setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

        // stretch the supplied image to fit
        [image setContentMode:UIViewContentModeScaleToFill];
    }
    return self;
}

@end
