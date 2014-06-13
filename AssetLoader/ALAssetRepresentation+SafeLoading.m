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
        CGImageRef newImg = [self applyXMPAdjustment:img xmp:self.metadata[@"AdjustmentXMP"] maxSize:maxLongSide originalSize:originalImageSize orientation:self.orientation];
        CGImageRelease(img);
        img = newImg;
    }

    return img;
}


- (CGImageRef)applyXMPAdjustment:(CGImageRef)rawImage xmp:(NSString *)xmpString maxSize:(CGFloat)maxSize originalSize:(CGSize)originalImageSize orientation:(ALAssetOrientation)orientation CF_RETURNS_RETAINED {
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
                    [filter setValue:[NSValue valueWithCGRect:CGRectIntegral(r)] forKey:@"inputRectangle"];
                }
            }
        }
    }

    CGAffineTransform transform = CGAffineTransformIdentity;

    // fix exif transform
    switch (orientation) {
        case ALAssetOrientationDown:
        case ALAssetOrientationDownMirrored:
            transform = CGAffineTransformMakeRotation(M_PI);
            break;

        case ALAssetOrientationLeft:
        case ALAssetOrientationLeftMirrored:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;

        case ALAssetOrientationRight:
        case ALAssetOrientationRightMirrored:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;

        case ALAssetOrientationUp:
        case ALAssetOrientationUpMirrored:
        default:
            // no rotation
            break;
    }

    // fix exif mirror
    switch (orientation) {

        case ALAssetOrientationDownMirrored:
        case ALAssetOrientationLeftMirrored:
        case ALAssetOrientationRightMirrored:
        case ALAssetOrientationUpMirrored:
            // mirror image
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case ALAssetOrientationDown:
        case ALAssetOrientationLeft:
        case ALAssetOrientationRight:
        case ALAssetOrientationUp:
        default:
            // no mirroring
            break;
    }

    // if we calculated a transform, add a filter to the chain
    if (!CGAffineTransformIsIdentity(transform)) {
        CIFilter *transformFilter = [CIFilter filterWithName:@"CIAffineTransform"];
        [transformFilter setValue:[NSValue valueWithCGAffineTransform:transform] forKey:@"inputTransform"];
        [filterArray addObject:transformFilter];
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

@implementation NSDictionary (AssetLoading)

- (CGSize)assetSize {
    // fetch EXIF rotation
    ALAssetOrientation orientation = [self[(NSString *)kCGImagePropertyOrientation] integerValue];

    // fetch pixel size
    CGSize assetSize = CGSizeMake([self[@"PixelWidth"] floatValue], [self[@"PixelHeight"] floatValue]);

    // check if XMP adjustment is neccessary
    if (self[@"AdjustmentXMP"]) {
        NSError *error;
        NSData *xmpData = [self[@"AdjustmentXMP"] dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                     inputImageExtent:CGRectMake(0, 0, assetSize.width, assetSize.height)
                                                                error:&error];
        if (!filterArray) {
            NSLog(@"Could not create filter array: %@", error);
        }

        // find crop filters in filter array as they change the size
        for (CIFilter *filter in filterArray) {
            if ([filter.name isEqualToString:@"CICrop"]) {
                CGRect r = [(NSValue *)[filter valueForKey:@"inputRectangle"] CGRectValue];
                assetSize = r.size;
            }
        }
    }

    // fix exif transform
    switch (orientation) {
        case ALAssetOrientationLeft:
        case ALAssetOrientationLeftMirrored:
        case ALAssetOrientationRight:
        case ALAssetOrientationRightMirrored: {
            CGFloat tmp = assetSize.width;
            assetSize.width = assetSize.height;
            assetSize.height = tmp;
            break;
        }

        case ALAssetOrientationUp:
        case ALAssetOrientationUpMirrored:
        case ALAssetOrientationDown:
        case ALAssetOrientationDownMirrored:
        default:
            // no rotation
            break;
    }
    return assetSize;
}

@end
