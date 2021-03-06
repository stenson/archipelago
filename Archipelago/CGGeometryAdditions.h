//
//  CGGeometryAdditions.h
//  CanOpener
//
//  Created by Robert Stenson on 6/12/13.
//  Copyright (c) 2013 Good Hertz. All rights reserved.
//

#ifndef CanOpener_CGGeometryAdditions_h
#define CanOpener_CGGeometryAdditions_h

#define RADIANS_FROM_DEGREES(x) (M_PI * (x) / 180.0)
#define DEGREES_FROM_RADIANS(x) ((180.0 / M_PI) * (x))

static CGRect CGRectGetCenteredSquare(CGRect rect)
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat minX = CGRectGetMinX(rect);
    CGFloat minY = CGRectGetMinY(rect);
    CGRect square;
    
    if (width > height) {
        square = CGRectMake(minX + (width - height) / 2.f, minY, height, height);
    } else {
        square = CGRectMake(minX, minY + (height - width) / 2.f, width, width);
    }
    
    return square;
}

/*  supports nulls for slice & remainder,
 if amount is less than 1, it's used as a percentage
 of the rect's relevant height/width (depending on edge) */

static CGRect CGRectSegment(CGRect rect, CGRect *slice, CGRect *remainder, CGFloat amount, CGRectEdge edge)
{
    CGRect nullSlice;
    CGRect nullRemainder;
    
    if (amount < 1.0) {
        CGFloat dimension = (edge == CGRectMinYEdge || edge == CGRectMaxYEdge) ? rect.size.height : rect.size.width;
        if (amount < 0) {
            amount = dimension + amount;
        } else {
            amount = floorf(dimension * amount);
        }
    }
    
    CGRectDivide(rect, slice ? slice : &nullSlice, remainder ? remainder : &nullRemainder, amount, edge);
    
    if (!slice) {
        return nullSlice;
    } else if (!remainder) {
        return nullRemainder;
    } else {
        return CGRectZero;
    }
}

static CGRect CGRectTake(CGRect rect, CGFloat amount, CGRectEdge edge)
{
    return CGRectSegment(rect, NULL, NULL, amount, edge);
}

static CGRect CGRectTakeFromCenter(CGRect rect, CGFloat amount, BOOL vertically)
{
    CGRect centered = CGRectTake(rect, amount, vertically ? CGRectMinYEdge : CGRectMinXEdge);
    if (vertically) {
        centered.origin.y += rect.size.height/2.f;
        centered.origin.y -= amount/2.f;
    } else {
        centered.origin.x += rect.size.width/2.f;
        centered.origin.x -= amount/2.f;
    }
    return centered;
}

static void CGRectDivideRectIntoEqualSubs(CGRect rect, CGRect subs[], NSInteger count, CGRectEdge edge)
{
    CGRect piece;
    for (NSInteger i = count; i > 1; i--) {
        CGRectSegment(rect, &piece, &rect, 1.f/(CGFloat)i, edge);
        subs[count-i] = piece;
    }
    
    subs[count-1] = rect; // leftover
}

static CGRect CGRectFromZeroOrigin(CGRect rect)
{
    return CGRectMake(0.f, 0.f, rect.size.width, rect.size.height);
}

static void CGContextDrawBorder(CGContextRef context, CGRect rect, CGRectEdge edge)
{
    CGPoint line[2];
    line[0] = CGPointMake(edge == CGRectMaxXEdge ? CGRectGetMaxX(rect) : CGRectGetMinX(rect), edge == CGRectMaxYEdge ? CGRectGetMaxY(rect) : CGRectGetMinY(rect));
    line[1] = CGPointMake(edge == CGRectMinXEdge ? CGRectGetMinX(rect) : CGRectGetMaxX(rect), edge == CGRectMinYEdge ? CGRectGetMinY(rect) : CGRectGetMaxY(rect));
    CGContextStrokeLineSegments(UIGraphicsGetCurrentContext(), line, 2);
}

#endif
