//
//  UIImageView+JKCustomLoader.m
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKCustomLoader.h"

@interface JKCustomLoader ()
@property (strong) UIView* viewToMask;
@property (assign) CGFloat maskSize;
@property (assign) NSInteger animationType;
@property (assign) CGFloat animationRate;
@property (strong) NSTimer* imageMaskingOperationTimer;
@property (assign) CGFloat maximumMaskSize;
@end


@implementation JKCustomLoader

-(instancetype)initWithInputView:(UIView*)inputView andNumberOfFramesPerSecond:(MaskShapeType)numberOfFrame andAnimationType:(NSInteger)animationType {
    if(self = [super init]) {
        self.viewToMask = inputView;
        self.animationRate = (CGFloat)(1.0/numberOfFrame);
        self.animationType = animationType;
    }
    return self;
}

-(void)loadViewWithPartialCompletionBlock:(void (^)(CGFloat partialCompletionPercentage))partialCompletion andCompletionBlock:(void (^)())completion {

    self.partialCompletionCallback = partialCompletion;
    self.completionCallback = completion;
    
    self.maximumMaskSize = [self calculateMaximumMaskDimension];
    self.maskSize = 0.0;
    self.viewToMask.layer.mask = [self getShapeFromRect:CGRectMake((self.viewToMask.frame.size.width - self.maskSize)/2, (self.viewToMask.frame.size.height - self.maskSize)/2, self.maskSize, self.maskSize)];
    self.imageMaskingOperationTimer = [NSTimer timerWithTimeInterval:self.animationRate target:self selector:@selector(updateImageMaskSize) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.imageMaskingOperationTimer forMode:NSDefaultRunLoopMode];
}

-(CAShapeLayer*)getShapeFromRect:(CGRect)rectPathForMask {
    CAShapeLayer* shape = [CAShapeLayer layer];
    CGPathRef maskingPath = CGPathCreateWithEllipseInRect(rectPathForMask, nil);
    shape.path = maskingPath;
    CGPathRelease(maskingPath);
    return shape;
}

-(CALayer*)getCustomMaskLayerFromRect:(CGRect)rectPathToMask {
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = rectPathToMask;
    UIImage* maskImage = [UIImage imageNamed:@"donald.png"];
    maskLayer.contents = (__bridge id) maskImage.CGImage;
    return maskLayer;
}




-(void)updateImageMaskSize {
    
    self.viewToMask.layer.mask = [self getShapeFromRect:CGRectMake((self.viewToMask.frame.size.width - self.maskSize)/2, (self.viewToMask.frame.size.height - self.maskSize)/2, self.maskSize, self.maskSize)];
    self.maskSize += 1.0;
    
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
