//
//  JKBezierStarDrawer.m
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/21/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKBezierStarDrawer.h"
#import <Foundation/Foundation.h>

/* Source : http://sketchytech.blogspot.com/2014/11/swift-stars-in-our-paths-cgpath.html */

@implementation JKBezierStarDrawer

-(CGFloat)degreeToRadianWithDegreeAngle:(CGFloat)angleInDegress {
    CGFloat b =  ((CGFloat)M_PI * (angleInDegress/180));
    return b;
}

-(NSArray*)polygonPointArrayWithSide:(NSInteger)sides andX:(CGFloat)x andY:(CGFloat)y andRadius:(CGFloat)radius andAdjustment:(CGFloat)adjustment {
    CGFloat angle = [self degreeToRadianWithDegreeAngle:(360/(CGFloat)sides)];
    CGFloat cx = x; // x origin
    CGFloat cy = y; // y origin
    CGFloat r  = radius; // radius of circle
    NSInteger i = sides;
    NSMutableArray* points = [NSMutableArray new];
    while ([points count] <= sides) {
        CGFloat xpo = cx - r * cos(angle * (CGFloat)i + [self degreeToRadianWithDegreeAngle:adjustment]);
        CGFloat ypo = cy - r * sin(angle * (CGFloat)i + [self degreeToRadianWithDegreeAngle:adjustment]);
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(xpo, ypo)]];
        i--;
    }
    return points;
}

-(CGPathRef)starPathWithX:(CGFloat)x andY:(CGFloat)y andRadius:(CGFloat)radius andSides:(NSInteger)sides andPointiness:(CGFloat)pointiness  {
    CGFloat adjustment = (CGFloat)(360/sides/2);
    CGMutablePathRef path = CGPathCreateMutable();
    NSArray* points = [self polygonPointArrayWithSide:sides andX:x andY:y andRadius:radius andAdjustment:adjustment];
    
    NSValue* rawValue = points[0];
    CGPoint cpg = [rawValue CGPointValue];
    NSArray* points2 = [self polygonPointArrayWithSide:sides andX:x andY:y andRadius:(radius*pointiness) andAdjustment:(CGFloat)adjustment];
    NSInteger i = 0;
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y);
    for (NSValue* p in points) {
        CGPoint point = [p CGPointValue];
        NSValue* valueFromPoints2 = points2[i];
        CGPoint pointFromValue2 = [valueFromPoints2 CGPointValue];
        CGPathAddLineToPoint(path, nil, pointFromValue2.x, pointFromValue2.y);
        CGPathAddLineToPoint(path, nil, point.x, point.y);
        i++;
    }
    CGPathCloseSubpath(path);
    return path;
}

-(UIBezierPath*) drawStarBezierWithX:(CGFloat)x andY:(CGFloat)y andRadius:(CGFloat)radius andSides:(NSInteger)sides andPointiness:(CGFloat)pointiness {
    CGPathRef path = [self starPathWithX:x andY:y andRadius:radius andSides:sides andPointiness:pointiness];
    UIBezierPath* bez = [UIBezierPath bezierPathWithCGPath:path];
    return bez;
}

@end
