//
//  TYImageDispose.h
//  IdCardRecognition
//
//  Created by 汤义 on 2018/1/9.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
@interface TYImageDispose : NSObject
- (UIImage *)imageFromSampleBuffers:(CMSampleBufferRef)sampleBuffer;
/*
 iOS UIImage 图像旋转
 vImg：待旋转的图
 vAngle：旋转角度
 vIsExpand：是否扩展，如果不扩展，那么图像大小不变，但被截掉一部分
 */
- (UIImage*)rotateImageWithAngle:(UIImage*)vImg Angle:(CGFloat)vAngle IsExpand:(BOOL)vIsExpand;
@end
