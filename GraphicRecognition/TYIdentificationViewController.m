//
//  TYIdentificationViewController.m
//  IdCardRecognition
//
//  Created by 汤义 on 2018/1/8.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "TYIdentificationViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>
#import "TYImageDispose.h"
#import "identificationBusiness.h"
#define UI_SCREEN_WIDTH     ([[UIScreen mainScreen] bounds].size.width) //整个屏幕的宽度
#define UI_SCREEN_HEIGHT    ([[UIScreen mainScreen] bounds].size.height) //整个屏幕的高度
@interface TYIdentificationViewController (){
    AVCaptureSession *_captureSession;
    UIImageView *_outputImageView;
    AVCaptureVideoPreviewLayer *_captureLayer;
}
@property (nonatomic, weak) UIImageView *imageViews;
@property (nonatomic, weak) UIImageView *conversionImg;

@property (nonatomic, strong) AVCaptureVideoDataOutput *captureOutput;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput* videoDataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preLayer;

@property (nonatomic, strong) TYImageDispose *imageDispose;

@property (nonatomic, strong) identificationBusiness *business;
@end

@implementation TYIdentificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initCapture];
    _business = [identificationBusiness recognizeCardManager];
}



- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    return _session;
}

- (dispatch_queue_t)queue {
    // Configure your output.
    if (!_queue) {
        _queue = dispatch_queue_create("myQueue", NULL);
    }
    return _queue;
}

- (void)initCapture {
    NSError *error = nil;
    AVCaptureDevice *device;
    NSArray *captureArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *devices in captureArray) {
        if ([devices position] == AVCaptureDevicePositionBack) {
            device = devices;
        }
    }
    //创建输入
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    //创建输出
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
    
    //设置输出样式和格式
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber
                       numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary
                                   dictionaryWithObject:value forKey:key];
    _videoDataOutput.videoSettings = videoSettings;
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([self.session canAddOutput:_videoDataOutput]) {
        [self.session addOutput:_videoDataOutput];
    }
    [self instantiationPreLayer];
    [self.session startRunning];
    
    UIImageView *imageViews = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, 200, 200)];
    imageViews.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_imageViews = imageViews];
    
    [self initImage];
    
    _imageDispose = [TYImageDispose new];
    
}



- (void)instantiationPreLayer {
    
    _preLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    //preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    _preLayer.frame = [UIScreen mainScreen].bounds;
    _preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_preLayer];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (connection == [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo]){
        UIImage *image = [_imageDispose imageFromSampleBuffers:sampleBuffer];
            NSLog(@"转码图片:%@",image);
        UIImage *img = [_imageDispose rotateImageWithAngle:image Angle:90 IsExpand:YES];
         dispatch_async(dispatch_get_main_queue(), ^{
             
            _imageViews.image = img;
             [_business recognizeCardWithImage:img compleate:^(NSString *text) {
                 NSLog(@"是否能识别:%@",text);
             } image:^(UIImage *img) {
                 _conversionImg.image = img;
             }];
        });
    }
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

- (CGSize)getVideoSize:(NSString *)sessionPreset {
    CGSize size = CGSizeZero;
    if ([sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
        size = CGSizeMake(480, 360);
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
        size = CGSizeMake(1920, 1080);
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        size = CGSizeMake(1280, 720);
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        size = CGSizeMake(640, 480);
    }
    
    return size;
}

- (void)initImage {
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH-200, 80, 200, 200)];
    image.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_conversionImg = image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
