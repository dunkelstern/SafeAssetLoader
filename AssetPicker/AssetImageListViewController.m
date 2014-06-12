//
//  AssetImageListViewController.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

@import AssetsLibrary;

#import "ALAssetRepresentation+SafeLoading.h"
#import "AssetImageListViewController.h"
#import "AssetImageCell.h"

@implementation AssetImageListViewController

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserverForName:ALAssetsLibraryChangedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.collectionView reloadData];
                                                  }];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(75, 75);

    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        [self setup];
        [self.collectionView registerClass:[AssetImageCell class] forCellWithReuseIdentifier:@"AssetCell"];
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)viewDidLoad {
    self.navigationItem.title = [self.group valueForProperty:@"ALAssetsGroupPropertyName"];
}

#pragma mark - Setter

- (void)setGroup:(ALAssetsGroup *)group {
    if (group != _group) {
        _group = group;
        self.navigationItem.title = [self.group valueForProperty:@"ALAssetsGroupPropertyName"];
        [self.collectionView reloadData];
    }
}

#pragma mark - CollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.group numberOfAssets];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    assert([cell isKindOfClass:[AssetImageCell class]]);
    AssetImageCell *imageCell = (AssetImageCell *)cell;
    [self.group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item]
                                 options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                     if (result) {
                                         CGImageRef thumbnail = [result thumbnail];
                                         imageCell.image.image = [UIImage imageWithCGImage:thumbnail scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
                                     }
                                 }];
    return cell;
}

#pragma mark - CollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath.item]
                                 options:0
                              usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                  if (result) {
                                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                          ALAssetRepresentation *representation = [result defaultRepresentation];

                                          CGImageRef img = [representation loadImageOfSize:self.maxSize];
                                          if (self.finishBlock) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  self.finishBlock(img);
                                                  CGImageRelease(img);
                                              });
                                          } else {
                                              CGImageRelease(img);
                                          }
                                      });
                                  }
                              }];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
