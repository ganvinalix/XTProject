//
//  NSAttributedString+EasyToUse.m
//  TuniuSelfDriving
//
//  Created by Ben on 14/12/2.
//  Copyright (c) 2014年 Tuniu. All rights reserved.
//

#import "NSAttributedString+EasyToUse.h"
#import <CoreText/CoreText.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0

#pragma mark - NSAttributedString

@implementation NSAttributedString (EasyToUse)

+ (instancetype)attributedStringWithString:(NSString*)string
{
    if (string)
    {
        return [[self alloc] initWithString:string];
    }
    else
    {
        return nil;
    }
}

+ (instancetype)attributedStringWithAttributedString:(NSAttributedString*)attrStr
{
    if (attrStr)
    {
        return [[self alloc] initWithAttributedString:attrStr];
    }
    else
    {
        return nil;
    }
}

- (CGSize)sizeConstrainedToSize:(CGSize)maxSize
{
    return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}

- (CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange*)fitRange
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self);
    CGSize sz = CGSizeMake(0.f, 0.f);
    if (framesetter)
    {
        CFRange fitCFRange = CFRangeMake(0,0);
        sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
        sz = CGSizeMake( floor(sz.width+1) , floor(sz.height+1) ); // take 1pt of margin for security
        CFRelease(framesetter);
        
        if (fitRange)
        {
            *fitRange = NSMakeRange((NSUInteger)fitCFRange.location, (NSUInteger)fitCFRange.length);
        }
    }
    return sz;
}

@end

#pragma mark - NSMutableAttributedString

@implementation NSMutableAttributedString (EasyToUse)

#pragma mark - Font

-(void)setFont:(UIFont*)font
{
    [self setFontName:font.fontName size:font.pointSize];
}

-(void)setFont:(UIFont*)font range:(NSRange)range
{
    [self setFontName:font.fontName size:font.pointSize range:range];
}

-(void)setFontName:(NSString*)fontName size:(CGFloat)size
{
    [self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}

-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range
{
    [self removeAttribute:NSFontAttributeName range:range];
    [self addAttribute:NSFontAttributeName value:[UIFont fontWithName:fontName size:size] range:range];
}

#pragma mark - Color

-(void)setTextColor:(UIColor*)color
{
    [self setTextColor:color range:NSMakeRange(0,[self length])];
}

-(void)setTextColor:(UIColor*)color range:(NSRange)range
{
    [self removeAttribute:NSForegroundColorAttributeName range:range];
    [self addAttribute:NSForegroundColorAttributeName value:color range:range];
}

- (void)setTextStrikethroughStyle:(NSUnderlineStyle)style
{
    [self setTextStrikethroughStyle:style range:NSMakeRange(0, self.length)];
}

- (void)setTextStrikethroughStyle:(NSUnderlineStyle)style range:(NSRange)range
{
    [self removeAttribute:NSStrikethroughStyleAttributeName range:range];
    [self addAttribute:NSStrikethroughStyleAttributeName value:@(style) range:range];
}

- (void)setTextUnderLineStyle:(NSUnderlineStyle)style
{
    [self setTextUnderLineStyle:style range:NSMakeRange(0, self.length)];
}

- (void)setTextUnderLineStyle:(NSUnderlineStyle)style range:(NSRange)range
{
    [self removeAttribute:NSUnderlineStyleAttributeName range:range];
    [self addAttribute:NSUnderlineStyleAttributeName value:@(style) range:range];
}

- (void)modifyParagraphStylesWithBlock:(void (^)(NSMutableParagraphStyle *paragraphStyle))block
{
    [self modifyParagraphStylesInRange:NSMakeRange(0, self.length) withBlock:block];
}

- (void)modifyParagraphStylesInRange:(NSRange)range withBlock:(void (^)(NSMutableParagraphStyle *))block
{
    NSParameterAssert(block != nil);
    
    NSRangePointer rangePtr = &range;
    NSUInteger loc = range.location;
    [self beginEditing];
    while (NSLocationInRange(loc, range))
    {
        NSParagraphStyle *paraStyle = [self attribute:NSParagraphStyleAttributeName
                                              atIndex:loc
                                longestEffectiveRange:rangePtr
                                              inRange:range];
        if (!paraStyle)
        {
            paraStyle = [NSParagraphStyle defaultParagraphStyle];
        }
        NSMutableParagraphStyle *mutableParaStyle = [paraStyle mutableCopy];
        block(mutableParaStyle);
        [self setParagraphStyle:mutableParaStyle range:*rangePtr];
        
        loc = NSMaxRange(*rangePtr);
    }
    [self endEditing];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle
{
    [self setParagraphStyle:paragraphStyle range:NSMakeRange(0, self.length)];
}

- (void)setParagraphStyle:(NSParagraphStyle *)paragraphStyle range:(NSRange)range
{
    [self removeAttribute:NSParagraphStyleAttributeName range:range];
    [self addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

@end

#endif