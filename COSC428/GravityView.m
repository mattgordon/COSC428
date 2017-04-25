//
//  GravityView.m
//  COSC428
//
//  Created by Matt Gordon on 25/04/17.
//  Copyright © 2017 Matt Gordon. All rights reserved.
//

#import "GravityView.h"

@implementation GravityView

double _x = 0;
double _y = 0;

double _lineWidth = 1.0;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

 */

- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    double widthOffset = _lineWidth / 2.0;
    double halfX = rect.size.width / 2.0;
    double halfY = rect.size.height / 2.0;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw axes
    CGContextSetStrokeColorWithColor(ctx, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextMoveToPoint(ctx, rect.size.width / 2.0 - widthOffset, 0);
    CGContextAddLineToPoint(ctx, rect.size.width / 2.0 - widthOffset, rect.size.height);
    CGContextStrokePath(ctx);
    
    CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
    CGContextMoveToPoint(ctx, 0, rect.size.height / 2.0 - widthOffset);
    CGContextAddLineToPoint(ctx, rect.size.width, rect.size.height / 2.0 - widthOffset);
    
    CGContextStrokePath(ctx);
    
    // draw gravity vector
    CGContextSetStrokeColorWithColor(ctx, [[UIColor blueColor] CGColor]);
    CGContextMoveToPoint(ctx, halfX - widthOffset, halfY - widthOffset);
    CGContextAddLineToPoint(ctx, halfX + halfX * _x, halfY + halfY * _y);
    
    CGContextStrokePath(ctx);
}

- (void)updateViewForX:(double)x AndY:(double)y {
    _x = -x; // need to invert x to point the right way...
    _y = y;
    
    [self setNeedsDisplay];
}

@end
