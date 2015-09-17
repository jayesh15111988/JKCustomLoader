//
//  UIImageView+JKCustomLoader.h
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MaskShapeType) {
    MaskShapeTypeCircle,
    MaskShapeTypeRectangle,
    MaskShapeTypeTriangle,
    MaskShapeTypeStar,
    MaskShapeTypeAlphaImage
};

@interface JKCustomLoader:NSObject

-(instancetype)initWithInputView:(UIView*)inputView andAnimationType:(MaskShapeType)animationType;
-(void)loadViewWithCompletionBlock:(void (^)())animationCompletion;

@property (nonatomic, strong) UIImage* maskImage;
@property (nonatomic, assign) CGFloat numberOfVerticesForPolygon;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) NSTimeInterval animationBeginDelay;

@end