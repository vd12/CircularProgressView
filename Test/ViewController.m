//
//  ViewController.m
//  Vladimir's RoundSlider Test
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "ViewController.h"
#import "CALayer+CircularProgress.h"
#import "ManageableVolumeView.h"
#import "DecoratedUISlider.h"

@interface ViewController ()
- (IBAction)pressButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonPress;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet ManageableVolumeView *volumeView;
@property (weak, nonatomic) IBOutlet DecoratedUISlider *slider;
@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    NSDictionary *dict = @{kCircularProgressBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.],
                             kCircularProgressBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                             kCircularProgressAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.],
                             kCircularProgressTextColorKey: [UIColor redColor],
                             kCircularProgressBgroundCircleWidthKey: @(1),
                             kCircularProgressAnimatingCircleWidthKey: @(4)};
    BOOL ret =
        [self.leftView.layer addCircularProgressWithMax:59 currentPosition:0 newPosition:59 animationDuration:60. repeat:YES frame:self.leftView.bounds corners:YES colorsAndWidth:dict completion:nil];
    NSLog(@"%s %d,", __func__, ret);
    
    ret = [self.rightView.layer addCircularProgressWithMax:59 currentPosition:59 newPosition:0 animationDuration:60. repeat:YES frame:self.rightView.bounds corners:NO colorsAndWidth:dict completion:nil];
    NSLog(@"%s %d,", __func__, ret);
    self.volumeView.minimumValue = .25;
    self.volumeView.maximumValue = .75;
    self.volumeView.value = .7;
    self.slider.value = 1.;
}

- (IBAction)pressButton:(UIButton*)sender
{
    self.volumeView.value = .3;
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Tap"]) {
        NSDictionary *dict = @{kCircularProgressBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.],
                                 kCircularProgressBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                                 kCircularProgressAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.],
                                 kCircularProgressTextColorKey: [UIColor whiteColor]};
        if ([sender.layer addCircularProgressWithMax:31415 currentPosition:3141 newPosition:31415 animationDuration:20. repeat:NO frame:sender.bounds corners:NO colorsAndWidth:dict completion:nil])
            [sender setTitle:@"" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Tap" forState:UIControlStateNormal];
        [sender.layer removeCircularProgress];
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    NSUInteger max, current;
    BOOL ret = NO;
    int inc = 0;
    if ([self.buttonPress.layer getCircularProgressMax:&max andCurrent:&current]) {
        NSLog(@"%s %d Old:%tu", __func__, ret, current);
        if ( UISwipeGestureRecognizerDirectionUp & [sender direction] ) {
            inc = 11;
        } else if (UISwipeGestureRecognizerDirectionDown & [sender direction] ) {
            inc = -11;
        } else if (UISwipeGestureRecognizerDirectionRight & [sender direction] ) {
            inc = 1;
        } else if (UISwipeGestureRecognizerDirectionLeft & [sender direction] ) {
            inc = -1;
        }
        NSDictionary *dict = @{kCircularProgressTextColorKey: [UIColor colorWithRed:(arc4random() % 256 / 256.) green:(arc4random() % 256 / 256.) blue:(arc4random() % 256 / 256.) alpha:1.]};
        ret = [self.buttonPress.layer setCircularProgressCurrentPosition:current + inc newColorsAndWidth:dict animationDuration: 1. repeat:NO completion:nil];
        [self.buttonPress.layer getCircularProgressMax:&max andCurrent:&current];
        NSLog(@"%s %d New:%tu", __func__, ret, current);
    }
}
@end
