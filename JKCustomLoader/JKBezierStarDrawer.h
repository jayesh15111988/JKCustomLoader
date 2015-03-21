//
//  JKBezierStarDrawer.h
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/21/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JKBezierStarDrawer : NSObject
-(UIBezierPath*) drawStarBezierWithX:(CGFloat)x andY:(CGFloat)y andRadius:(CGFloat)radius andSides:(NSInteger)sides andPointiness:(CGFloat)pointiness;
@end
