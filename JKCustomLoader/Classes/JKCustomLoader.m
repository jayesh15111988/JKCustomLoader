//
//  UIImageView+JKCustomLoader.m
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKCustomLoader.h"
#import "JKBezierStarDrawer.h"

@interface JKCustomLoader ()

@property (strong) UIView* viewToMask;
@property (assign) CGFloat maskSize;
@property (assign) MaskShapeType animationType;
@property (strong) NSTimer* imageMaskingOperationTimer;
@property (assign) CGFloat maximumMaskSize;
@property (assign) CGFloat viewMidX;
@property (assign) CGFloat viewMidY;
@property (assign) CGFloat animationRate;

typedef void (^PartialCompletionBlock)(CGFloat completionPercentage);
@property (strong, nonatomic) PartialCompletionBlock partialCompletionCallback;

typedef void (^CompletionBlock)();
@property (strong, nonatomic) CompletionBlock completionCallback;

@end

@implementation JKCustomLoader

-(instancetype)initWithInputView:(UIView*)inputView andAnimationType:(MaskShapeType)animationType {
    if(self = [super init]) {
        self.viewToMask = inputView;
        self.viewMidX = self.viewToMask.frame.size.width/2;
        self.viewMidY = self.viewToMask.frame.size.height/2;
        self.animationType = animationType;
        //Default values in case we want to draw a polygon
        self.numberOfFramesPerSecond = 60.0;
        self.numberOfVerticesForPolygon = 6;
        self.pointinessForStarCorners = 2;
        self.maskSizeIncrementPerFrame = 3;
    }
    return self;
}

-(void)loadViewWithPartialCompletionBlock:(void (^)(CGFloat partialCompletionPercentage))partialCompletion andCompletionBlock:(void (^)())completion {
    
    self.animationRate = (CGFloat)(1.0/self.numberOfFramesPerSecond);
    self.partialCompletionCallback = partialCompletion;
    self.completionCallback = completion;
    CGFloat maximumViewDimension = MAX(self.viewToMask.frame.size.width, self.viewToMask.frame.size.height);
    if(self.animationType == MaskShapeTypeTriangle) {
        self.maximumMaskSize = (maximumViewDimension/2) + maximumViewDimension * 0.866;
    } else if(self.animationType == MaskShapeTypeStar) {
        self.maximumMaskSize = maximumViewDimension * 0.5;
    } else if(self.animationType == MaskShapeTypeAlphaImage) {
        self.maximumMaskSize = self.maskSizeIncrementPerFrame * (maximumViewDimension/2);
        NSAssert(self.maskImage, @"Masking image cannot be nil when MaskShapeTypeAlphaImage animation mode is selected");
    } else if(self.animationType == MaskShapeTypeCircle) {
        self.maximumMaskSize = [self calculateMaximumMaskDimension];
    } else if (self.animationType == MaskShapeTypeRectangle) {
        self.maximumMaskSize = maximumViewDimension;
    }
    
    self.maskSize = 0.0;
    self.viewToMask.layer.mask = [self getShapeFromRect:CGRectMake((self.viewToMask.frame.size.width - self.maskSize)/2, (self.viewToMask.frame.size.height - self.maskSize)/2, self.maskSize, self.maskSize)];
    self.imageMaskingOperationTimer = [NSTimer timerWithTimeInterval:self.animationRate target:self selector:@selector(updateImageMaskSize) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.imageMaskingOperationTimer forMode:NSDefaultRunLoopMode];

}

-(CAShapeLayer*)getShapeFromRect:(CGRect)rectPathForMask {
    CAShapeLayer* shape = [CAShapeLayer layer];
    CGPathRef maskingPath;
    if (self.animationType == MaskShapeTypeStar) {
        JKBezierStarDrawer* bezierStarDrawer = [JKBezierStarDrawer new];
        maskingPath = [bezierStarDrawer drawStarBezierWithX:self.viewMidX andY:self.viewMidY andRadius:rectPathForMask.size.height andSides:self.numberOfVerticesForPolygon andPointiness:self.pointinessForStarCorners].CGPath;
        shape.path = maskingPath;
        return shape;
    } else if(self.animationType == MaskShapeTypeCircle) {
        maskingPath = CGPathCreateWithEllipseInRect(rectPathForMask, nil);
    } else if(self.animationType == MaskShapeTypeRectangle){
        maskingPath = CGPathCreateWithRect(rectPathForMask, nil);
    } else if (self.animationType == MaskShapeTypeTriangle) {
        maskingPath = [self getTriangleShapeWithSize:rectPathForMask.size.height];
    } else if (self.animationType == MaskShapeTypeAlphaImage) {
        return [self getCustomMaskLayerFromRect:rectPathForMask];
    }
    shape.path = maskingPath;
    CGPathRelease(maskingPath);
    return shape;
}

-(CGMutablePathRef)getTriangleShapeWithSize:(CGFloat)shapeSize {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, self.viewMidX, self.viewMidY - shapeSize); //start from here
    CGPathAddLineToPoint(path, nil, self.viewMidX - shapeSize, self.viewMidY + shapeSize);
    CGPathAddLineToPoint(path, nil, self.viewMidX + shapeSize, self.viewMidY + shapeSize);
    CGPathAddLineToPoint(path, nil, self.viewMidX, self.viewMidY - shapeSize);
    return path;
}

-(CAShapeLayer*)getCustomMaskLayerFromRect:(CGRect)rectPathToMask {
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.frame = rectPathToMask;
    maskLayer.contents = (__bridge id) self.maskImage.CGImage;
    return maskLayer;
}

-(void)updateImageMaskSize {
    
    self.viewToMask.layer.mask = [self getShapeFromRect:CGRectMake((self.viewToMask.frame.size.width - self.maskSize)/2, (self.viewToMask.frame.size.height - self.maskSize)/2, self.maskSize, self.maskSize)];
    self.maskSize += self.maskSizeIncrementPerFrame;
    
    if(self.partialCompletionCallback) {
        self.partialCompletionCallback(((self.maskSize/self.maximumMaskSize)*100));
    }
    if(self.maskSize >= self.maximumMaskSize) {
        [self.imageMaskingOperationTimer invalidate];
        self.imageMaskingOperationTimer = nil;
        self.viewToMask.layer.mask = nil;
        if(self.completionCallback) {
            self.completionCallback();
        }
    }
}

-(CGFloat)calculateMaximumMaskDimension {
    CGFloat maxDimension = MAX(self.viewToMask.frame.size.width, self.viewToMask.frame.size.height);
    return sqrt(pow(maxDimension, 2) + pow(maxDimension, 2));
}

@end
