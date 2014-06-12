//
//  ViewController.m
//  AssetLibraryExample_Plain
//
//  Created by Johannes Schriewer on 12.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import "ViewController.h"
#import "AssetLoaderViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *previewImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation ViewController

- (instancetype)init {
    self = [super initWithNibName:@"View" bundle:nil];
    if (self) {
    }
    return self;
}

- (IBAction)loadImage:(id)sender {
    AssetLoaderViewController *assetLoader = [[AssetLoaderViewController alloc] init];
    [assetLoader setMaxSize:320];
    __weak ViewController *weakSelf = self;
    [assetLoader setCancelBlock:^{
        ViewController *strongSelf = weakSelf;
        strongSelf.statusLabel.text = NSLocalizedString(@"User cancelled", @"Message displayed if the user cancelled picking an image");
        [strongSelf.spinner stopAnimating];
    }];
    [assetLoader setFinishBlock:^(CGImageRef image) {
        ViewController *strongSelf = weakSelf;
        strongSelf.previewImage.image = [UIImage imageWithCGImage:image];
        strongSelf.statusLabel.text = NSLocalizedString(@"User picked image", @"Message displayed if the user picked an image");
        [strongSelf.spinner stopAnimating];
    }];
    [self presentViewController:assetLoader animated:YES completion:nil];
}

@end
