//
//  ViewController.m
//  cocacola
//
//  Created by zwm on 2018/7/31.
//  Copyright © 2018年 enhance. All rights reserved.
//

#import "ViewController.h"
#import "EHWaveView.h"
#import <CoreMotion/CoreMotion.h>

#ifndef HexRGB
#define HexRGB(rgbValue) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha: 1.0]
#endif

@interface ViewController ()

@property (nonatomic, weak) EHWaveView *waterWaveView;
@property (nonatomic, strong) CMMotionManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w * 1124.0f / 962.0f;
    CGFloat boW = h * 920.0f / 1124.0f;
    
    // 因为图片不是居中的，只为6sp调了一下偏移量
    CGRect waveFrame = CGRectMake((w - boW) / 2 - 16, 44 + (h - boW) / 2 + 12, boW, boW);

    EHWaveView *waterWaveView = [[EHWaveView alloc] initWithFrame:waveFrame];
    [self.view addSubview:waterWaveView];
    _waterWaveView = waterWaveView;
    _waterWaveView.layer.cornerRadius = MIN(CGRectGetHeight(_waterWaveView.frame)/2, CGRectGetWidth(_waterWaveView.frame)/2);
    
    UIImageView *upView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, w, h)];
    [self.view addSubview:upView];
    [upView setImage:[UIImage imageNamed:@"cocacola"]];
    
    _waterWaveView.percent = 0.8;
    [_waterWaveView startWave];
    
    _manager = [[CMMotionManager alloc] init];
    __weak typeof(self) weakSelf = self;
    if (_manager.deviceMotionAvailable) {
        _manager.deviceMotionUpdateInterval = 0.01f;
        [_manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                      withHandler:^(CMDeviceMotion *data, NSError *error) {
                                          if (data.userAcceleration.x < -2.5f || data.userAcceleration.x > 2.5f) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  weakSelf.waterWaveView.waveSpeedOffset = 0.2/M_PI;
                                                  weakSelf.waterWaveView.waveAmplitudeOffset = 10;
                                              });
                                          }
                                          if (data.gravity.z <= -0.99) {
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  weakSelf.waterWaveView.percentOffset = 0;
                                              });
                                              weakSelf.waterWaveView.transform = CGAffineTransformMakeRotation(0.0);
                                          }
                                          else {
                                              double rotation = atan2(data.gravity.x, data.gravity.y) - M_PI;
                                              CGFloat percent = 1.0;
                                              if (rotation >= -0.5 * M_PI) {
                                                  percent = (rotation + 0.5 * M_PI) / (0.5 * M_PI);
                                              } else if (rotation >= -M_PI) {
                                                  percent = 1.0 - (rotation + M_PI) / (0.5 * M_PI);
                                              } else if (rotation >= -1.5 * M_PI) {
                                                  percent = (rotation + 1.5 * M_PI) / (0.5 * M_PI);
                                              } else if (rotation >= -2.0 * M_PI) {
                                                  percent = 1.0 - (rotation + 2.0 * M_PI) / (0.5 * M_PI);
                                              }
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  weakSelf.waterWaveView.percentOffset = (1.0 - percent) / 4.0;
                                              });
                                              weakSelf.waterWaveView.transform = CGAffineTransformMakeRotation(rotation);
                                          }
                                      }];
    }
}

- (IBAction)resetBtnClick:(UIButton *)sender
{
    [_waterWaveView stopWave];
    [_waterWaveView startWave];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
