//
//  CircularProgressView.h
//  CircularProgressViewTest
//
//  Created by Vladimir Doukhanine on 3/13/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CALayer+CircularProgress.h"

@interface CircularProgressView : UIView

- (void)set:(float)value completion:(CircularProgressAnimatingCompletionBlock)completionBlock newColorsAndWidth:(NSDictionary *)dict;
- (void)show:(BOOL)show animated:(BOOL)animated duration:(NSTimeInterval)duration;

@end
