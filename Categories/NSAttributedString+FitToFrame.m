//
//  NSAttributedString+FitToFrame.m
//  Vladimir's FitFrame
//
//  Created by Vladimir Doukhanine on 2/11/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "NSAttributedString+FitToFrame.h"

CG_INLINE
BOOL CGSizeContainsSize(CGSize x, CGSize y)
{
    if ( y.width <= x.width && y.height <= x.height)
        return YES;
    else
        return NO;
}

@implementation NSAttributedString (FitToFrame)

-(NSAttributedString *) fitToFrame:(CGRect)frame newString:(NSString *)newStr newTextColor:(UIColor*)textColor returnNewBounds:(CGRect*)bounds
{
    NSMutableAttributedString *outStr;
    if (newStr) {
        NSDictionary *dict = [self attributesAtIndex:0 effectiveRange:NULL];
        //NSLog(@"%@", dict);
        outStr = [[NSMutableAttributedString alloc] initWithString:newStr attributes:dict];
    } else
        outStr = [self mutableCopy];
    [outStr enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, outStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            UIFont *newFont = (UIFont *)value;
            UIFont *prevFont;
            CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
            CGRect curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            CGFloat diff = 0.;
            BOOL fromSmall = NO, fromBig = NO;
            do {
                prevFont = newFont;
                *bounds = curBounds;
                if (CGSizeContainsSize(frame.size, curBounds.size)) { //smaller
                    fromSmall = YES;
                    if (!fromBig)
                        diff = prevFont.pointSize;
                    else
                        diff /= 2;
                    newFont = [prevFont fontWithSize:prevFont.pointSize + diff];
                } else { //bigger
                    fromBig = YES;
                    if (!fromSmall)
                        diff = prevFont.pointSize;
                    else
                        diff /= 2;
                    newFont = [prevFont fontWithSize:prevFont.pointSize - diff];
                }
                [outStr removeAttribute:NSFontAttributeName range:range];
                [outStr addAttribute:NSFontAttributeName value:newFont range:range];
                curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                if (diff <= 1)
                    break;
            } while (1);
            if (textColor) {
                [outStr removeAttribute:NSForegroundColorAttributeName range:range];
                [outStr addAttributes:@{(NSString *)kCTForegroundColorAttributeName: (__bridge id)textColor.CGColor} range:range];
            }
            (*bounds).origin.x += (frame.size.width - (*bounds).size.width) / 2.;
            (*bounds).origin.y += (frame.size.height - (*bounds).size.height) / 2.;
            *stop = YES;
        }
    }];
    return outStr;
}

@end
