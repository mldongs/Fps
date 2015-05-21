//
//  FpsView.h
//  fps_01
//
//  Created by mldongs on 15-3-18.
//  Copyright (c) 2015年 mldongs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FpsView : UIView

@property(nonatomic, strong) NSMutableArray *cpuArray;
@property(nonatomic, strong) NSMutableArray *memArray;
@property(atomic,assign) float currMem;
@property(atomic,assign) float maxMem;
@property(atomic,assign) float currCpu;
@property(atomic,assign) float maxCpu;

@property(atomic,assign) int w;
@property(atomic,assign) int h;
@property(atomic,assign) float max;

@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UILabel *tf;
@property(nonatomic,strong) NSTimer *timer;

@property (nonatomic, assign) CGPoint prevPoint;

@end
