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
@property (nonatomic) CircularProgressView *pop;

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

- (void)touchDown:(id)sender
{
    [self update];
    [self.pop show:YES animated:YES duration:.2];
}

- (void)touchUp:(id)sender
{
    [self.pop show:NO animated:YES duration:.2];
}

- (void)setup
{
    for (UIView *view in [self subviews]) {
        //NSLog(@"%@ %@", [[view class] description], view);
		if ([view isKindOfClass:[UISlider class]]) {
			self.backingSlider = (UISlider *)view;
            break;
		}
    }
    if (self.backingSlider) {
        self.pop = [[CircularProgressView alloc] initWithFrame:[self getThumbRect]];
        self.pop.alpha = 0;
        [self.backingSlider addSubview:self.pop];
        [self.backingSlider addTarget:self action:@selector(changeVolume:) forControlEvents:UIControlEventValueChanged];
        [self.backingSlider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [self.backingSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.backingSlider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [self update];
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

- (void)update
{
    CGRect rect = [self getThumbRect];
    self.pop.frame = CGRectOffset(rect, 0, -(rect.size.height + 1));
    ManageableVolumeView * __weak weakSelf = self;
    CircularProgressViewAnimatingCompletionBlock completion = ^{
        ManageableVolumeView *strongSelf = weakSelf;
        //NSLog(@"Completion");
        if (0 == strongSelf.pop.alpha) {
            strongSelf.pop.alpha = 1;
            UIGraphicsBeginImageContextWithOptions(strongSelf.pop.layer.bounds.size, strongSelf.pop.layer.opaque, 0);
            [strongSelf.pop.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [strongSelf.backingSlider setThumbImage:img forState:UIControlStateNormal];
            strongSelf.pop.alpha = 0;
        } else
            [strongSelf.backingSlider setThumbImage:nil forState:UIControlStateNormal];
    };
    if (self.backingSlider.value > self.backingSlider.maximumValue)
        self.backingSlider.value = self.backingSlider.maximumValue;
    else if (self.backingSlider.value < self.backingSlider.minimumValue)
        self.backingSlider.value = self.backingSlider.minimumValue;
    [self.pop set:self.backingSlider.value completion:completion newColorsAndWidth:nil];
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