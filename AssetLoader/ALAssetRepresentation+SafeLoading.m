//
//  ALAssetRepresentation+SafeLoading.m
//  AssetLibraryExample
//
//  Created by Johannes Schriewer on 12.06.14.
//  Copyright (c) 2014 Johannes Schriewer. All rights reserved.
//

#import "ALAssetRepresentation+SafeLoading.h"

@import ImageIO;
@import CoreImage;

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *representation = (__bridge id)info;

    NSError *error = nil;
    size_t bytes = [representation getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];

    if (bytes == 0 && error) {
        NSLog(@"Error while reading asset: %@", error);
    }

    return bytes;
}

static void releaseAssetCallback(void *info) {
    CFRelease(info);
}

@implementation ALAssetRepresentation (SafeLoading)

- (CGImageRef)loadImageOfSize:(CGFloat)maxLongSide CF_RETURNS_RETAINED {
    CGSize originalImageSize = CGSizeMake([self.metadata[@"PixelWidth"] floatValue], [self.metadata[@"PixelHeight"] floatValue]);
    CGImageRef img;

    // just correct EXIF-Rotation and resize image if needed
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };

    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(self), [self size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);

    NSDictionary *options;
    if (maxLongSide != 0.0) {
        if (self.metadata[@"AdjustmentXMP"]) {
            CGSize croppedImageSize  = self.dimensions;
            CGFloat cropToMaxSize = MIN(maxLongSide / croppedImageSize.width * originalImageSize.width, maxLongSide / croppedImageSize.height * originalImageSize.height);
            options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                        (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(cropToMaxSize),
                        (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                        };
        } else {
            options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                        (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(maxLongSide),
                        (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                        };
        }
    } else {
        options = @{(NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                    (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                    };
    }
    img = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)options);
    CFRelease(source);
    CFRelease(provider);


    if (self.metadata[@"AdjustmentXMP"]) {
        // some things have been done to this image in photos.app
        CGImageRef newImg = [self applyXMPAdjustment:img xmp:self.metadata[@"AdjustmentXMP"] maxSize:maxLongSide originalSize:originalImageSize];
        CGImageRelease(img);
        img = newImg;
    }

    return img;
}


- (CGImageRef)applyXMPAdjustment:(CGImageRef)rawImage xmp:(NSString *)xmpString maxSize:(CGFloat)maxSize originalSize:(CGSize)originalImageSize CF_RETURNS_RETAINED {
    NSData *xmpData = [xmpString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    CIContext *context;

    // try hardware first
    EAGLContext *myEAGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    context = [CIContext contextWithEAGLContext:myEAGLContext options:@{ kCIContextWorkingColorSpace : [NSNull null] }];

    // check if we can render the image on hardware
    CGSize maxGPUImageSize = [context inputImageMaximumSize];
    if ((maxGPUImageSize.width < CGImageGetWidth(rawImage)) || (maxGPUImageSize.height < CGImageGetHeight(rawImage))) {
        context = nil;
    }

    // fallback to software renderer
    if (!context) {
        context = [CIContext contextWithOptions:@{ kCIContextUseSoftwareRenderer : @YES }];
    }

    // if we have no context here, bail out
    if (!context) {
        CGImageRetain(rawImage);
        return rawImage;
    }

    CIImage *image = [CIImage imageWithCGImage:rawImage];

    NSMutableArray *filterArray = [[CIFilter filterArrayFromSerializedXMP:xmpData
                                                         inputImageExtent:image.extent
                                                                    error:&error] mutableCopy];
    // something went wrong while initializing filters?
    if (!filterArray) {
        NSLog(@"Error during CIFilter creation: %@", error);
        CGImageRetain(rawImage);
        return rawImage;
    }

    // add scaling filters
    if (maxSize > 0.0) {
        if ((originalImageSize.width != CGImageGetWidth(rawImage)) || (originalImageSize.height != CGImageGetHeight(rawImage))) {
            CGFloat zoom = MIN(originalImageSize.width / CGImageGetWidth(rawImage), originalImageSize.height / CGImageGetHeight(rawImage));
            BOOL translationFound = NO, cropFound = NO;
            for (CIFilter *filter in filterArray) {
                if ([filter.name isEqualToString:@"CIAffineTransform"] && !translationFound) {
                    translationFound = YES;
                    CGAffineTransform t = [(NSValue *)[filter valueForKey:@"inputTransform"] CGAffineTransformValue];
                    t.tx /= zoom;
                    t.ty /= zoom;
                    [filter setValue:[NSValue valueWithCGAffineTransform:t] forKey:@"inputTransform"];
                }
                if ([filter.name isEqualToString:@"CICrop"] && !cropFound) {
                    cropFound = YES;
                    CGRect r = [(NSValue *)[filter valueForKey:@"inputRectangle"] CGRectValue];
                    r.origin.x /= zoom;
                    r.origin.y /= zoom;
                    r.size.width /= zoom;
                    r.size.height /= zoom;
                    [filter setValue:[NSValue valueWithCGRect:r] forKey:@"inputRectangle"];
                }
            }
        }
    }

    // filter chain
    for (CIFilter *filter in filterArray) {
        [filter setValue:image forKey:kCIInputImageKey];
        image = [filter outputImage];
    }

    // render
    CGImageRef editedImage = [context createCGImage:image fromRect:image.extent];

    // return
    if (!editedImage) {
        CGImageRetain(rawImage);
        return rawImage;
    } else {
        return editedImage;
    }
}

@end
