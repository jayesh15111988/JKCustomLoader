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
-(void)loadViewWithPartialCompletionBlock:(void (^)(CGFloat partialCompletionPercentage))partialCompletion andCompletionBlock:(void (^)())completion;

@property (strong) UIImage* maskImage;
@property (assign) CGFloat numberOfVerticesForPolygon;
@property (assign) CGFloat pointinessForStarCorners;
@property (assign) CGFloat numberOfFramesPerSecond;
@property (assign) CGFloat maskSizeIncrementPerFrame;

@end