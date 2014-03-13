//
//  ManageableVolumeView.m
//  CircularProgressViewTest
//
//  Created by Vladimir Doukhanine on 3/11/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "ManageableVolumeView.h"

@interface ManageableVolumeView()
@property (weak, nonatomic) UISlider *backingSlider;
@property (nonatomic) PopUpView *pop;
@end

@implementation ManageableVolumeView

- (void)setMaximumValue:(float)maximumValue
{
    self.backingSlider.maximumValue = maximumValue;
}

- (float)maximumValue
{
    return self.backingSlider.maximumValue;
}

- (void)setMinimumValue:(float)minimumValue
{
    self.backingSlider.minimumValue = minimumValue;
}

- (float)minimumValue
{
    return self.backingSlider.minimumValue;
}

-(id)initWithFrame:(CGRect)rect
{
    if ((self = [super initWithFrame:rect]))
        [self setup];
    return self;
}

-(id)initWithCoder:(NSCoder*)coder //up from storyboard
{
    if ((self = [super initWithCoder:coder]))
        [self setup];
    return self;
}

- (void)touchDown:(id)sender
{
    [self update];
    [self show:YES];
}

- (void)touchUp:(id)sender
{
    [self show:NO];
}

- (void)setup
{
    for (UIView *view in [self subviews]) {
        NSLog(@"%@ %@",[[view class] description], view);
		if ([view isKindOfClass:[UISlider class]]) {
			self.backingSlider = (UISlider *)view;
            break;
		}
    }
    if (self.backingSlider) {
        self.pop = [[PopUpView alloc] initWithFrame:[self getThumbRect]];
        self.pop.alpha = 0;
        [self.backingSlider addSubview:self.pop];
        [self.backingSlider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
        [self.backingSlider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self.backingSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.backingSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)changeVolume:(id)sender
{
    //NSLog(@"Volume:%tu", (NSUInteger)(self.backingSlider.value  * 100. + .5));
    [self update];
}

- (void) setValue:(float)value
{
    self.backingSlider.value = value;
}

- (void)show:(BOOL)show
{
    [UIView beginAnimations:@"popup" context:NULL];
    [UIView setAnimationDuration:.2];
    if (show)
        self.pop.alpha = 1;
    else
        self.pop.alpha = 0;
    [UIView commitAnimations];
}

-(void)update
{
    CGRect thumbRect = [self getThumbRect];
    self.pop.frame = CGRectOffset(thumbRect, 0, -thumbRect.size.height -5);
    CircularProgressViewAnimatingCompletionBlock completion = ^{
        //NSLog(@"Completion");
        BOOL restore = NO;
        if (0 == self.pop.alpha) {
            self.pop.alpha = 1;
            restore = YES;
        }
        UIGraphicsBeginImageContextWithOptions(self.pop.layer.bounds.size, self.pop.layer.opaque, 0);
        [self.pop.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.backingSlider setThumbImage:img forState:UIControlStateNormal];
        if (restore)
            self.pop.alpha = 0;
    };
    if (self.backingSlider.value > self.backingSlider.maximumValue)
        self.backingSlider.value = self.backingSlider.maximumValue;
    else if (self.backingSlider.value < self.backingSlider.minimumValue)
        self.backingSlider.value = self.backingSlider.minimumValue;
    [self.pop set:self.backingSlider.value completion:completion];
}

- (CGRect)getThumbRect
{
    return [self.backingSlider thumbRectForBounds:self.backingSlider.bounds trackRect:[self.backingSlider trackRectForBounds:self.backingSlider.bounds] value:self.backingSlider.value];
}

- (void)dealloc
{
    [self.backingSlider removeTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
    [self.backingSlider removeTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [self.backingSlider removeTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.backingSlider removeTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
}

@end


@implementation PopUpView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        NSDictionary *dict = @{kCircularProgressViewBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1],
                               kCircularProgressViewBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                               kCircularProgressViewAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1],
                               kCircularProgressViewTextColorKey: [UIColor blackColor/*colorWithRed:0. green:1. blue:22./255. alpha:1.*/],
                               kCircularProgressViewBgroundCircleWidthKey: @(2),
                               kCircularProgressViewAnimatingCircleWidthKey: @(3)};
        [self.layer addCircularProgressViewWithMax:100 currentPosition:0 newPosition:0 animationDuration:0. repeat:NO frame:self.layer.bounds corners:NO colorsAndWidth:dict completion:nil];    }
    return self;
}

- (void)set:(float)value completion:(CircularProgressViewAnimatingCompletionBlock)completionBlock
{
    [self.layer setCircularProgressViewCurrentPosition:(NSUInteger)(value * 100. + .5) newColorsAndWidth:nil animationDuration:0 repeat:NO completion:completionBlock];
}

@end

