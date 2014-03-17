//
//  UIView+CircularProgress.h
//  Vladimir's CircularProgress
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCircularProgressBgroundColorKey = @"bgroundColor";
static NSString *kCircularProgressBgroundCircleColorKey = @"bgroundCircleColor";
static NSString *kCircularProgressAnimatingCircleColorKey = @"animatingCircleColor";
static NSString *kCircularProgressTextColorKey = @"textColor";
static NSString *kCircularProgressBgroundCircleWidthKey = @"circleWidth";
static NSString *kCircularProgressAnimatingCircleWidthKey = @"animatingCircleWidth";

typedef void (^CircularProgressAnimatingCompletionBlock)(void);

@interface CALayer (CircularProgress)
// current from 0 to (goal - 1)!!!
// return -1 in case of error otherwise current or goal
- (BOOL)addCircularProgressWithMax:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newPosition animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat frame:(CGRect)frame corners:(BOOL)corners colorsAndWidth:(NSDictionary*)dict completion:(CircularProgressAnimatingCompletionBlock)completionBlock;
- (void)removeCircularProgress;
- (BOOL)setCircularProgressCurrentPosition:(NSUInteger)newCurrent newColorsAndWidth:(NSDictionary*)colors animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressAnimatingCompletionBlock)completionBlock;
- (CAShapeLayer *)getCircularProgressMax:(NSUInteger *)max andCurrent:(NSUInteger *)current;

@end
