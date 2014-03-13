//
//  CircularProgressView.m
//  CircularProgressViewTest
//
//  Created by Vladimir Doukhanine on 3/13/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "CircularProgressView.h"

@implementation CircularProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self setup];
    return self;
}

-(id)initWithCoder:(NSCoder*)coder //up from storyboard
{
    if ((self = [super initWithCoder:coder]))
        [self setup];
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    NSDictionary *dict = @{kCircularProgressViewBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1],
                           kCircularProgressViewBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                           kCircularProgressViewAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1],
                           kCircularProgressViewTextColorKey: [UIColor blackColor/*colorWithRed:0. green:1. blue:22./255. alpha:1.*/],
                           kCircularProgressViewBgroundCircleWidthKey: @(2),
                           kCircularProgressViewAnimatingCircleWidthKey: @(3)};
    [self.layer addCircularProgressViewWithMax:100 currentPosition:0 newPosition:0 animationDuration:0. repeat:NO frame:self.layer.bounds corners:NO colorsAndWidth:dict completion:nil];
    
}

- (void)set:(float)value completion:(CircularProgressViewAnimatingCompletionBlock)completionBlock newColorsAndWidth:(NSDictionary *)dict
{
    [self.layer setCircularProgressViewCurrentPosition:(NSUInteger)(value * 100. + .5) newColorsAndWidth:dict animationDuration:0 repeat:NO completion:completionBlock];
}

- (void)show:(BOOL)show animated:(BOOL)animated duration:(NSTimeInterval)duration
{
    if (animated) {
        [UIView beginAnimations:@"show" context:NULL];
        [UIView setAnimationDuration:duration];
    }
    if (show)
        self.alpha = 1;
    else
        self.alpha = 0;
    if (animated)
        [UIView commitAnimations];
}

@end

