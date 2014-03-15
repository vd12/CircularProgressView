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

-(NSAttributedString *) fitToFrame:(CGRect)frame newString:(NSString *)newStr newColor:(UIColor*)color prevFontSize:(CGFloat*)prevFontSize returnNewBounds:(CGRect*)bounds
{
    NSMutableAttributedString *outStr;
    if (newStr) {
        NSDictionary *dict = [self attributesAtIndex:0 effectiveRange:NULL];
        outStr = [[NSMutableAttributedString alloc] initWithString:newStr attributes:dict];
    } else
        outStr = [self mutableCopy];
    [outStr enumerateAttribute:(NSString *)kCTFontAttributeName inRange:NSMakeRange(0, outStr.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value) {
            //UIFont *newFont = (UIFont *)value;
            CFStringRef fontNameRef = (CFStringRef)CFBridgingRetain([(UIFont *)value fontName]);
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
                            diff = CTFontGetSize(prevFontRef) / 2;
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
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) + 1 , NULL);
                    } else { //bigger
                        fromBig = YES;
                        if (prevFontRef)
                            CFRelease(prevFontRef);
                        prevFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(newFontRef), NULL);
                        CFRelease(newFontRef);
                        newFontRef = CTFontCreateWithName(fontNameRef, CTFontGetSize(prevFontRef) - 1 , NULL);
                    }
                    [outStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)newFontRef range:range];
                    curBounds = [outStr boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                } while (1);
            }
            *prevFontSize = CTFontGetSize(newFontRef);
            CFRelease(fontNameRef);
            CFRelease(newFontRef);
            CFRelease(prevFontRef);
            if (color)
                [outStr addAttributes:@{(NSString *)kCTForegroundColorAttributeName: (__bridge id)color.CGColor} range:range];
            (*bounds).origin.x += (frame.size.width - (*bounds).size.width) / 2.;
            (*bounds).origin.y += (frame.size.height - (*bounds).size.height) / 2.;
            *stop = YES;
        }
    }];
    return outStr;
}

@end
