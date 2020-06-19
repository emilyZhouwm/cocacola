//
//  EHWaveView.m
//  bowen
//
//  Created by zwm on 2018/7/30.
//  Copyright © 2018年 enhance. All rights reserved.
//

#import "EHWaveView.h"

#ifndef HexRGBAlpha
#define HexRGBAlpha(rgbValue, a) [UIColor colorWithRed: ((float)((rgbValue & 0xFF0000) >> 16))/255.0 green: ((float)((rgbValue & 0xFF00) >> 8))/255.0 blue: ((float)(rgbValue & 0xFF))/255.0 alpha: (a)]
#endif

@interface EHWaveView ()

@property (nonatomic, strong) CADisplayLink *waveDisplaylink;

@property (nonatomic, strong) CAShapeLayer  *firstWaveLayer;
@property (nonatomic, strong) CAShapeLayer  *secondWaveLayer;
@property (nonatomic, strong) CAShapeLayer  *thirdWaveLayer;
@property (nonatomic, strong) CAGradientLayer  *firstColorLayer;
@property (nonatomic, strong) CAGradientLayer  *secondColorLayer;
@property (nonatomic, strong) CAGradientLayer  *thirdColorLayer;

@end

@implementation EHWaveView {

    CGFloat waveAmplitude;  // 波纹振幅
    CGFloat waveCycle;      // 波纹周期
    CGFloat waveSpeed;      // 波纹速度
    CGFloat waveGrowth;     // 波纹上升速度
    
    CGFloat waterWaveHeight;
    CGFloat waterWaveWidth;
    CGFloat offsetX;           // 波浪x位移
    CGFloat currentWavePointY; // 当前波浪上市高度Y（高度从大到小 坐标系向下增长）
    
    float variable;     // 可变参数 更加真实 模拟波纹
    BOOL increase;      // 增减变化
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds  = YES;
        [self setUp];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds  = YES;
        [self setUp];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
    if (waterWaveWidth > 0) {
        waveCycle = 3 * M_PI / waterWaveWidth;
    }
    
    if (currentWavePointY <= 0) {
        currentWavePointY = self.frame.size.height;
    }
}

- (void)setUp
{
    waterWaveHeight = self.frame.size.height/2;
    waterWaveWidth  = self.frame.size.width;
   
    waveGrowth = 1.5;
    waveSpeed = 0.1/M_PI;
    
    _percentOffset = 1;
    _waveAmplitudeOffset = 0;
    _waveSpeedOffset = 0;
    
    [self resetProperty];
}

- (void)resetProperty
{
    currentWavePointY = self.frame.size.height;
    
    variable = 1.6;
    increase = NO;
    
    offsetX = 0;
}

- (void)setPercent:(CGFloat)percent
{
    _percent = percent;
    [self resetProperty];
}

- (void)startWave
{
    [self resetProperty];

    // 从里到外
    if (_firstWaveLayer == nil) {
        // 创建第一个波浪Layer
        _firstWaveLayer = [CAShapeLayer layer];
        _firstColorLayer = [CAGradientLayer layer];
        _firstColorLayer.frame = self.bounds;
        _firstColorLayer.startPoint = CGPointMake(0, 0.5f);   //
        _firstColorLayer.endPoint = CGPointMake(1, 0.5f);     //
        _firstColorLayer.colors = @[(id)[UIColor colorWithRed:120.0/255.0 green:10.0/255.0 blue:0.0/255.0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:200.0/255.0 green:34.0/255.0 blue:7.0/255.0 alpha:0.3].CGColor];
        _firstColorLayer.mask = _firstWaveLayer;
        [self.layer addSublayer:_firstColorLayer];
    }
    
    if (_secondWaveLayer == nil) {
        // 创建第二个波浪Layer
        _secondWaveLayer = [CAShapeLayer layer];
        _secondColorLayer = [CAGradientLayer layer];
        _secondColorLayer.frame = self.bounds;
        _secondColorLayer.startPoint = CGPointMake(0, 0.5f);   //
        _secondColorLayer.endPoint = CGPointMake(1, 0.5f);     //
        _secondColorLayer.colors = @[(id)[UIColor colorWithRed:120.0/255.0 green:10.0/255.0 blue:0.0/255.0 alpha:0.4].CGColor, (id)[UIColor colorWithRed:200.0/255.0 green:34.0/255.0 blue:7.0/255.0 alpha:0.4].CGColor];
        _secondColorLayer.mask = _secondWaveLayer;
        [self.layer addSublayer:_secondColorLayer];
    }
    
    if (_thirdWaveLayer == nil) {
        // 创建第三个波浪Layer
        _thirdWaveLayer = [CAShapeLayer layer];
        _thirdColorLayer = [CAGradientLayer layer];
        _thirdColorLayer.frame = self.bounds;
        _thirdColorLayer.startPoint = CGPointMake(0, 0.5f);   //
        _thirdColorLayer.endPoint = CGPointMake(1, 0.5f);     //
        _thirdColorLayer.colors = @[(id)[UIColor colorWithRed:120.0/255.0 green:10.0/255.0 blue:0.0/255.0 alpha:1].CGColor, (id)[UIColor colorWithRed:200.0/255.0 green:34.0/255.0 blue:7.0/255.0 alpha:1].CGColor];
        _thirdColorLayer.mask = _thirdWaveLayer;
        [self.layer addSublayer:_thirdColorLayer];
    }
    
    if (_waveDisplaylink) {
        [self stopWave];
    }
    
    // 启动定时调用
    _waveDisplaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(getCurrentWave:)];
    [_waveDisplaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)reset
{
    [self stopWave];
    [self resetProperty];
    
    [_firstWaveLayer removeFromSuperlayer];
    _firstWaveLayer = nil;
    [_secondWaveLayer removeFromSuperlayer];
    _secondWaveLayer = nil;
    [_thirdWaveLayer removeFromSuperlayer];
    _thirdWaveLayer = nil;
    [_firstColorLayer removeFromSuperlayer];
    _firstColorLayer = nil;
    [_secondColorLayer removeFromSuperlayer];
    _secondColorLayer = nil;
    [_thirdColorLayer removeFromSuperlayer];
    _thirdColorLayer = nil;
}

- (void)animateWave
{
    if (increase) {
        variable += 0.01;
    } else {
        variable -= 0.01;
    }
    
    if (variable <= 1) {
        increase = YES;
    }
    
    if (variable >= 1.6) {
        increase = NO;
    }
    
    if (_waveAmplitudeOffset > 0.0) {
        _waveAmplitudeOffset -= 0.1;
    }
    if (_waveSpeedOffset > 0.0) {
        _waveSpeedOffset -= 0.001;
    }
    
    waveAmplitude = variable * 5;// 幅度调这个值
}

- (void)getCurrentWave:(CADisplayLink *)displayLink
{
    [self animateWave];
    
    if (currentWavePointY > 2 * waterWaveHeight * (1 - _percent)) {
        // 波浪高度未到指定高度 继续上涨
        currentWavePointY -= waveGrowth;
    }

    // 波浪位移，如果要不同速度分开速度
    offsetX += waveSpeed + self.waveSpeedOffset;
    
    [self setCurrentFirstWaveLayerPath];

    [self setCurrentSecondWaveLayerPath];
    
    [self setCurrentThirdWaveLayerPath];
}

- (void)setCurrentFirstWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = (waveAmplitude + self.waveAmplitudeOffset) * sin(waveCycle * x + offsetX) + currentWavePointY + (self.frame.size.height - currentWavePointY ) * self.percentOffset;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _firstWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)setCurrentSecondWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        // 余弦波浪公式
        y = (waveAmplitude + self.waveAmplitudeOffset) * cos(waveCycle * x + offsetX) + currentWavePointY + (self.frame.size.height - currentWavePointY ) * self.percentOffset;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _secondWaveLayer.path = path;
    CGPathRelease(path);
}

- (void)setCurrentThirdWaveLayerPath
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = currentWavePointY;
    CGPathMoveToPoint(path, nil, 0, y);
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        // 正弦波浪公式
        y = (waveAmplitude + self.waveAmplitudeOffset) * sin(waveCycle * x + offsetX + waterWaveWidth / 2) + currentWavePointY + (self.frame.size.height - currentWavePointY ) * self.percentOffset;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _thirdWaveLayer.path = path;
    CGPathRelease(path);
}

- (void) stopWave
{
    [_waveDisplaylink invalidate];
    _waveDisplaylink = nil;
}

- (void)dealloc
{
    [self reset];
}

@end
