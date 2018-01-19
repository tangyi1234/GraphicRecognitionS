//
//  TYImageDispose.m
//  IdCardRecognition
//
//  Created by 汤义 on 2018/1/9.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "TYImageDispose.h"

@implementation TYImageDispose
- (UIImage *)imageFromSampleBuffers:(CMSampleBufferRef)sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}

- (UIImage*)rotateImageWithAngle:(UIImage*)vImg Angle:(CGFloat)vAngle IsExpand:(BOOL)vIsExpand
{
    CGSize imgSize = CGSizeMake(vImg.size.width * vImg.scale, vImg.size.height * vImg.scale);
    
    CGSize outputSize = imgSize;
    if (vIsExpand) {
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        //旋转
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(vAngle*M_PI/180.0));
        
        //NSLog(@"rotateImageWithAngle, size0:%f, size1:%f", imgSize.width, rect.size.width);
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, vAngle*M_PI/180.0);
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [vImg drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
