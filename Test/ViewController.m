//
//  ViewController.m
//  Vladimir's RoundSlider Test
//
//  Created by Vladimir Doukhanine on 2/9/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import "ViewController.h"
#import "UIView+CircularProgressView.h"

@interface ViewController ()
- (IBAction)pressButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *buttonPress;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *rightView;
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
        [self.leftView addCircularProgressViewWithMax:59 currentPosition:0 newPosition:59 animationDuration:60. repeat:YES frame:self.leftView.bounds corners:YES colorsAndWidth:dict];
    NSLog(@"%s %d,", __func__, ret);
    
    ret = [self.rightView addCircularProgressViewWithMax:59 currentPosition:59 newPosition:0 animationDuration:60. repeat:YES frame:self.rightView.bounds corners:NO colorsAndWidth:dict];
    NSLog(@"%s %d,", __func__, ret);
}

- (IBAction)pressButton:(UIButton*)sender
{
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Press"]) {
        NSDictionary *dict = @{kCircularProgressViewBgroundColorKey: [UIColor colorWithRed:0. green:172./255. blue:237./255. alpha:1.],
                                 kCircularProgressViewBgroundCircleColorKey: [UIColor colorWithRed:0. green:0. blue:0. alpha:1.],
                                 kCircularProgressViewAnimatingCircleColorKey: [UIColor colorWithRed:0. green:1. blue:22./255. alpha:1.],
                                 kCircularProgressViewTextColorKey: [UIColor whiteColor]};
        if ([sender addCircularProgressViewWithMax:314 currentPosition:0 newPosition:314 animationDuration:2. repeat:NO frame:sender.bounds corners:NO colorsAndWidth:dict])
            [sender setTitle:@"" forState:UIControlStateNormal];
        NSLog(@"Pressed %@", sender);
    } else {
        [sender setTitle:@"Press" forState:UIControlStateNormal];
        [sender removeCircularProgressView];
        NSLog(@"Depressed... %@", sender);
    }
}

- (IBAction)swipe:(UISwipeGestureRecognizer *)sender
{
    NSUInteger max, current;
    BOOL ret = NO;
    int inc = 0;
    if ([self.buttonPress getCircularProgressViewMax:&max andCurrent:&current]) {
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
        NSDictionary *dict = @{kCircularProgressViewTextColorKey: [UIColor colorWithRed:(arc4random() % 255 / 255.) green:(arc4random() % 255 / 255.) blue:(arc4random() % 255 / 255.) alpha:1.]};
        ret = [self.buttonPress setCircularProgressViewCurrentPosition:current + inc newColorsAndWidth:dict animationDuration: 1. repeat:NO];
        [self.buttonPress getCircularProgressViewMax:&max andCurrent:&current];
        NSLog(@"%s %d New:%tu", __func__, ret, current);
    }
}
@end
