//
//  ViewController.m
//  Vladimir's RoundSlider Test
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "ViewController.h"
#import "CALayer+CircularProgressView.h"
#import "ManageableVolumeView.h"

@interface ViewController ()
- (IBAction)pressButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonPress;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
@property (weak, nonatomic) IBOutlet ManageableVolumeView *volumeView;
@end

@implementation ViewController

-(void) viewDidAppear:(BOOL)animated
{
    NSDictionary *dict = @{kCircularProgressViewBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.],
                             kCircularProgressViewBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                             kCircularProgressViewAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.],
                             kCircularProgressViewTextColorKey: [UIColor redColor],
                             kCircularProgressViewBgroundCircleWidthKey: @(1),
                             kCircularProgressViewAnimatingCircleWidthKey: @(4)};
    BOOL ret =
        [self.leftView.layer addCircularProgressViewWithMax:59 currentPosition:0 newPosition:59 animationDuration:60. repeat:YES frame:self.leftView.bounds corners:YES colorsAndWidth:dict completion:nil];
    NSLog(@"%s %d,", __func__, ret);
    
    ret = [self.rightView.layer addCircularProgressViewWithMax:59 currentPosition:59 newPosition:0 animationDuration:60. repeat:YES frame:self.rightView.bounds corners:NO colorsAndWidth:dict completion:nil];
    NSLog(@"%s %d,", __func__, ret);
    self.volumeView.minimumValue = .25;
    self.volumeView.maximumValue = .75;
    self.volumeView.value = .7;
}

- (IBAction)pressButton:(UIButton*)sender
{
    self.volumeView.value = .3;
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Tap"]) {
        NSDictionary *dict = @{kCircularProgressViewBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.],
                                 kCircularProgressViewBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                                 kCircularProgressViewAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.],
                                 kCircularProgressViewTextColorKey: [UIColor whiteColor]};
        if ([sender.layer addCircularProgressViewWithMax:31415 currentPosition:3141 newPosition:31415 animationDuration:20. repeat:NO frame:sender.bounds corners:NO colorsAndWidth:dict completion:nil])
            [sender setTitle:@"" forState:UIControlStateNormal];
    } else {
        [sender setTitle:@"Tap" forState:UIControlStateNormal];
        [sender.layer removeCircularProgressView];
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    NSUInteger max, current;
    BOOL ret = NO;
    int inc = 0;
    if ([self.buttonPress.layer getCircularProgressViewMax:&max andCurrent:&current]) {
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
        NSDictionary *dict = @{kCircularProgressViewTextColorKey: [UIColor colorWithRed:(arc4random() % 256 / 256.) green:(arc4random() % 256 / 256.) blue:(arc4random() % 256 / 256.) alpha:1.]};
        ret = [self.buttonPress.layer setCircularProgressViewCurrentPosition:current + inc newColorsAndWidth:dict animationDuration: 1. repeat:NO completion:nil];
        [self.buttonPress.layer getCircularProgressViewMax:&max andCurrent:&current];
        NSLog(@"%s %d New:%tu", __func__, ret, current);
    }
}
@end
