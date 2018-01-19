//
//  TYImageIdentifyViewController.m
//  GraphicRecognition
//
//  Created by 汤义 on 2018/1/19.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "TYImageIdentifyViewController.h"
#import "identificationBusiness.h"

#define UI_SCREEN_WIDTH     ([[UIScreen mainScreen] bounds].size.width) //整个屏幕的宽度
#define UI_SCREEN_HEIGHT    ([[UIScreen mainScreen] bounds].size.height) //整个屏幕的高度
@interface TYImageIdentifyViewController ()
@property (nonatomic, strong) identificationBusiness *business;
@property (nonatomic, weak) UIImageView *conversionImg;
@end

@implementation TYImageIdentifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _business = [identificationBusiness recognizeCardManager];
    [self initImage];
    [self imageText];
}

- (void)imageText{
    UIImage *img = [UIImage imageNamed:@"这里是文字图片"];
    [_business recognizeCardWithImageText:img compleate:^(NSString *text) {
        NSLog(@"是否能识别:%@",text);
    } image:^(UIImage *img) {
        _conversionImg.image = img;
    }];
}

- (void)initImage {
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 80, UI_SCREEN_WIDTH, 400)];
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
