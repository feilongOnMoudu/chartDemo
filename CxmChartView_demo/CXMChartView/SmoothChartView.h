//
//  SmoothChartView.h
//  AseanData
//
//  Created by 陈小明 on 2017/4/24.
//  Copyright © 2017年 wanshenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LineChartDelegate <NSObject>

- (void)tapRefresh;

@optional

@end

@interface SmoothChartView : UIView

/*
 * X 轴的刻度数字
 */
@property (nonatomic,strong)NSArray *arrX;

/*
 * Y 轴的刻度数字
 */
@property (nonatomic,strong)NSArray *arrY;

@property(nonatomic,weak)id<LineChartDelegate>   delegate;

/*
 * 刷新数据 重新开始动画
 */
-(void)refreshChartAnmition;

/* 根据数据源画图
 *  pathX :横坐标数据
 *
 *  pathY :纵坐标数据源
 *  X:X轴需要切割的份数
 */
-(void)drawSmoothViewWithArrayX:(NSArray*)pathX andArrayY:(NSArray*)pathY andScaleX:(float)X;
-(void)drawSmoothViewWithArrayX2:(NSArray*)pathX andArrayY:(NSArray*)pathY andScaleX:(float)X;

@end
