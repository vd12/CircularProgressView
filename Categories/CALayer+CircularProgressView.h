//
//  UIView+CircularProgressView.h
//  Vladimir's CircularProgressView
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCircularProgressViewBgroundColorKey = @"bgroundColor";
static NSString *kCircularProgressViewBgroundCircleColorKey = @"bgroundCircleColor";
static NSString *kCircularProgressViewAnimatingCircleColorKey = @"animatingCircleColor";
static NSString *kCircularProgressViewTextColorKey = @"textColor";
static NSString *kCircularProgressViewBgroundCircleWidthKey = @"circleWidth";
static NSString *kCircularProgressViewAnimatingCircleWidthKey = @"animatingCircleWidth";

typedef void (^CircularProgressViewAnimatingCompletionBlock)(void);

@interface CALayer (CircularProgressView)
// current from 0 to (goal - 1)!!!
// return -1 in case of error otherwise current or goal
-(BOOL) addCircularProgressViewWithMax:(NSUInteger)max currentPosition:(NSUInteger)current newPosition:(NSUInteger)newPosition animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat frame:(CGRect)frame corners:(BOOL)corners colorsAndWidth:(NSDictionary*)dict completion:(CircularProgressViewAnimatingCompletionBlock)completionBlock;
-(void) removeCircularProgressView;
-(BOOL) setCircularProgressViewCurrentPosition:(NSUInteger)newCurrent newColorsAndWidth:(NSDictionary*)colors animationDuration:(NSTimeInterval)duration repeat:(BOOL)repeat completion:(CircularProgressViewAnimatingCompletionBlock)completionBlock;
-(CAShapeLayer *) getCircularProgressViewMax:(NSUInteger *)max andCurrent:(NSUInteger *)current;

@end
