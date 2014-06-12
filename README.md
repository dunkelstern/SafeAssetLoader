Memory safe ALAssetsLibrary image loader implementation with example code.

For motivations of writing this category read:
http://blog.dunkelstern.de/2014/06/11/alassetslibrary-what-apple-does-not-tell/

# Usage for safe loading

The main category method for this asset loader is `ALAssetRepresentation`'s `loadImageOfSize:`

~~~objc
// outside of the implementation in the same file
@import ALAssetsLibrary;
#import "ALAssetRepresentation+SafeLoading.h"

// Usage
NSURL *assetURL;            // contains URL of the asset
CGFloat maxSize = 1000.0;   // size of image to load

ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
[lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
    ALAssetRepresentation *representation = [result defaultRepresentation];
    CGImageRef img = [representation loadImageOfSize:maxSize];
    // do something with img
    CGImageRelease(img);
} failureBlock:^(NSError *error) {
    NSLog(@"An error occured: %@", error);
}];
~~~

# Usage for asset picker

In the source code there is a reimplementation of the Apple image picker as an example to how to use the `ALAssetsLibrary` you can include that picker if you want to modify some aspect of the picker.

There are example projects using a plain view controller and just instanciating
the asset loader and one that is storyboard based. The code of the picker can do both.

~~~objc
// outside of the implementation in the same file
#import "AssetLoaderViewController.h"

// Usage
AssetLoaderViewController *assetLoader = [[AssetLoaderViewController alloc] init];

// set maximum image size to be 320 pixels on the long side
[assetLoader setMaxSize:320];
[assetLoader setCancelBlock:^{
    NSLog(@"User canceled");
}];
[assetLoader setFinishBlock:^(CGImageRef image) {
    // do something with image
}];
[self presentViewController:assetLoader animated:YES completion:nil];
~~~

# Example code

There are two projects with example code:
* AssetLibraryExample_StoryBoard : simple storyboard based example of the asset picker
* AssetLibraryExample_Plain : simple "traditional" XIB/Plain example of the asset picker

# License

Copyright (c) 2014, Johannes Schriewer <hallo@dunkelstern.de>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of the <organization> nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.