//
//  ViewController.m
//  GraphicRecognition
//
//  Created by 汤义 on 2018/1/19.
//  Copyright © 2018年 汤义. All rights reserved.
//

#import "ViewController.h"
#import "TYIdentificationViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initBut];
}

- (void)initBut {
    UIButton *cameraBut = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBut.frame = CGRectMake(20, 80, 100, 40);
    cameraBut.backgroundColor = [UIColor redColor];
    [cameraBut setTitle:@"摄像识别" forState:UIControlStateNormal];
    [cameraBut addTarget:self action:@selector(cameraButSele) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBut];
    
    UIButton *imgBut = [UIButton buttonWithType:UIButtonTypeCustom];
    imgBut.frame = CGRectMake(20, 130, 100, 40);
    imgBut.backgroundColor = [UIColor greenColor];
    [imgBut setTitle:@"图片识别" forState:UIControlStateNormal];
    [imgBut addTarget:self action:@selector(imgButSele) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imgBut];
}

- (void)cameraButSele {
    TYIdentificationViewController *vc = [[TYIdentificationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imgButSele {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
