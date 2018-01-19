//
//  identificationBusiness.m
//  opencv-facerec
//
//  Created by 汤义 on 2018/1/5.
//  Copyright © 2018年 Fifteen Jugglers Software. All rights reserved.
//

#import "identificationBusiness.h"
#import <opencv2/highgui/cap_ios.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/highgui/ios.h>
#import <TesseractOCR/TesseractOCR.h>
#import "Imageprocess.h"
#import "publicClass.h"
//#ifdef __cplusplus
//#import <opencv2/opencv.hpp>
//#endif
@interface identificationBusiness()
@property (nonatomic, assign) BOOL Enter;
@end

@implementation identificationBusiness
+ (instancetype)recognizeCardManager {
    static identificationBusiness *recognizeCardManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recognizeCardManager = [[identificationBusiness alloc] init];
    });
    return recognizeCardManager;
}

- (void)recognizeCardWithImage:(UIImage *)cardImage compleate:(CompleateBlock)compleate image:(imageBlock)image{
    
    //利用TesseractOCR识别文字
    if (_Enter == NO ) {
        _Enter = YES;
        //扫描身份证图片，并进行预处理，定位号码区域图片并返回
        //去灯光阴影
        UIImage *lightImage = [self getRidShadow:cardImage];
//        image(lightImage);
        UIImage *numberImage = [self opencvScanCard:lightImage];
        image(numberImage);
        if (numberImage == nil) {
            compleate(nil);
            NSLog(@"没有图片");
            _Enter = NO;
            return;
        }
        [self tesseractRecognizeImage:numberImage compleate:^(NSString *numbaerText) {
            _Enter = NO;
            compleate(numbaerText);
        }];
    }
    
}

- (void)recognizeCardWithImageText:(UIImage *)cardImage compleate:(CompleateBlock)compleate image:(imageBlock)image{
    
    //利用TesseractOCR识别文字
    if (_Enter == NO ) {
        _Enter = YES;
        //扫描身份证图片，并进行预处理，定位号码区域图片并返回
        //去灯光阴影
        UIImage *lightImage = [self getRidShadow:cardImage];
        //        image(lightImage);
        UIImage *numberImage = [self opencvScanCard:lightImage];
        image(numberImage);
        if (numberImage == nil) {
            compleate(nil);
            NSLog(@"没有图片");
            _Enter = NO;
            return;
        }
        [self tesseractRecognizeImageText:numberImage compleate:^(NSString *numbaerText) {
            _Enter = NO;
            compleate(numbaerText);
        }];
    }
    
}

//扫描身份证图片，并进行预处理，定位号码区域图片并返回
- (UIImage *)opencvScanCard:(UIImage *)image {
    //将UIImage转换成Mat
    cv::Mat resultImage;
    UIImageToMat(image, resultImage);
    //转为灰度图(最后一个参数的使用，是用来最后处理成什么颜色)
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);//COLOR_BGR2GRAY COLOR_BGR2HSV
//    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    //利用阈值二值化
    cv::threshold(resultImage, resultImage, 100, 255, CV_THRESH_BINARY);
    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    //腐蚀，填充（腐蚀是让黑色点变大）cv::Size(6,6)黑线粗细数值越大粗点越大
    cv::Mat erodeElement = getStructuringElement(cv::MORPH_RECT, cv::Size(6,6),cv::Point(0, 0));
    cv::erode(resultImage, resultImage, erodeElement);
    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    //轮廊检测
    std::vector<std::vector<cv::Point>> contours;//定义一个容器来存储所有检测到的轮廊
    ////findContours注释[self findContoursAnnotation];
    cv::findContours(resultImage, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
//    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    //取出身份证号码区域
    std::vector<cv::Rect> rects;
    cv::Rect numberRect = cv::Rect(0,0,0,0);
    /*
     begin
     语法：iterator begin();
     解释：begin()函数返回一个迭代器,指向字符串的第一个元素.
     end
     语法：iterator end();
     解释：end()函数返回一个迭代器，指向字符串的末尾(最后一个字符的下一个位置).
     */
    std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
    for ( ; itContours != contours.end(); ++itContours) {
        cv::Rect rect = cv::boundingRect(*itContours);
        printf("阈值：%d\n numberRect数据是什么:%d\n rect高度:%d\n",rect.width,numberRect.width,rect.height);
        rects.push_back(rect);
        //算法原理
        if (rect.width > numberRect.width && rect.width > rect.height * 5) {
            numberRect = rect;
        }
        
//        if (rect.width == 1594) {
//            numberRect = rect;
//        }
    }
    //身份证号码定位失败
    if (numberRect.width == 0 || numberRect.height == 0) {
        return nil;
    }
    //定位成功成功，去原图截取身份证号码区域，并转换成灰度图、进行二值化处理
    cv::Mat matImage;
    UIImageToMat(image, matImage);
    resultImage = matImage(numberRect);
    //将Mat转换成UIImage
//    UIImage *numberImage = MatToUIImage(resultImage);
//    return numberImage;
    cvtColor(resultImage, resultImage, cv::COLOR_BGR2GRAY);
    cv::threshold(resultImage, resultImage, 80, 255, CV_THRESH_BINARY);
    //将Mat转换成UIImage
    UIImage *numberImage = MatToUIImage(resultImage);
    return numberImage;
}



//利用TesseractOCR识别身份证
- (void)tesseractRecognizeImage:(UIImage *)image compleate:(CompleateBlock)compleate {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"正在进行识别");
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
        tesseract.image = [image g8_blackAndWhite];
        tesseract.image = image;
        // Start the recognition
        [tesseract recognize];
        //执行回调
        compleate(tesseract.recognizedText);
    });
}

//利用TesseractOCR识别文字
- (void)tesseractRecognizeImageText:(UIImage *)image compleate:(CompleateBlock)compleate {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"正在进行识别");
        G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"chi_sim"];
        tesseract.image = [image g8_blackAndWhite];
        tesseract.image = image;
        // Start the recognition
        [tesseract recognize];
        //执行回调
        compleate(tesseract.recognizedText);
    });
}

- (UIImage *)getRidShadow:(UIImage *)img {
         cv::Mat g_srcImage,dstImage;
         UIImageToMat(img, g_srcImage);
         std::vector<cv::Mat> g_vChannels;
    
         //分离通道
         split(g_srcImage,g_vChannels);
         cv::Mat imageBlueChannel = g_vChannels.at(0);
         cv::Mat imageGreenChannel = g_vChannels.at(1);
         cv::Mat imageRedChannel = g_vChannels.at(2);
    
         double imageBlueChannelAvg=0;
         double imageGreenChannelAvg=0;
         double imageRedChannelAvg=0;
    
         //求各通道的平均值
         imageBlueChannelAvg = mean(imageBlueChannel)[0];
         imageGreenChannelAvg = mean(imageGreenChannel)[0];
         imageRedChannelAvg = mean(imageRedChannel)[0];
    
         //求出个通道所占增益
         double K = (imageRedChannelAvg+imageGreenChannelAvg+imageRedChannelAvg)/3;
         double Kb = K/imageBlueChannelAvg;
         double Kg = K/imageGreenChannelAvg;
         double Kr = K/imageRedChannelAvg;
    
         //更新白平衡后的各通道BGR值
         addWeighted(imageBlueChannel,Kb,0,0,0,imageBlueChannel);
         addWeighted(imageGreenChannel,Kg,0,0,0,imageGreenChannel);
         addWeighted(imageRedChannel,Kr,0,0,0,imageRedChannel);
    
         merge(g_vChannels,dstImage);//图像各通道合并
//         imshow("白平衡后图",dstImage);
    //将Mat转换成UIImage
    UIImage *numberImage = MatToUIImage(dstImage);
    return numberImage;
}
//findContours注释
- (void)findContoursAnnotation{
    /*
     [cpp] view plain copy
     findContours( InputOutputArray image, OutputArrayOfArrays contours,
     OutputArray hierarchy, int mode,
     int method, Point offset=Point());
     [cpp] view plain copy
     findContours( InputOutputArray image, OutputArrayOfArrays contours,
     int mode, int method, Point offset=Point());
     
     
     image：输入图像。8-bit的单通道二值图像，非零的像素都会被当作1。
     
     contours：检测到的轮廓。是一个向量，向量的每个元素都是一个轮廓。因此，这个向量的每个元素仍是一个向量。即
     
     [cpp] view plain copy
     vector<vector<Point> > contours;
     hierarchy：各个轮廓的继承关系。hierarchy也是一个向量，长度和contours相等，每个元素和contours的元素对应。hierarchy的每个元素是一个包含四个整型数的向量。即：
     
     [cpp] view plain copy
     vector<Vec4i> hierarchy; //Vec4i is a vector contains four number of int
     hierarchy[i][0],hierarchy[i][1],hierarchy[i][2],hierarchy[i][3],分别表示的是第i条轮廓(contours[i])的下一条，前一条，包含的第一条轮廓(第一条子轮廓)和包含他的轮廓(父轮廓)。
     
     mod：检测轮廓的方法。有四种方法。
     
     —CV_RETR_EXTERNAL：只检测外轮廓。忽略轮廓内部的洞。
     
     —CV_RETR_LIST：检测所有轮廓，但不建立继承(包含)关系。
     
     —CV_RETR_TREE：检测所有轮廓，并且建立所有的继承(包含)关系。也就是说用CV_RETR_EXTERNAL和CV_RETR_LIST方法的时候hierarchy这个变量是没用的，因为前者没有包含关系，找到的都是外轮廓，后者仅仅是找到所哟的轮廓但并不把包含关系区分。用TREE这种检测方法的时候我们的hierarchy这个参数才是有意义的。事实上，应用前两种方法的时候，我们就用findContours这个函数的第二种声明了。
     
     —CV_RETR_CCOMP：检测所有轮廓，但是仅仅建立两层包含关系。外轮廓放到顶层，外轮廓包含的第一层内轮廓放到底层，如果内轮廓还包含轮廓，那就把这些内轮廓放到顶层去。
     
     method：表示一条轮廓的方法。
     
     – CV_CHAIN_APPROX_NONE：把轮廓上所有的点存储。
     
     – CV_CHAIN_APPROX_SIMPLE：只存储水平，垂直，对角直线的起始点。对drawContours函数来说，这两种方法没有区别。
     
     – CV_CHAIN_APPROX_TC89_L1,CV_CHAIN_APPROX_TC89_KCOS：实现的“Teh-Chin chain approximation algorithm.”这个不太懂。他们的论文：Teh, C.H. and Chin, R.T., On the Detection of Dominant Points on Digital Curve. PAMI 11 8, pp 859-872 (1989)
     
     offset：Optional offset by which every contour point is shifted. This is useful if the contours are extracted from the image ROI and then they should be analyzed in the whole image context。懒得翻译了，直接把参考手册原文拿过来了。
     */
}
@end
