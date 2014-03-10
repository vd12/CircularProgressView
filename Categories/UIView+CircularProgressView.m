//
//  UIView+CircularProgressView.m
//  Vladimir's CircularProgressView
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "UIView+CircularProgressView.h"
#import "NSAttributedString+FitToFrame.h"

@implementation UIView (CircularProgressView)

#pragma mark private constants

static NSString *kCircularProgressViewShapeLayerName = @"CircularProgressView";
static NSString *kCircularProgressViewBgroundShapeLayerName = @"CircularProgressViewBground";
static NSUInteger const kCircularProgressViewKeyFrameLimit = 1000;

#pragma mark public instance methods

-(BOOL) addCircularProgressViewWithMax:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newPosition animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat frame:(CGRect)frame corners:(BOOL)corners colorsAndWidth:(NSDictionary*)dict
{
    if (current > max || newPosition > max || CGRectIsEmpty(frame)) //sanity check
        return NO;
    UIColor *backgroundColor = [dict objectForKey:kCircularProgressViewBgroundColorKey];
    if (!backgroundColor)
        backgroundColor = [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.];
    UIColor *backgroundCircleColor = [dict objectForKey:kCircularProgressViewBgroundCircleColorKey];
    if (!backgroundCircleColor)
        backgroundCircleColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.];
    UIColor *animatingCircleColor = [dict objectForKey:kCircularProgressViewAnimatingCircleColorKey];
    if (!animatingCircleColor)
        animatingCircleColor = [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.];
    UIColor *textColor = [dict objectForKey:kCircularProgressViewTextColorKey];
    if (!textColor)
        textColor = [UIColor blackColor];
    NSNumber *backgroundCircleWidth = [dict objectForKey:kCircularProgressViewBgroundCircleWidthKey];
    if (!backgroundCircleWidth)
        backgroundCircleWidth = @(2); // default;
    NSNumber *animatingCircleWidth = [dict objectForKey:kCircularProgressViewAnimatingCircleWidthKey];
    if (!animatingCircleWidth)
        animatingCircleWidth = @(8);
    [self removeCircularProgressView];

    CAShapeLayer *shapeLayer;
    if (corners) {
        shapeLayer = [CAShapeLayer layer];
        shapeLayer.zPosition = CGFLOAT_MAX;
        shapeLayer.frame = frame;
        shapeLayer.backgroundColor = backgroundColor.CGColor;
        shapeLayer.name = kCircularProgressViewBgroundShapeLayerName;
        [self.layer addSublayer:shapeLayer];
    }
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.zPosition = CGFLOAT_MAX;
    shapeLayer.frame = frame;
    CGFloat sqSize = MIN(CGRectGetWidth(shapeLayer.bounds), CGRectGetHeight(shapeLayer.bounds));
    CGRect bounds = CGRectMake((CGRectGetWidth(shapeLayer.bounds) - sqSize) / 2., (CGRectGetHeight(shapeLayer.bounds) - sqSize) / 2., sqSize, sqSize);
    CGFloat inset = ([animatingCircleWidth floatValue] - [backgroundCircleWidth floatValue]) / 2.;
    shapeLayer.bounds = CGRectInset(bounds, inset, inset);
    CGPoint center = CGPointMake( shapeLayer.bounds.origin.x + CGRectGetWidth(shapeLayer.bounds) / 2., shapeLayer.bounds.origin.y + CGRectGetHeight(shapeLayer.bounds) / 2.);
    inset = [backgroundCircleWidth floatValue] / 2.;
    bounds = CGRectInset(shapeLayer.bounds, inset, inset);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center radius:bounds.size.height / 2. startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = backgroundCircleColor.CGColor;
    shapeLayer.fillColor = backgroundColor.CGColor;
    shapeLayer.lineWidth = [backgroundCircleWidth floatValue];
    shapeLayer.strokeStart = 0.;
    shapeLayer.strokeEnd = 1.;
    shapeLayer.name = kCircularProgressViewShapeLayerName;

    CAShapeLayer *sliderLayer = [CAShapeLayer layer];
    sliderLayer.zPosition = CGFLOAT_MAX;
    sliderLayer.frame = frame;
    sliderLayer.bounds = shapeLayer.bounds;
    sliderLayer.path = path.CGPath;
    sliderLayer.strokeColor = animatingCircleColor.CGColor;
    sliderLayer.fillColor = backgroundColor.CGColor;
    sliderLayer.lineWidth = [animatingCircleWidth floatValue];
    sliderLayer.strokeStart = sliderLayer.strokeEnd = 0.;

    [shapeLayer addSublayer:sliderLayer];

    //additional 1 transparent to get bounds fitted in round!!
    CATextLayer *txtLayer = [CATextLayer layer];
    txtLayer.zPosition = CGFLOAT_MAX;
    CGFloat sqSize1 = (( sqSize - [animatingCircleWidth floatValue] - [backgroundCircleWidth floatValue] ) / 2.) * sqrtf(2.);
    inset = (sqSize - sqSize1) / 2.;
    txtLayer.frame = CGRectInset(shapeLayer.bounds, inset, inset);
    txtLayer.backgroundColor = backgroundColor.CGColor;//animatingCircleColor.CGColor;
    txtLayer.foregroundColor = textColor.CGColor;
    txtLayer.name = [NSString stringWithFormat:@"%tu,%tu", max, current];//[@(current) stringValue];
    txtLayer.alignmentMode = kCAAlignmentCenter;
    txtLayer.contentsGravity = kCAGravityBottom;

    //need to caclulate frame for goal-1 first because it is widest themn we roll to current
    CTFontRef fontRef = CTFontCreateWithName(CFSTR("HelveticaNeue-Thin"), 26.0, NULL);//"HelveticaNeue-Light""Baskerville"
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[@(0) stringValue]
                                                attributes:@{ (NSString *)kCTFontAttributeName: CFBridgingRelease(fontRef),
                                                              (NSString *)kCTForegroundColorAttributeName: (__bridge id)textColor.CGColor,
                                                              NSBackgroundColorAttributeName: backgroundColor}];
    txtLayer.string = attrStr;

    [shapeLayer addSublayer:txtLayer];

    [self.layer addSublayer:shapeLayer];
    
    return [self animateCircularProgressView:shapeLayer max:max currentPosition:current newPosition:newPosition newColors:nil animationDuration:duration repeat:repeat force:YES];
}

-(void) removeCircularProgressView
{
    [[self findCircularProgressViewShapelayer:kCircularProgressViewShapeLayerName] removeFromSuperlayer];
    [[self findCircularProgressViewShapelayer:kCircularProgressViewBgroundShapeLayerName] removeFromSuperlayer];
}

-(BOOL) setCircularProgressViewCurrentPosition:(NSUInteger)newCurrent newColorsAndWidth:(NSDictionary*)dict animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat
{
    NSUInteger max, current;
    CAShapeLayer *shapeLayer;
    if ((shapeLayer = [self getCircularProgressViewMax:&max andCurrent:&current]))
        return [self animateCircularProgressView:shapeLayer max:max currentPosition:current newPosition:newCurrent newColors:dict animationDuration:duration repeat:repeat force:NO];
    else
        return NO;
}

-(CAShapeLayer *) getCircularProgressViewMax:(NSUInteger *)max andCurrent:(NSUInteger *)current
{
    CAShapeLayer *shapeLayer = [self findCircularProgressViewShapelayer:kCircularProgressViewShapeLayerName];
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    if (!txtLayer)
        return nil;
    if (sscanf([txtLayer.name cStringUsingEncoding:NSUTF8StringEncoding], "%tu,%tu", max, current) != 2 )
        return nil;
//    NSLog(@"%s %tu,%tu", __func__, *max, *current);
    return shapeLayer;
}

#pragma mark private instance methods

-(BOOL) animateCircularProgressView:(CAShapeLayer *)shapeLayer max:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newCurrent newColors:(NSDictionary*)colors animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat force:(BOOL)force
{
    if (!shapeLayer || current > max || newCurrent > max) //sanity check
        return NO;
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    CAShapeLayer *sliderLayer = (CAShapeLayer *)shapeLayer.sublayers[0];

    UIColor *backgroundColor = [colors objectForKey:kCircularProgressViewBgroundColorKey];
    if (backgroundColor) {
        [self findCircularProgressViewShapelayer:kCircularProgressViewBgroundShapeLayerName].backgroundColor = backgroundColor.CGColor;
        shapeLayer.fillColor = backgroundColor.CGColor;
        sliderLayer.fillColor = backgroundColor.CGColor;
        txtLayer.backgroundColor = backgroundColor.CGColor;
    }
    UIColor *backgroundCircleColor = [colors objectForKey:kCircularProgressViewBgroundCircleColorKey];
    if (backgroundCircleColor)
        shapeLayer.strokeColor = backgroundCircleColor.CGColor;
    UIColor *animatingCircleColor = [colors objectForKey:kCircularProgressViewAnimatingCircleColorKey];
    if (animatingCircleColor)
        sliderLayer.strokeColor = animatingCircleColor.CGColor;
    UIColor *txtColor = [colors objectForKey:kCircularProgressViewTextColorKey];
    if (txtColor) {
        if (!CGColorEqualToColor(txtLayer.foregroundColor, txtColor.CGColor)) {
            txtLayer.foregroundColor = txtColor.CGColor;
            force = YES;
        }
    }
    if (current == newCurrent && !force)
        return YES;
    NSUInteger cur = current;
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
    if (steps > kCircularProgressViewKeyFrameLimit) {
        step *= steps / kCircularProgressViewKeyFrameLimit;
        steps = kCircularProgressViewKeyFrameLimit;
    }
    NSMutableArray *valuesStr = [NSMutableArray arrayWithCapacity:steps + 2];
    NSMutableArray *valuesBounds = [NSMutableArray arrayWithCapacity:steps + 2];
    CGRect newBounds;
    CGFloat fontSize = 0;
    valuesStr[0] =  [txtLayer.string fitToFrame:txtLayer.frame newString:[@(cur) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
    valuesBounds[0] = [NSValue valueWithCGRect:newBounds];
    NSUInteger i;
    for (i = 1; i < steps; i++) {
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
    CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = duration;
    pathAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    pathAnimation.fromValue = @(((CGFloat)current) / max);
    pathAnimation.toValue = @(((CGFloat)newCurrent) / max);
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [sliderLayer addAnimation:pathAnimation forKey:nil];
    return YES;
}

-(CAShapeLayer *) findCircularProgressViewShapelayer: (NSString *)layerName
{
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]] && [layer.name isEqualToString:layerName])
            return (CAShapeLayer *)layer;
    }
    return nil;
}

@end
