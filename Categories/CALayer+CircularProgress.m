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
static int const kCircularProgressSavedParams = 7;
static NSString *kCircularProgressSaveParamsFormat = @"%u %u %f %f %f %f %f";
// %lf for double scanf!!! and then assighn to cgfloat ccording apple doc
static char const *kCircularProgressScanfParamsFormat = "%u %u %lf %lf %lf %lf %lf";

#pragma mark public instance methods

- (BOOL)addCircularProgressWithMax:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newPosition animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat frame:(CGRect)frame corners:(BOOL)corners colorsAndWidth:(NSDictionary *)dict completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    if (current > max || newPosition > max || CGRectIsEmpty(frame) || !max) //sanity check
        return NO;
    UIColor *bgroundColor = dict[kCircularProgressBgroundColorKey];
    if (!bgroundColor)
        bgroundColor = [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.];
    UIColor *bgroundCircleColor = dict[kCircularProgressBgroundCircleColorKey];
    if (!bgroundCircleColor)
        bgroundCircleColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:1.];
    UIColor *animatingCircleColor = dict[kCircularProgressAnimatingCircleColorKey];
    if (!animatingCircleColor)
        animatingCircleColor = [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.];
    UIColor *textColor = dict[kCircularProgressTextColorKey];
    if (!textColor)
        textColor = [UIColor blackColor];
    NSNumber *bgroundCircleWidth = dict[kCircularProgressBgroundCircleWidthKey];
    if (!bgroundCircleWidth)
        bgroundCircleWidth = @(2); // default;
    NSNumber *animatingCircleWidth = dict[kCircularProgressAnimatingCircleWidthKey];
    if (!animatingCircleWidth)
        animatingCircleWidth = @(8);
    CGFloat inset = MAX([bgroundCircleWidth floatValue], [animatingCircleWidth floatValue]) / 4;
    int space = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame)) - inset * 2;
    if (space < 20)  //sanity check
        return NO;
    [self removeCircularProgress]; // dont add it twice!!!

    if (corners) {
        CAShapeLayer *bshapeLayer = [CAShapeLayer layer];
        bshapeLayer.frame = frame;
        bshapeLayer.backgroundColor = bgroundColor.CGColor;
        bshapeLayer.name = kCircularProgressBgroundShapeLayerName;
        [self addSublayer:bshapeLayer];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = frame;
    CGFloat sqSize = MIN(CGRectGetWidth(shapeLayer.bounds), CGRectGetHeight(shapeLayer.bounds));
    CGRect bounds = CGRectMake((CGRectGetWidth(shapeLayer.bounds) - sqSize) / 2., (CGRectGetHeight(shapeLayer.bounds) - sqSize) / 2., sqSize, sqSize);
    shapeLayer.bounds = CGRectInset(bounds, inset, inset);
    CGPoint center = CGPointMake(shapeLayer.bounds.origin.x + CGRectGetWidth(shapeLayer.bounds) / 2., shapeLayer.bounds.origin.y + CGRectGetHeight(shapeLayer.bounds) / 2.);
    inset = [bgroundCircleWidth floatValue] / 4;
    bounds = CGRectInset(shapeLayer.bounds, inset, inset);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:bounds.size.height / 2. startAngle:-M_PI_2 endAngle:M_PI+M_PI_2 clockwise:YES];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = bgroundCircleColor.CGColor;
    shapeLayer.fillColor = bgroundColor.CGColor;
    shapeLayer.lineWidth = [bgroundCircleWidth floatValue];
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1;
    shapeLayer.name = kCircularProgressShapeLayerName;

    CAShapeLayer *sliderLayer = [CAShapeLayer layer];
    sliderLayer.frame = frame;
    sliderLayer.bounds = shapeLayer.bounds;
    sliderLayer.path = path.CGPath;
    sliderLayer.strokeColor = animatingCircleColor.CGColor;
    sliderLayer.fillColor = bgroundColor.CGColor;
    sliderLayer.lineWidth = [animatingCircleWidth floatValue];
    sliderLayer.strokeStart = sliderLayer.strokeEnd = 0;

    //additional 1 transparent to get bounds fitted in round!!
    CATextLayer *txtLayer = [CATextLayer layer];
    CGFloat sqSize1 = ((sqSize - [animatingCircleWidth floatValue] - [bgroundCircleWidth floatValue]) / 2.) * M_SQRT2;
    inset = (sqSize - sqSize1) / 2;
    txtLayer.frame = CGRectInset(shapeLayer.bounds, inset, inset);
    txtLayer.backgroundColor = bgroundColor.CGColor; //animatingCircleColor.CGColor;
    txtLayer.name = [NSString stringWithFormat:kCircularProgressSaveParamsFormat, (unsigned int)max, (unsigned int)current,
                     (double)txtLayer.frame.origin.x, (double)txtLayer.frame.origin.y, (double)txtLayer.frame.size.width, (double)txtLayer.frame.size.height, 0.]; //[@(current) stringValue];
    txtLayer.alignmentMode = kCAAlignmentCenter;
    txtLayer.contentsGravity = kCAGravityBottom;

    CTFontRef fontRef = CTFontCreateWithName(CFSTR("HelveticaNeue-Thin"), 20.0, NULL); //"Chalkduster""HelveticaNeue-Light""Baskerville""HelveticaNeue-Thin"
    NSAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[@(0) stringValue]
                                                attributes:@{ (NSString *)kCTFontAttributeName:(__bridge id)fontRef,
                                                              (NSString *)kCTForegroundColorAttributeName:(__bridge id)textColor.CGColor}];
    CFRelease(fontRef);
    
    txtLayer.string = attrStr;

    [shapeLayer addSublayer:sliderLayer];
    
    [shapeLayer addSublayer:txtLayer];

    [self addSublayer:shapeLayer];
    
    return [self animateCircularProgress:shapeLayer newPosition:newPosition newColors:nil animationDuration:duration repeat:repeat completion:completionBlock];
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
    [ self removeCircularProgressAnimationsWithLayers:YES];
}

- (BOOL)setCircularProgressCurrentPosition:(NSUInteger)newCurrent newColorsAndWidth:(NSDictionary *)dict animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    return [self animateCircularProgress:[self findCircularProgressShapelayer:kCircularProgressShapeLayerName] newPosition:newCurrent newColors:dict animationDuration:duration repeat:repeat completion:completionBlock];
}

- (CAShapeLayer *)getCircularProgressMax:(NSUInteger *)max andCurrent:(NSUInteger *)current
{
    CAShapeLayer *shapeLayer = [self findCircularProgressShapelayer:kCircularProgressShapeLayerName];
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    if (!txtLayer)
        return nil;
    unsigned int mx, curr;
    if (sscanf([txtLayer.name cStringUsingEncoding:NSASCIIStringEncoding], "%u %u", &mx, &curr) != 2 )
        return nil;
    *max = mx;
    *current = curr;
//    NSLog(@"%s %tu,%tu", __func__, *max, *current);
    return shapeLayer;
}

#pragma mark private instance methods

- (void)removeCircularProgressAnimationsWithLayers:(BOOL)removeLayers
{
    CALayer* layer = [self findCircularProgressShapelayer:kCircularProgressShapeLayerName];
    if (removeLayers) {
        [layer removeFromSuperlayer];
        [[self findCircularProgressShapelayer:kCircularProgressBgroundShapeLayerName] removeFromSuperlayer];
    } else {
        [CATransaction begin];
        for (CALayer* sublayer in [layer sublayers]) {
            [sublayer removeAllAnimations];
        }
        [CATransaction commit];
    }
}

- (BOOL)animateCircularProgress:(CAShapeLayer *)shapeLayer newPosition:(NSUInteger)newCurrent newColors:(NSDictionary *)colors animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressAnimatingCompletionBlock)completionBlock
{
    if (!shapeLayer) //sanity check
        return NO;
    CATextLayer *txtLayer = (CATextLayer *)shapeLayer.sublayers[1];
    NSUInteger max, current;
    double x, y, width, height, fSize;
    unsigned int mx, curr;
    if (sscanf([txtLayer.name cStringUsingEncoding:NSASCIIStringEncoding], kCircularProgressScanfParamsFormat, &mx, &curr, &x, &y, &width, &height, &fSize) != kCircularProgressSavedParams )
        return NO;
    max = (NSUInteger)mx;
    current = (NSUInteger)curr;
    CGRect frame = CGRectMake(x, y, width, height);
    CGFloat fontSize = fSize;
    
    if (current > max || newCurrent > max || CGRectIsEmpty(frame)) //sanity check
        return NO;
    //[ self removeCircularProgressAnimationsWithLayers:NO];
    [CATransaction lock];
    [CATransaction begin];
    CAShapeLayer *sliderLayer = (CAShapeLayer *)shapeLayer.sublayers[0];
    UIColor *bgroundColor = colors[kCircularProgressBgroundColorKey];
    if (bgroundColor) {
        [self findCircularProgressShapelayer:kCircularProgressBgroundShapeLayerName].backgroundColor = bgroundColor.CGColor;
        shapeLayer.fillColor = bgroundColor.CGColor;
        sliderLayer.fillColor = bgroundColor.CGColor;
        txtLayer.backgroundColor = bgroundColor.CGColor;
    }
    UIColor *bgroundCircleColor = colors[kCircularProgressBgroundCircleColorKey];
    if (bgroundCircleColor)
        shapeLayer.strokeColor = bgroundCircleColor.CGColor;
    UIColor *animatingCircleColor = colors[kCircularProgressAnimatingCircleColorKey];
    if (animatingCircleColor)
        sliderLayer.strokeColor = animatingCircleColor.CGColor;
    UIColor *txtColor = colors[kCircularProgressTextColorKey];
    if (txtColor) {
        if (!CGColorEqualToColor(txtLayer.foregroundColor, txtColor.CGColor))
            txtLayer.foregroundColor = txtColor.CGColor;
    }
    //txt & txt bounds
    BOOL inc = (newCurrent >= current) ? YES : NO;
    NSInteger steps = 1, step;
    if (current == newCurrent)
        duration = 0;
    if (duration > 0) {
        steps = inc ? newCurrent - current : current - newCurrent;
        step = 1;
        double fps = steps / duration;
        if (fps > 30) {// > 30FPS?
            step = fps / 30;
            steps /= step;
            if (steps < 1)
                steps = 1;
        }
        if (steps > kCircularProgressKeyFrameLimit) {
            step *= steps / kCircularProgressKeyFrameLimit;
            steps = kCircularProgressKeyFrameLimit;
        }
    } else
        [CATransaction setDisableActions:YES];//disable animation

    NSMutableArray *valuesStr = [NSMutableArray arrayWithCapacity:steps + 1];
    NSMutableArray *valuesBounds = [NSMutableArray arrayWithCapacity:steps + 1];
    NSUInteger i = 0, cur = current;
    CGRect newBounds;
    valuesStr[i] =  [txtLayer.string fitToFrame:frame newString:[@(cur) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
    txtLayer.name = [NSString stringWithFormat:kCircularProgressSaveParamsFormat, (unsigned int)max, (unsigned int)newCurrent, (double)(frame.origin.x), (double)(frame.origin.y), (double)(frame.size.width), (double)(frame.size.height), (double)fontSize];
    valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
    while (++i < steps) { //skip if steps <= 1
        valuesStr[i] = [txtLayer.string fitToFrame:frame newString:[@(cur) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
        valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
        if (inc)
            cur += step;
        else
            cur -= step;
    }
    valuesStr[i] = [txtLayer.string fitToFrame:frame newString:[@(newCurrent) stringValue] newColor:txtColor prevFontSize:&fontSize returnNewBounds:&newBounds];
    valuesBounds[i] = [NSValue valueWithCGRect:newBounds];
    
    //must be before adding animations!!!
    [CATransaction setCompletionBlock:^{
        if (completionBlock) {
            //[self removeCircularProgressAnimationsWithLayers:NO];
            completionBlock();
        }
    }];

    //slider
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = duration;
    pathAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    pathAnimation.fromValue = @(((CGFloat)current) / max);
    pathAnimation.toValue = @(((CGFloat)newCurrent) / max);
    pathAnimation.fillMode = kCAFillModeBoth;//kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [sliderLayer addAnimation:pathAnimation forKey:pathAnimation.keyPath];
    //txt bounds
    CAKeyframeAnimation *boundsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.values = valuesBounds;
    boundsAnimation.duration = duration;
    boundsAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    boundsAnimation.fillMode = kCAFillModeBoth;//kCAFillModeForwards;
    boundsAnimation.removedOnCompletion = NO;
    [txtLayer addAnimation:boundsAnimation forKey:boundsAnimation.keyPath];
    //txt
    CAKeyframeAnimation *txtAnimation = [CAKeyframeAnimation animationWithKeyPath:@"string"];
    txtAnimation.values = valuesStr;
    txtAnimation.duration = duration;
    txtAnimation.repeatCount = repeat ? HUGE_VALF : 0;
    txtAnimation.fillMode = kCAFillModeBoth;//kCAFillModeForwards;
    txtAnimation.removedOnCompletion = NO;
    [txtLayer addAnimation:txtAnimation forKey:txtAnimation.keyPath];

    [CATransaction commit];
    [CATransaction unlock];
    return YES;
}

- (CAShapeLayer *)findCircularProgressShapelayer:(NSString *)layerName
{
    for (CALayer *layer in self.sublayers) {
        if ([layer isKindOfClass:[CAShapeLayer class]] && [layer.name isEqualToString:layerName])
            return (CAShapeLayer *)layer;
    }
    return nil;
}

@end
