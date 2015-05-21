//
//  FpsView.m
//  fps_01
//
//  Created by mldongs on 15-3-18.
//  Copyright (c) 2015年 mldongs. All rights reserved.
//

#import "FpsView.h"
#import <mach/mach.h>

@implementation FpsView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (instancetype)initWithFrame:(CGRect)frame {
    // Do any additional setup after loading the view, typically from a nib.
    //[self fps];
    self = [super initWithFrame:frame];
    if(self)
    {
        self.w = frame.size.width;
        self.h = frame.size.height;
        
        self.max = 60;
        
        self.cpuArray = [NSMutableArray array];
        self.memArray = [NSMutableArray array];
        
        
        CGRect rect = CGRectMake(0, 0, self.w, self.h);
        
        _tf = [[UILabel alloc] initWithFrame:rect];
        
        _imageView = [[UIImageView alloc] initWithFrame:rect];
        
        [_tf setFont:[UIFont systemFontOfSize:11]];
        _tf.numberOfLines = 0;
        _tf.alpha = 0.5;
        
        [self addSubview:_imageView];
        [self addSubview:_tf];
        
        _imageView.frame = CGRectMake(0, 0, self.w, self.h);
        _tf.frame = CGRectMake(0, 0, self.w, self.h);
        
        UIGraphicsBeginImageContext(_imageView.frame.size);
        [_imageView.image drawInRect:rect];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(update) userInfo:nil repeats:YES];
        
        [self.timer setFireDate:[NSDate distantPast]];
    }
    return self;
    
    //[self showLine];
}

- (void) update{
    [self captureMemUsageGetString];
    self.currCpu = cpu_usage();
    self.currMem = [self usedMemory];
    
    //self.currMem = (self.currMem /1024/1024*100)/1024;
    
    //NSLog(@"cpu:%f , mem:%7.1f",self.currCpu,self.currMem/1000.0f);
    
    self.maxCpu = self.currCpu > self.maxCpu?self.currCpu:self.maxCpu;
    self.maxMem = self.currMem > self.maxMem?self.currMem:self.maxMem;
    
    [self.cpuArray addObject:[NSNumber numberWithFloat:self.currCpu]];
    if (self.cpuArray.count>self.max) {
        [self.cpuArray removeObjectAtIndex:0];
    }
    
    [self.memArray addObject:[NSNumber numberWithUnsignedLongLong:self.currMem]];
    if (self.memArray.count>self.max) {
        [self.memArray removeObjectAtIndex:0];
    }
    
    NSString *str = [NSString stringWithFormat:@" cpu:   %3.1f%%\n mem: %4.1fM",self.currCpu,(self.currMem/1000000.0f)];
    _tf.text = str;
    
    [self showLine];
}

- (void) dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void) showLine{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    
    CGContextClearRect(context,CGRectMake(0, 0, self.w, self.h));
    
    CGContextBeginPath(context);
    
    //drawbackground
    //NSArray *cArray = [NSArray arrayWithArray:self.cpuArray];
    //NSArray *mArray = [NSArray arrayWithArray:self.memArray];
    
    //    反序
    NSArray *cArray = [NSArray arrayWithArray:[self.cpuArray reverseObjectEnumerator].allObjects];
    NSArray *mArray = [NSArray arrayWithArray:[self.memArray reverseObjectEnumerator].allObjects];
    
    double vx = 0.0;
    double vy = 0.0;
    
    
    //cpu
    CGContextSetRGBStrokeColor(context, 1.0, 0, 0, 0.5);
    CGContextMoveToPoint(context, 0, self.h);
    for (int i=0; i<cArray.count; i++) {
        
        if (self.max == 0 || self.maxCpu == 0) {
            vx = 0;
            vy = 0;
        } else {
            vx = self.w * (i / self.max);
            vy = self.h - self.h * ([[cArray objectAtIndex:i] floatValue] / self.maxCpu);
        }
        CGContextAddLineToPoint(context, vx, vy);
    }
    
    CGContextAddLineToPoint(context, vx, self.h);
    
    CGContextSetRGBFillColor(context, 0.5, 0.0, 0.0, 0.2);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    //mem
    CGContextSetRGBStrokeColor(context, 0.0, 0, 1.0, 0.7);
    CGContextMoveToPoint(context, 0, self.h);
    
    for (int i=0; i<mArray.count; i++) {
        
        if (self.maxMem == 0 || self.max == 0) {
            vx = 0;
            vy = 0;
        } else {
            vx = self.w * (i / self.max);
            vy = self.h - self.h * ([[mArray objectAtIndex:i] floatValue] / self.maxMem);
        }
        CGContextAddLineToPoint(context, vx, vy);
    }
    
    CGContextAddLineToPoint(context, vx, self.h);
    
    //CGContextClosePath(context);
    //    CGContextStrokePath(context);
    //
    CGContextSetRGBFillColor(context, 0.0, 0.0, 0.5, 0.2);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    //UIGraphicsEndImageContext();
}


- (void)fps {
    
    CGRect rect = CGRectMake(0, 0, 100, 30);
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:rect];
    
    [self addSubview:imageView];
    
    //imageView.frame = CGRectMake(50, 150, 100, 30);
    
    CGRect frame = imageView.frame;
    frame.origin.y = 50;
    imageView.frame = frame;
    
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 1.0);  //线宽
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);  //颜色
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), 0, 0);  //起点坐标
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), 60, 0);   //终点坐标
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    imageView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    //    [super touchesBegan:touches withEvent:event];
    
    _prevPoint = [touch locationInView:nil];
    NSLog(@"begintouch");
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:nil];
    CGRect frame = self.frame;
    frame.origin.x += currentLocation.x - _prevPoint.x;
    frame.origin.y += currentLocation.y - _prevPoint.y;
    
    //_prevPoint = frame.origin;
    
    self.frame = frame;
    
    _prevPoint = currentLocation;
    NSLog(@"touchmove");
}


//c++
float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

float mem_usage(void)
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   MACH_TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        //NSLog(@"Memory in use (in bytes): %llu", info.resident_size);
        return info.resident_size;
    } else {
        //NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
        return 0;
    }
}


static long prevMemUsage = 0;
static long curMemUsage = 0;
static long memUsageDiff = 0;
static long curFreeMem = 0;

-(vm_size_t) freeMemory {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

-(vm_size_t) usedMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

-(void) captureMemUsage {
    prevMemUsage = curMemUsage;
    curMemUsage = [self usedMemory];
    memUsageDiff = curMemUsage - prevMemUsage;
    curFreeMem = [self freeMemory];
    
    
}

-(NSString*) captureMemUsageGetString{
    return [self captureMemUsageGetString: @"Memory used %7.1f (%+5.0f), free %7.1f kb"];
}

-(NSString*) captureMemUsageGetString:(NSString*) formatstring {
    [self captureMemUsage];
    
    //NSLog([NSString stringWithFormat:formatstring,curMemUsage/1000.0f,memUsageDiff/1000.0f,curFreeMem/1000.0f]);
    return [NSString stringWithFormat:formatstring,curMemUsage/1000.0f, memUsageDiff/1000.0f, curFreeMem/1000.0f];
    
}
@end

