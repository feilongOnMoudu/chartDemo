//
//  SmoothChartView.m
//  AseanData
//
//  Created by 陈小明 on 2017/4/24.
//  Copyright © 2017年 wanshenglong. All rights reserved.
//平滑的曲线

#import "SmoothChartView.h"
#import "UIBezierPath+curved.h"
#import "UIColor+Extra.h"

@interface SmoothChartView ()
{
    CAShapeLayer *anmitionLayer;
    
    CAShapeLayer *anmitionLayer2;
    
    CAGradientLayer *gradientLayer;
    NSMutableArray *_pointArr;
    //记录两条线所有的点
    NSMutableArray * _allPointArray;
    
    //X轴
    CAShapeLayer *layerX;
    
    //纵坐标轴
    CAShapeLayer *layerY;
    CAShapeLayer *layerY2;
    
    CAShapeLayer *_bottomLayer;
    CAShapeLayer *_bottomLayer2;
    
}

@property(nonatomic,strong) UIView *verticalView;

@property (nonatomic,strong) UIView * chartBaseView;
@end
#define  VIEW_WIDTH  self.frame.size.width //底图的宽度
#define  VIEW_HEIGHT self.frame.size.height//底图的高度

#define  LABLE_WIDTH  (VIEW_WIDTH - 25) //表的宽度
#define  LABLE_HEIGHT (self.frame.size.height - 50) //表的高度

#define LineView_WIDTH LABLE_WIDTH
#define LineView_HEIGHT LABLE_HEIGHT

@implementation SmoothChartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initData];
        self.chartBaseView = [[UIView alloc] initWithFrame:CGRectMake(25, 25, LineView_WIDTH, LineView_HEIGHT)];
        [self addSubview:self.chartBaseView];
        
        
    }
    return self;
}

- (void)start {
    // X轴
    [self makeChartXView];
    // Y轴
    [self makeChartYView];
    // 承载曲线图的View
    [self makeBottomlayer];
    [self makeBottomlayer2];
}
-(void)initData{
    _pointArr = [[NSMutableArray alloc] initWithCapacity:0];
    _allPointArray = [[NSMutableArray alloc] init];
    [self addAllEvent];
}

-(void)addAllEvent
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(event_longPressMethod:)];
    [self addGestureRecognizer:longPress];
}

-(void)event_longPressMethod:(UILongPressGestureRecognizer *)longPress {
    CGPoint touchPoint = [longPress locationInView:self.chartBaseView];
    if (UIGestureRecognizerStateBegan == longPress.state || UIGestureRecognizerStateChanged == longPress.state) {
        for (NSUInteger p = 0; p < _allPointArray.count; p++) {
            NSArray *linePointsArray = _allPointArray[p];
            
            for (NSUInteger i = 0; i < linePointsArray.count - 1; i += 1) {
#warning 获取点击的某个点
                CGFloat gap = 0.6;
                CGPoint p1 = [linePointsArray[i] CGPointValue];
                CGPoint p2 = [linePointsArray[i + 1] CGPointValue];
                if (_allPointArray.count > 1) {
                    gap = (p2.x - p1.x) /2;
                }
                
                
                float distanceToP1 = (float) fabs(touchPoint.x - p1.x);
                float distanceToP2 = (float) fabs(touchPoint.x - p2.x);
                
                float distance = MIN(distanceToP1, distanceToP2);
                
                NSLog(@"touchPoint.x = %f,p1.x   = %f,gap = %f",touchPoint.x,p1.x, gap);
                
                NSLog(@"touchPoint.x = %f,p2.x   = %f,gap = %f",touchPoint.x,p2.x, gap);
                if (touchPoint.x <= 0) {
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(tapRefresh)]) {
//                        if (!self.verticalView) {
//                            self.verticalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, LineView_HEIGHT)];
//                            self.verticalView.clipsToBounds = YES;
//                            [self.chartBaseView addSubview:self.verticalView];
//                            self.verticalView.backgroundColor = [UIColor redColor];
//                        }
//                        self.verticalView.frame = CGRectMake(0, 0, 1, LineView_HEIGHT);
//                        self.verticalView.hidden = NO;
//                        [self.delegate tapRefresh];
//                        NSLog(@"1 touch.x = %f p1x = %f p2.x = %f index = %ld",touchPoint.x,p1.x, p2.x,i);
//                        return;
//                    }
                    if (!self.verticalView) {
                        self.verticalView = [[UIView alloc] initWithFrame:CGRectMake(7, 0, 1, LineView_HEIGHT)];
                        self.verticalView.clipsToBounds = YES;
                        [self.chartBaseView addSubview:self.verticalView];
                        self.verticalView.backgroundColor = [UIColor redColor];
                    }
                    self.verticalView.frame = CGRectMake(7, 0, 1, LineView_HEIGHT);
                    self.verticalView.hidden = NO;
                    [self.delegate tapRefresh];
                    NSLog(@"1 touch.x = %f p1x = %f p2.x = %f index = %ld",touchPoint.x,p1.x, p2.x,i);
                    return;
                } else {
                    if (touchPoint.x < p1.x + gap && touchPoint.x< p1.x - gap) {
                        if (self.delegate && [self.delegate respondsToSelector:@selector(tapRefresh)]) {
                            if (!self.verticalView) {
                                self.verticalView = [[UIView alloc] initWithFrame:CGRectMake(-20, 0, 1, LineView_HEIGHT)];
                                self.verticalView.clipsToBounds = YES;
                                [self.chartBaseView addSubview:self.verticalView];
                                self.verticalView.backgroundColor = [UIColor redColor];
                            }
                            self.verticalView.frame = CGRectMake(p1.x, 0, 1, LineView_HEIGHT);
                            self.verticalView.hidden = NO;
                            [self.delegate tapRefresh];
                            NSLog(@"1 touch.x = %f p1x = %f p2.x = %f index = %ld",touchPoint.x,p1.x, p2.x,i);
                            return;
                        }
                    } else if (touchPoint.x  < p2.x + gap && touchPoint.x < p2.x - gap) {
                        if (!self.verticalView) {
                            self.verticalView = [[UIView alloc] initWithFrame:CGRectMake(-20, 0, 1, LineView_HEIGHT)];
                            self.verticalView.clipsToBounds = YES;
                            [self.chartBaseView addSubview:self.verticalView];
                            self.verticalView.backgroundColor = [UIColor redColor];
                        }
                        self.verticalView.frame = CGRectMake(p2.x, 0, 1, LineView_HEIGHT);
                        self.verticalView.hidden = NO;
                        [self.delegate tapRefresh];
                        NSLog(@"2 touch.x = %f p1x = %f p2.x = %f index = %ld",touchPoint.x,p1.x, p2.x,i+1);
                        return;
                    } else {
                        
                    }
                }
                
            }
        }
    } else {
        if (self.verticalView) {
            self.verticalView.hidden = YES;
        }
    }
}
-(void)makeChartXView{

    //X轴
    layerX = [CAShapeLayer layer];
    layerX.frame = CGRectMake(0,LineView_HEIGHT, LineView_WIDTH, 1);
    layerX.backgroundColor = [UIColor colorFromHexCode:@"d8d8d8"].CGColor;
    [self.chartBaseView.layer addSublayer:layerX];
    
}
-(void)makeChartYView{

    //左侧纵坐标轴
    layerY = [CAShapeLayer layer];
    layerY.frame = CGRectMake(25,25, 1, LABLE_HEIGHT);
    layerY.backgroundColor = [[UIColor colorFromHexCode:@"d8d8d8"] CGColor];
    [self.layer addSublayer:layerY];
    
    float height= LineView_HEIGHT/self.gLineCount;
    // 纵坐标上的横线
    for (int i=0; i<self.gLineCount; i++) {
        if (i!=5) {
            CAShapeLayer *layer5 = [CAShapeLayer layer];
            layer5.frame = CGRectMake(0, i*height,LineView_WIDTH, 0.5f);
            layer5.backgroundColor = [[UIColor colorFromHexCode:@"d8d8d8"] CGColor];
            [layerY addSublayer:layer5];
        }
    }
    
    // 右侧侧纵轴线
    CAShapeLayer *layerLeft = [CAShapeLayer layer];
    layerLeft.frame = CGRectMake(LineView_WIDTH,0, 0.5f, LineView_HEIGHT);
    layerLeft.backgroundColor = [[UIColor colorFromHexCode:@"d8d8d8"] CGColor];
    [self.chartBaseView.layer addSublayer:layerLeft];

}

-(void)makeBottomlayer{

    _bottomLayer = [CAShapeLayer layer];
    _bottomLayer.backgroundColor = [UIColor clearColor].CGColor;
    _bottomLayer.frame = CGRectMake(0, 0, LineView_WIDTH, LineView_HEIGHT);
    [self.chartBaseView.layer addSublayer:_bottomLayer];
}

- (void)makeBottomlayer2 {
    _bottomLayer2 = [CAShapeLayer layer];
    _bottomLayer2.backgroundColor = [UIColor clearColor].CGColor;
    _bottomLayer2.frame = CGRectMake(0, 0, LineView_WIDTH, LineView_HEIGHT);
    [self.chartBaseView.layer addSublayer:_bottomLayer2];
}

-(void)setArrX:(NSArray *)arrX{
    _arrX = arrX;
    
    [layerX removeFromSuperlayer];
    [self makeChartXView];
    
    
    for (NSInteger i=0; i<arrX.count; i++) {
        
        UILabel *label = (UILabel*)[self viewWithTag:5000+i];
        [label removeFromSuperview];
    }
    //横坐标上的数字
    for (int i=0; i<self.xLabelCount; i++) {
        
        UILabel *layer3 = [UILabel new];
        layer3.frame = CGRectMake(25 + LineView_WIDTH / self.xLabelCount  * i, CGRectGetMaxY(self.chartBaseView.frame), LineView_WIDTH / self.xLabelCount, 20);
        layer3.text = [NSString stringWithFormat:@"%@",_arrX[i]];
        layer3.font = [UIFont systemFontOfSize:12];
        layer3.textAlignment = ((i == 0) ? NSTextAlignmentLeft : NSTextAlignmentRight);
        layer3.tag = 5000+i;
        layer3.textColor = [UIColor colorFromHexCode:@"999999"];
        [self addSubview:layer3];
    }

}
-(void)setArrY:(NSArray *)arrY{
    _arrY = arrY;
    
    [layerY removeFromSuperlayer];
    [self makeChartYView];
    
    float height= LineView_HEIGHT/self.gLineCount;

    for (NSInteger i=0; i<self.gLineCount; i++) {
        
        UILabel *label = (UILabel*)[self viewWithTag:4000+i];
        [label removeFromSuperview];
    }
    CGFloat gapNum = [[_arrY lastObject] floatValue] - [[_arrY firstObject] floatValue];
    //纵坐标上的数字
    for (int i=0; i<self.gLineCount+1; i++) {
        
        UILabel *layer6 = [UILabel new];
        layer6.frame = CGRectMake(0,LABLE_HEIGHT-(i*height)+15, 25, 20);
        layer6.text = [NSString stringWithFormat:@"%.0f",gapNum/self.gLineCount * i];
        layer6.font = [UIFont systemFontOfSize:12];
        layer6.textAlignment = NSTextAlignmentRight;
        layer6.tag = 4000+i;
        layer6.textColor = [UIColor colorFromHexCode:@"999999"];
        [self addSubview:layer6];
    
    }
}
//画图
-(void)drawSmoothViewWithArrayX:(NSArray*)pathX andArrayY:(NSArray*)pathY andScaleX:(float)X{

    [_bottomLayer removeFromSuperlayer];
    [self makeBottomlayer];
    [_pointArr removeAllObjects];
    
    // 创建layer并设置属性
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth =  1.0f;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeColor = [UIColor colorFromHexCode:@"00c1ed"].CGColor;
    [_bottomLayer addSublayer:layer];
    
    CGPoint point;
    // 创建贝塞尔路径~
    UIBezierPath *path = [UIBezierPath bezierPath];

    //X轴和Y轴的倍率
    CGFloat BLX = (LineView_WIDTH - 10)/(pathX.count - 1);
     CGFloat gapNum = [[_arrY lastObject] floatValue] - [[_arrY firstObject] floatValue];
    NSMutableArray * ponits = [[NSMutableArray alloc] init];
    for (int i= 0; i< pathY.count; i++) {
        
        CGFloat X = i*BLX + 10;
        CGFloat Y = (1 - ([pathY[i] floatValue]/gapNum)) * LineView_HEIGHT;
        
        //NSLog(@"space==%lf",VIEW_HEIGHT - LABLE_HEIGHT);
        point = CGPointMake(X, Y);

        [_pointArr addObject:[NSValue valueWithCGPoint:point]];
        
        [ponits addObject:[NSValue valueWithCGPoint:point]];
       
        
        if (i==0) {
            [path moveToPoint:point];//起点
        }
        
        [path addLineToPoint:point];
    }
     [_allPointArray addObject:ponits];
    //平滑曲线
    path = [path smoothedPathWithGranularity:20];
    // 关联layer和贝塞尔路径~
    layer.path = path.CGPath;
    
    // 创建Animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0);
    animation.toValue = @(3.0);
    animation.autoreverses = NO;
    animation.duration = 3;
    
    // 设置layer的animation
    [layer addAnimation:animation forKey:nil];
    
    layer.strokeEnd = 1;
    anmitionLayer = layer;
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [self drawGradient];
//
//    });

}

-(void)drawSmoothViewWithArrayX2:(NSArray*)pathX andArrayY:(NSArray*)pathY andScaleX:(float)X{
    
    [_bottomLayer2 removeFromSuperlayer];
    [self makeBottomlayer2];
    [_pointArr removeAllObjects];
    
    // 创建layer并设置属性
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth =  1.0f;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeColor = [UIColor colorFromHexCode:@"999999"].CGColor;
    [_bottomLayer2 addSublayer:layer];
    
    CGPoint point;
    // 创建贝塞尔路径~
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //X轴和Y轴的倍率
    CGFloat BLX = (LineView_WIDTH - 10)/(pathX.count - 1);
    CGFloat gapNum = [[_arrY lastObject] floatValue] - [[_arrY firstObject] floatValue];
    NSMutableArray * ponits = [[NSMutableArray alloc] init];
    for (int i= 0; i< pathY.count; i++) {
        
        CGFloat X = i*BLX + 10;
        NSLog(@"%f",BLX);
        CGFloat Y = (1 - ([pathY[i] floatValue]/gapNum)) * LineView_HEIGHT;
        
        //NSLog(@"space==%lf",VIEW_HEIGHT - LABLE_HEIGHT);
        point = CGPointMake(X, Y);
        NSLog(@"%f    %f",point.x,point.y);
        [_pointArr addObject:[NSValue valueWithCGPoint:point]];
        [ponits addObject:[NSValue valueWithCGPoint:point]];
        
        if (i==0) {
            [path moveToPoint:point];//起点
        }
        
        [path addLineToPoint:point];
    }
    [_allPointArray addObject:ponits];
    //平滑曲线
    path = [path smoothedPathWithGranularity:20];
    // 关联layer和贝塞尔路径~
    layer.path = path.CGPath;
    
    // 创建Animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0);
    animation.toValue = @(3.0);
    animation.autoreverses = NO;
    animation.duration = 3;
    
    // 设置layer的animation
    [layer addAnimation:animation forKey:nil];
    
    layer.strokeEnd = 1;
    anmitionLayer2 = layer;
}

#pragma mark 渐变阴影
- (void)drawGradient {
    
    [gradientLayer removeAllAnimations];
    [gradientLayer removeFromSuperlayer];
    
    gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0,0, LABLE_WIDTH, VIEW_HEIGHT -23);
    gradientLayer.colors =@[(__bridge id)[UIColor colorWithRed:46/255.0 green:200/255.0 blue:237/255.0 alpha:0.5].CGColor,(__bridge id)[UIColor colorWithRed:240/255.0 green:252/255.0 blue:254/255.0 alpha:0.4].CGColor];
    
    UIBezierPath *gradientPath = [[UIBezierPath alloc] init];
    
   // NSLog(@"Y====%lf",[[_pointArr firstObject] CGPointValue].y);

    CGPoint firstPoint = CGPointMake([[_pointArr firstObject] CGPointValue].x,LABLE_HEIGHT+25) ;

    CGPoint lastPoint =  [[_pointArr lastObject] CGPointValue];
    
   // NSLog(@"firstPointX===%lf firstpointY==%lf",firstPoint.x,firstPoint.y);
    [gradientPath moveToPoint:firstPoint];
    
    for (int i = 0; i < _pointArr.count; i ++) {
        [gradientPath addLineToPoint:[_pointArr[i] CGPointValue]];
    }
    // 圆滑曲线
    gradientPath = [gradientPath smoothedPathWithGranularity:20];
    
    CGPoint endPoint = lastPoint;
    endPoint = CGPointMake(endPoint.x , VIEW_WIDTH +23);
    [gradientPath addLineToPoint:endPoint];
    
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = gradientPath.CGPath;
    gradientLayer.mask = arc;
    [anmitionLayer addSublayer:gradientLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(0.3);
    animation.toValue = @(1);
    animation.autoreverses = NO;
    animation.duration = 2.0;
    [gradientLayer addAnimation:animation forKey:nil];
    
}
-(void)refreshChartAnmition{
    
    // 创建Animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0.0);
    animation.toValue = @(3.0);
    animation.autoreverses = NO;
    animation.duration = 3;
    
    // 设置layer的animation
    [anmitionLayer addAnimation:animation forKey:nil];
     [anmitionLayer2 addAnimation:animation forKey:nil];
    
    anmitionLayer.strokeEnd = 1;
    anmitionLayer2.strokeEnd = 1;
    
    [gradientLayer removeAllAnimations];
    [gradientLayer removeFromSuperlayer];
    
    [_allPointArray removeAllObjects];
    
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [gradientLayer removeAllAnimations];
         [gradientLayer removeFromSuperlayer];

        //[self drawGradient];

    });
}
@end
