//
//  UIView+CircularProgress.m
//  Vladimir's CircularProgress
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "CALayer+CircularProgress.h"
#import "NSAttributedString+FitToFrame.h"

@implementation CALayer (CircularProgress)

#pragma mark private constants

static NSString *kCircularProgressShapeLayerName = @"CircularProgress";
static NSString *kCircularProgressBgroundShapeLayerName = @"CircularProgressBground";
static NSUInteger const kCircularProgressKeyFrameLimit = 1000;

#pragma mark public instance methods

- (BOOL)addCircularProgressWithMax:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newPosition animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat frame:(CGRect)frame corners:(BOOL)corners colorsAndWidth:(NSDictionary*)dict completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    [ self removeCircularProgress]; // dont add it twice!!!                                                                                                                     
    if (current > max || newPosition > max || CGRectIsEmpty(frame)) //sanity check
        return NO;
    UIColor *bgroundColor = [dict objectForKey:kCircularProgressBgroundColorKey];
    if (!bgroundColor)
        bgroundColor = [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.];
    UIColor *bgroundCircleColor = [dict objectForKey:kCircularProgressBgroundCircleColorKey];
    if (!bgroundCircleColor)
        bgroundCircleColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.];
    UIColor *animatingCircleColor = [dict objectForKey:kCircularProgressAnimatingCircleColorKey];
    if (!animatingCircleColor)
        animatingCircleColor = [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.];
    UIColor *textColor = [dict objectForKey:kCircularProgressTextColorKey];
    if (!textColor)
        textColor = [UIColor blackColor];
    NSNumber *bgroundCircleWidth = [dict objectForKey:kCircularProgressBgroundCircleWidthKey];
    if (!bgroundCircleWidth)
        bgroundCircleWidth = @(2); // default;
    NSNumber *animatingCircleWidth = [dict objectForKey:kCircularProgressAnimatingCircleWidthKey];
    if (!animatingCircleWidth)
        animatingCircleWidth = @(8);
    CGFloat inset = MAX([bgroundCircleWidth floatValue], [animatingCircleWidth floatValue]) / 4;
    int space = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame)) - inset * 2;
    if (space < 20)  //sanity check
        return NO;
    [self removeCircularProgress];

    CAShapeLayer *shapeLayer;
    if (corners) {
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.zPosition = CGFLOAT_MAX;
        shapeLayer.frame = frame;
        shapeLayer.backgroundColor = bgroundColor.CGColor;
        shapeLayer.name = kCircularProgressBgroundShapeLayerName;
        [self addSublayer:shapeLayer];
    }
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.zPosition = CGFLOAT_MAX;
    shapeLayer.frame = frame;
    CGFloat sqSize = MIN(CGRectGetWidth(shapeLayer.bounds), CGRectGetHeight(shapeLayer.bounds));
    CGRect bounds = CGRectMake((CGRectGetWidth(shapeLayer.bounds) - sqSize) / 2., (CGRectGetHeight(shapeLayer.bounds) - sqSize) / 2., sqSize, sqSize);
    shapeLayer.bounds = CGRectInset(bounds, inset, inset);
    CGPoint center = CGPointMake( shapeLayer.bounds.origin.x + CGRectGetWidth(shapeLayer.bounds) / 2., shapeLayer.bounds.origin.y + CGRectGetHeight(shapeLayer.bounds) / 2.);
    inset = [bgroundCircleWidth floatValue] / 4;
    bounds = CGRectInset(shapeLayer.bounds, inset, inset);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center radius:bounds.size.height / 2. startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = bgroundCircleColor.CGColor;
    shapeLayer.fillColor = bgroundColor.CGColor;
    shapeLayer.lineWidth = [bgroundCircleWidth floatValue];
    shapeLayer.strokeStart = 0.;
    shapeLayer.strokeEnd = 1.;
    shapeLayer.name = kCircularProgressShapeLayerName;

    CAShapeLayer *sliderLayer = [CAShapeLayer layer];
    sliderLayer.zPosition = CGFLOAT_MAX;
    sliderLayer.frame = frame;
    sliderLayer.bounds = shapeLayer.bounds;
    sliderLayer.path = path.CGPath;
    sliderLayer.strokeColor = animatingCircleColor.CGColor;
    sliderLayer.fillColor = bgroundColor.CGColor;
    sliderLayer.lineWidth = [animatingCircleWidth floatValue];
    sliderLayer.strokeStart = sliderLayer.strokeEnd = 0.;

    //additional 1 transparent to get bounds fitted in round!!
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.zPosition = CGFLOAT_MAX;
    CGFloat sqSize1 = (( sqSize - [animatingCircleWidth floatValue] - [bgroundCircleWidth floatValue] ) / 2.) * M_SQRT2;
    inset = (sqSize - sqSize1) / 2;
    txtLayer.frame = CGRectInset(shapeLayer.bounds, inset, inset);
    txtLayer.backgroundColor = bgroundColor.CGColor; //animatingCircleColor.CGColor;
    txtLayer.foregroundColor = textColor.CGColor;
    txtLayer.name = [NSString stringWithFormat:@"%tu,%tu", max, current]; //[@(current) stringValue];
    txtLayer.alignmentMode = kCAAlignmentCenter;
    txtLayer.contentsGravity = kCAGravityBottom;

    //need to caclulate frame for goal-1 first because it is widest themn we roll to current
    CTFontRef fontRef = CTFontCreateWithName(CFSTR("HelveticaNeue-Thin"), 20.0, NULL); //"Chalkduster""HelveticaNeue-Light""Baskerville""HelveticaNeue-Thin"
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[@(0) stringValue]
                                                attributes:@{ (NSString *)kCTFontAttributeName: (__bridge id)fontRef,
                                                              (NSString *)kCTForegroundColorAttributeName: (__bridge id)textColor.CGColor}];
    CFRelease(fontRef);
    
    txtLayer.string = attrStr;

    [shapeLayer addSublayer:sliderLayer];
    
    [shapeLayer addSublayer:txtLayer];
    
    [self addSublayer:shapeLayer];
    
    return [self animateCircularProgress:shapeLayer max:max currentPosition:current newPosition:newPosition newColors:nil animationDuration:duration repeat:repeat completion:completionBlock];
}

- (BOOL)findCircularProgress
{
    if ([self findCircularProgressShapelayer:kCircularProgressShapeLayerName]) //progressshapelayer only, background layer may not exist
        return YES;
    else
        return NO;
}

- (void)removeCircularProgress
{
    [ self removeCircularProgressAnimations];
    [[self findCircularProgressShapelayer:kCircularProgressShapeLayerName] removeFromSuperlayer];
    [[self findCircularProgressShapelayer:kCircularProgressBgroundShapeLayerName] removeFromSuperlayer];
}

- (BOOL)setCircularProgressCurrentPosition:(NSUInteger)newCurrent newColorsAndWidth:(NSDictionary*)dict animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    NSUInteger max, current;
    CAShapeLayer *shapeLayer;
    if ((shapeLayer = [self getCircularProgressMax:&max andCurrent:&current]))
        return [self animateCircularProgress:shapeLayer max:max currentPosition:current newPosition:newCurrent newColors:dict animationDuration:duration repeat:repeat completion:completionBlock];
    else
        return NO;
}

- (CAShapeLayer *)getCircularProgressMax:(NSUInteger *)max andCurrent:(NSUInteger *)current
{
    CAShapeLayer *shapeLayer = [self findCircularProgressShapelayer:kCircularProgressShapeLayerName];
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    if (!txtLayer)
        return nil;
    if (sscanf([txtLayer.name cStringUsingEncoding:NSUTF8StringEncoding], "%tu,%tu", max, current) != 2 )
        return nil;
//    NSLog(@"%s %tu,%tu", __func__, *max, *current);
    return shapeLayer;
}

#pragma mark private instance methods

- (void)removeCircularProgressAnimations
{
    [self removeAllAnimations];
    for (CALayer* layer in [self sublayers])
        [layer removeAllAnimations];
}

- (BOOL)animateCircularProgress:(CAShapeLayer *)shapeLayer max:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newCurrent newColors:(NSDictionary*)colors animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    if (!shapeLayer || current > max || newCurrent > max) //sanity check
        return NO;
    [CATransaction lock];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            //[ self removeCircularProgressAnimations];
            completionBlock();
        }
    }];
    [ self removeCircularProgressAnimations];
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    CAShapeLayer *sliderLayer = (CAShapeLayer *)shapeLayer.sublayers[0];

    UIColor *bgroundColor = [colors objectForKey:kCircularProgressBgroundColorKey];
    if (bgroundColor) {
        [self findCircularProgressShapelayer:kCircularProgressBgroundShapeLayerName].backgroundColor = bgroundColor.CGColor;
        shapeLayer.fillColor = bgroundColor.CGColor;
        sliderLayer.fillColor = bgroundColor.CGColor;
        txtLayer.backgroundColor = bgroundColor.CGColor;
    }
    UIColor *bgroundCircleColor = [colors objectForKey:kCircularProgressBgroundCircleColorKey];
    if (bgroundCircleColor)
        shapeLayer.strokeColor = bgroundCircleColor.CGColor;
    UIColor *animatingCircleColor = [colors objectForKey:kCircularProgressAnimatingCircleColorKey];
    if (animatingCircleColor)
        sliderLayer.strokeColor = animatingCircleColor.CGColor;
    UIColor *txtColor = [colors objectForKey:kCircularProgressTextColorKey];
    if (txtColor) {
        if (!CGColorEqualToColor(txtLayer.foregroundColor, txtColor.CGColor))
            txtLayer.foregroundColor = txtColor.CGColor;
    }
    txtLayer.name = [NSString stringWithFormat:@"%tu,%tu", max, newCurrent];
    //txt & txt bounds
    BOOL inc = (newCurrent >= current) ? YES : NO;
    NSUInteger steps = inc ? newCurrent - current : current - newCurrent;
    NSUInteger step = 1;
    if (0. == duration) {
        step = steps;
        steps = 0;
    } else {
        CGFloat curFps30 = steps / duration / 30.;
        if (curFps30 > 1.) {// > 30FPS?
            step *= curFps30;
            steps /= step;
        }
    }
    if (steps > kCircularProgressKeyFrameLimit) {
        step *= steps / kCircularProgressKeyFrameLimit;
        steps = kCircularProgressKeyFrameLimit;
    }
    NSMutableArray *valuesStr = [NSMutableArray arrayWithCapacity:steps + 2];
    NSMutableArray *valuesBounds = [NSMutableArray arrayWithCapacity:steps + 2];
    CGRect newBounds;
    CGFloat fontSize = 0;
    NSUInteger i = 0, cur = current;
    valuesStr[i] =  [txtLayer.string fitToFrame:txtLayer.frame newString:[@(cur) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
    valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
    while (++i < steps) {
        valuesStr[i] = [txtLayer.string fitToFrame:txtLayer.frame newString:[@(cur) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
        valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
        if (inc)
            cur += step;
        else
            cur -= step;
    }
    valuesStr[i] = [txtLayer.string fitToFrame:txtLayer.frame newString:[@(newCurrent) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
    valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
    
    CAKeyframeAnimation *txtAnimation = [CAKeyframeAnimation animationWithKeyPath:@"string"];
    txtAnimation.values = valuesStr;
    txtAnimation.duration = duration;
    txtAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    txtAnimation.fillMode = kCAFillModeForwards;
    txtAnimation.removedOnCompletion = NO;
    [txtLayer addAnimation:txtAnimation forKey:txtAnimation.keyPath];
    //txt bounds
    CAKeyframeAnimation *boundsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.values = valuesBounds;
    boundsAnimation.duration = duration;
    boundsAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    boundsAnimation.fillMode = kCAFillModeForwards;
    boundsAnimation.removedOnCompletion = NO;
    [txtLayer addAnimation:boundsAnimation forKey:boundsAnimation.keyPath];
    //slider
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = duration;
    pathAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    pathAnimation.fromValue = @(((CGFloat)current) / max);
    pathAnimation.toValue = @(((CGFloat)newCurrent) / max);
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [sliderLayer addAnimation:pathAnimation forKey:pathAnimation.keyPath];
    
    [CATransaction flush];
    [CATransaction commit];
    [CATransaction flush];
    [CATransaction unlock];
    return YES;
}

- (CAShapeLayer *)findCircularProgressShapelayer: (NSString *)layerName
{
    for (CALayer *layer in self.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]] && [layer.name isEqualToString:layerName])
            return (CAShapeLayer *)layer;
    }
    return nil;
}

@end
