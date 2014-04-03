//
//  DecoratedUISlider.m
//  CircularProgressViewTest
//
//  Created by Vladimir Doukhanine on 3/13/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "DecoratedUISlider.h"

@interface DecoratedUISlider()

@property (nonatomic) CircularProgressView *pop;

@end

@implementation DecoratedUISlider

- (id)initWithFrame:(CGRect)rect
{
    if ((self = [super initWithFrame:rect]))
        [self setup];
    return self;
}

- (id)initWithCoder:(NSCoder *)coder //up from storyboard
{
    if ((self = [super initWithCoder:coder]))
        [self setup];
    return self;
}

- (void)setup
{
    self.pop = [[CircularProgressView alloc] initWithFrame:[self getThumbRect]];
    self.pop.alpha = 0;
    [self addSubview:self.pop];
    [self update];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL ret = [super beginTrackingWithTouch:touch withEvent:event];
    //NSLog(@"%s %d",__func__, ret);
    if (ret) {
        [self update];
        [self.pop show:YES animated:NO duration:0];
    }
    return ret;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [super endTrackingWithTouch:touch withEvent:event];
    [self update];
    [self.pop show:NO animated:NO duration:0];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [super cancelTrackingWithEvent:event];
    [self update];
    [self.pop show:NO animated:NO duration:0];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL ret = [super continueTrackingWithTouch:touch withEvent:event];
    //NSLog(@"%s %d",__func__, ret);
    [self update];
    if (!ret)
        [self.pop show:NO animated:NO duration:0];
    return ret;
}

- (void)update
{
    CGRect rect = [self getThumbRect];
    self.pop.frame = CGRectOffset(rect, 0, -(rect.size.height + 1));
    DecoratedUISlider * __weak weakSelf = self;
    CircularProgressAnimatingCompletionBlock completion = ^{
        //NSLog(@"Completion");
        DecoratedUISlider *strongSelf = weakSelf;
        if (0 == strongSelf.pop.alpha) {
            strongSelf.pop.alpha = 1;
            UIGraphicsBeginImageContext(strongSelf.pop.layer.bounds.size);
            [strongSelf.pop.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            strongSelf.pop.alpha = 0;
            [strongSelf setThumbImage:img forState:UIControlStateNormal];
        } else {
            if ([strongSelf thumbImageForState:UIControlStateNormal])
                [strongSelf setThumbImage:nil forState:UIControlStateNormal];
        }
    };
    [self.pop set:self.value completion:completion newColorsAndWidth:nil];
}

- (CGRect)getThumbRect
{
    return [self thumbRectForBounds:self.bounds trackRect:[self trackRectForBounds:self.bounds] value:self.value];
}

- (void)setValue:(float)value
{
    [super setValue:value];
    //NSLog(@"setValue:%f", value);
    [self update];
}

@end
