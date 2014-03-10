//
//  NSAttributedString+FitToFrame.h
//  Vladimir's FitToFrame
//
//  Created by Vladimir Doukhanine on 2/11/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (FitToFrame)

-(NSAttributedString *) fitToFrame:(CGRect)frame newString:(NSString *)newStr newTextColor:(UIColor*)textColor returnNewBounds:(CGRect*)bounds;

@end
