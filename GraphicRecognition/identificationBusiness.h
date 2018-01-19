//
//  identificationBusiness.h
//  opencv-facerec
//
//  Created by 汤义 on 2018/1/5.
//  Copyright © 2018年 Fifteen Jugglers Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/highgui/cap_ios.h>
@class UIImage;
typedef void (^CompleateBlock)(NSString *text);
typedef void (^imageBlock)(UIImage *img);
typedef void (^CompleateArrBlock)(NSString *text,NSString *text1);
@interface identificationBusiness : NSObject
/**
 *  初始化一个单例
 *
 *  @return 返回一个RecogizeCardManager的实例对象
 */
+ (instancetype)recognizeCardManager;

/**
 *  根据身份证照片得到身份证号码
 *
 *  @param cardImage 传入的身份证照片
 *  @param compleate 识别完成后的回调
 */
- (void)recognizeCardWithImage:(UIImage *)cardImage compleate:(CompleateBlock)compleate image:(imageBlock)image;
/**
 *  根据文字图片
 *
 *  @param cardImage 传入文字图片
 *  @param compleate 识别完成后的回调
 */
- (void)recognizeCardWithImageText:(UIImage *)cardImage compleate:(CompleateBlock)compleate image:(imageBlock)image;

- (NSArray*)opencvScanCards:(UIImage*)image;
@end
