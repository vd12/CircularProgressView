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

- (id)initWithCoder:(NSCoder*)coder //up from storyboard
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

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [self update];
    [self.pop show:YES animated:NO duration:0];
    BOOL ret = [super beginTrackingWithTouch:touch withEvent:event];
    return ret;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [self update];
    [self.pop show:NO animated:NO duration:0];
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [self update];
    [self.pop show:NO animated:NO duration:0];
    [super cancelTrackingWithEvent:event];
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    //NSLog(@"%s",__func__);
    [self update];
    BOOL ret = [super continueTrackingWithTouch:touch withEvent:event];
    return ret;
}

- (void)update
{
    CGRect rect = [self getThumbRect];
    self.pop.frame = CGRectOffset(rect, 0, -(rect.size.height + 1));
    CircularProgressViewAnimatingCompletionBlock completion = ^{
        //NSLog(@"Completion");
        if (0 == self.pop.alpha) {
            self.pop.alpha = 1;
            UIGraphicsBeginImageContextWithOptions(self.pop.layer.bounds.size, self.pop.layer.opaque, 0);
            [self.pop.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [self setThumbImage:img forState:UIControlStateNormal];
            self.pop.alpha = 0;
        } else
            [self setThumbImage:nil forState:UIControlStateNormal];
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
