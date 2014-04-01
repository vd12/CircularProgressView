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

- (NSAttributedString *)fitToFrame:(CGRect)frame newString:(NSString *)newStr newColor:(UIColor *)color prevFontSize:(CGFloat *)prevFontSize returnNewBounds:(CGRect *)bounds
{
    NSMutableAttributedString *outStr = [self mutableCopy];
    [self enumerateAttribute:(NSString *)kCTFontAttributeName inRange:NSMakeRange(0, self.string.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            if (newStr) {
                [[outStr mutableString ]replaceOccurrencesOfString:outStr.string withString:newStr options:NSCaseInsensitiveSearch range:range];
                range = NSMakeRange(0, newStr.length);
            }
            CFStringRef fontNameRef = (__bridge CFStringRef)[(UIFont *)value fontName];
            CTFontRef newFontRef = CTFontCreateWithName(fontNameRef, [(UIFont *)value pointSize], NULL);
            CTFontRef prevFontRef = NULL;
            CGSize maxSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
            CGFloat diff = 0.;
            BOOL fromSmall = NO, fromBig = NO;
            if (0. == *prevFontSize) {
                CGRect curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                do {
                    if (prevFontRef)
                        CFRelease(prevFontRef);
                    prevFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(newFontRef), NULL);
                    *bounds = curBounds;
                    if (CGSizeContainsSize(frame.size, curBounds.size)) { //smaller
                        fromSmall = YES;
                        if (!fromBig)
                            diff = CTFontGetSize(prevFontRef);
                        else
                            diff /= 2;
                        CFRelease(newFontRef);
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) + diff, NULL);
                    } else { //bigger
                        fromBig = YES;
                        if (!fromSmall)
                            diff = CTFontGetSize(prevFontRef) / 2;
                        else
                            diff /= 2;
                        CFRelease(newFontRef);
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) - diff, NULL);
                    }
                    [outStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)newFontRef range:range];
                    curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                    if (diff <= 1)
                        break;
                } while (1);
            } else {
                CFRelease(newFontRef);
                newFontRef = CTFontCreateWithName(fontNameRef, *prevFontSize, NULL);
                [outStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)newFontRef range:range];
                CGRect curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                do {
                    *bounds = curBounds;
                    if (CGSizeContainsSize(frame.size, curBounds.size)) { //smaller
                        fromSmall = YES;
                        if (fromSmall && fromBig)
                            break;
                        if (prevFontRef)
                            CFRelease(prevFontRef);
                        prevFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(newFontRef), NULL);
                        CFRelease(newFontRef);
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) + .5 , NULL);
                    } else { //bigger
                        fromBig = YES;
                        if (prevFontRef)
                            CFRelease(prevFontRef);
                        prevFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(newFontRef), NULL);
                        CFRelease(newFontRef);
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) - .5 , NULL);
                    }
                    [outStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)newFontRef range:range];
                    curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                } while (1);
            }
            *prevFontSize = CTFontGetSize(newFontRef);
            CFRelease(newFontRef);
            CFRelease(prevFontRef);
            if (color)
                [outStr addAttributes:@{(NSString *)kCTForegroundColorAttributeName: (__bridge id)color.CGColor} range:range];
            (*bounds).origin.x += (frame.size.width - (*bounds).size.width) / 2.;
            (*bounds).origin.y += (frame.size.height - (*bounds).size.height) / 2.;
            *stop = YES;
        }
    }];
    return [outStr copy];
}

@end
