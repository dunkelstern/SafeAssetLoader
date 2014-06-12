//
//  AssetFolderViewController.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 05.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

@import AssetsLibrary;

#import "AssetFolderViewController.h"
#import "AssetImageListViewController.h"

@interface AssetFolderViewController () {
    ALAssetsLibrary *assetsLibrary;
    NSMutableArray *assetGroups;
    NSLock *assetGroupsLock;
}

@end

@implementation AssetFolderViewController

- (void)setup {
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    assetGroupsLock = [[NSLock alloc] init];
    assetGroupsLock.name = @"assetGroupsLock";

    assetGroups = [NSMutableArray array];
    [self loadAssetGroups:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error while accessing Assets Library", @"Error message title displayed when accessing Assets Library fails")
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok button tile")
                                              otherButtonTitles:nil];
        [alert show];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:ALAssetsLibraryChangedNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [self loadAssetGroups:nil];
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
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALAssetsLibraryChangedNotification object:nil];
}

- (void)viewDidLoad {
    if (self.storyboard) return;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelPressed:)];
    self.navigationItem.title = NSLocalizedString(@"Select Album", @"Title of album selector view");
    self.navigationItem.backBarButtonItem.title = NSLocalizedString(@"Albums", @"Title of album selector back button");
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AssetFolderCell"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[AssetImageListViewController class]]) {
        AssetImageListViewController *imageLib = (AssetImageListViewController *)[segue destinationViewController];
        [self setupImageList:imageLib forGroup:assetGroups[self.tableView.indexPathForSelectedRow.row]];
    }
}

#pragma mark - UI Actions
- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.cancelBlock) self.cancelBlock();
    }];
}

#pragma mark - Tableview Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count;
    [assetGroupsLock lock];
    count = [assetGroups count];
    [assetGroupsLock unlock];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssetFolderCell" forIndexPath:indexPath];

    [assetGroupsLock lock];
    ALAssetsGroup *group = assetGroups[indexPath.row];
    cell.imageView.image = [UIImage imageWithCGImage:group.posterImage];
    cell.textLabel.text = [group valueForProperty:@"ALAssetsGroupPropertyName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d photos", @"Subtitle of Assets Library Group displaying number of photos contained"), group.numberOfAssets];
    [assetGroupsLock unlock];

    return cell;
}

#pragma mark - Tableview Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.storyboard) return;

    AssetImageListViewController *imageLib = [[AssetImageListViewController alloc] init];
    [self setupImageList:imageLib forGroup:assetGroups[indexPath.row]];
    [self.navigationController pushViewController:imageLib animated:YES];
}

#pragma mark - Internal

- (void)setupImageList:(AssetImageListViewController *)controller forGroup:(ALAssetsGroup *)group {
    [assetGroupsLock lock];
    [controller setGroup:group];
    [controller setFinishBlock:self.finishBlock];
    [controller setMaxSize:self.maxSize];
    [assetGroupsLock unlock];
}

- (void)loadAssetGroups:(void (^)(NSError *error))failureBlock {
    [assetGroupsLock lock];
    [assetGroups removeAllObjects];
    [assetGroupsLock unlock];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [assetGroupsLock lock];
            [assetGroups addObject:group];
            [assetGroupsLock unlock];
        } else {
            // group == nil -> last item
            [assetGroupsLock lock];
            [assetGroupsLock unlock];
            [self.tableView reloadData]; // may fail because view not loaded, intended to do so
        }
    } failureBlock:failureBlock];
}

@end
