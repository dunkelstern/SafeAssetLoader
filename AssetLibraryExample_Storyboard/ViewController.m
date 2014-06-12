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
    if ([[segue destinationViewController] isKindOfClass:[AssetLoaderViewController class]]) {
        AssetLoaderViewController *assetLoader = (AssetLoaderViewController *)[segue destinationViewController];
        [assetLoader setMaxSize:320];
        [assetLoader setCancelBlock:^{
            self.statusLabel.text = NSLocalizedString(@"User cancelled", @"Message displayed if the user cancelled picking an image");
            [self.spinner stopAnimating];
        }];
        [assetLoader setFinishBlock:^(CGImageRef image) {
            self.imagePreview.image = [UIImage imageWithCGImage:image];
            self.statusLabel.text = NSLocalizedString(@"User picked image", @"Message displayed if the user picked an image");
            [self.spinner stopAnimating];
        }];
    }
}

@end
