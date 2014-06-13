//
//  ViewController.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import "ViewController.h"
#import "AssetLoaderViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // navigation will be by segue
    if ([[segue destinationViewController] isKindOfClass:[AssetLoaderViewController class]]) {
        AssetLoaderViewController *assetLoader = (AssetLoaderViewController *)[segue destinationViewController];
        [assetLoader setMaxSize:320];   // only load images up to 320 pixels in width or height (longer side = 320 px)
        [assetLoader setCancelBlock:^{
            // display message that the user canceled
            self.statusLabel.text = NSLocalizedString(@"User cancelled", @"Message displayed if the user cancelled picking an image");
            [self.spinner stopAnimating];
        }];
        [assetLoader setFinishBlock:^(CGImageRef image) {
            // display message that the user picked an image and the picked image
            self.imagePreview.image = [UIImage imageWithCGImage:image];
            self.statusLabel.text = NSLocalizedString(@"User picked image", @"Message displayed if the user picked an image");
            [self.spinner stopAnimating];
        }];
    }
}

@end
