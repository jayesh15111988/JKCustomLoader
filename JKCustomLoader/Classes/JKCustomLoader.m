//
//  UIImageView+JKCustomLoader.m
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKCustomLoader.h"
#import "JKBezierStarDrawer.h"

typedef NS_ENUM (NSUInteger, CustomLoaderAnimationStage) {
	CustomLoaderAnimationStageFirst,
	CustomLoaderAnimationStageSecond
};

@interface JKCustomLoader ()

@property (nonatomic, strong) UIView* viewToMask;
@property (nonatomic, assign) MaskShapeType animationType;
@property (nonatomic, assign) CGFloat maximumMaskSize;
@property (nonatomic, assign) CGFloat viewMidX;
@property (nonatomic, assign) CGFloat viewMidY;
@property (nonatomic, strong) CALayer* viewMask;
@property (nonatomic, assign) CGFloat maskSize;
@property (nonatomic, assign) CGFloat maskSizeIncrementPerFrame;
@property (nonatomic, strong) NSTimer* imageMaskingOperationTimer;
@property (nonatomic, assign) CustomLoaderAnimationStage animationStage;
@property (nonatomic, assign) CGFloat minimumAnimationMaskSize;

// Test props to calculate total animation duration. Not really useful except for that.
@property (nonatomic, strong) NSDate* methodStart;
@property (nonatomic, strong) NSDate* methodFinish;

typedef void (^CustomLoadingAnimationCompleted)();
@property (nonatomic, copy) CustomLoadingAnimationCompleted customLoadingAnimationCompletedBlock;

@end

@implementation JKCustomLoader

- (instancetype)initWithInputView:(UIView*)inputView andAnimationType:(MaskShapeType)animationType {
	if (self = [super init]) {
		_viewToMask = inputView;
		_viewMidX = self.viewToMask.frame.size.width / 2;
		_viewMidY = self.viewToMask.frame.size.height / 2;
		_animationType = animationType;
		// Default values in case we want to draw a polygon
		_numberOfVerticesForPolygon = 6;
		_animationDuration = 1.0;
		_maskSize = 40.0;
		_animationBeginDelay = 0.5;
	}
	return self;
}

- (void)loadViewWithCompletionBlock:(void (^)())animationCompletion {
	self.customLoadingAnimationCompletedBlock = animationCompletion;
	CGFloat maximumViewDimension = MAX (self.viewToMask.frame.size.width, self.viewToMask.frame.size.height);
	if (self.animationType == MaskShapeTypeTriangle) {
		self.maximumMaskSize = (maximumViewDimension / 2) + maximumViewDimension * 0.866;
	} else if (self.animationType == MaskShapeTypeStar) {
		self.maximumMaskSize = maximumViewDimension * 0.5;
	} else if (self.animationType == MaskShapeTypeAlphaImage) {
		self.maximumMaskSize = maximumViewDimension * 4.0;
		NSAssert (self.maskImage,
			  @"Masking image cannot be nil when MaskShapeTypeAlphaImage animation mode is selected");
	} else if (self.animationType == MaskShapeTypeCircle) {
		self.maximumMaskSize = [self maximumMaskDimension];
	} else if (self.animationType == MaskShapeTypeRectangle) {
		self.maximumMaskSize = maximumViewDimension;
	}
	_minimumAnimationMaskSize = _maskSize / 2.0;
	_maskSizeIncrementPerFrame = ((self.maximumMaskSize) / _animationDuration) * (0.0167);
	if (self.animationType == MaskShapeTypeAlphaImage) {
		_viewMask = [self shapeForImageAnimationFromRect:CGRectMake (0, 0, _maskSize, _maskSize)];
		_viewToMask.layer.mask = _viewMask;
		[self animateMask];
	} else {
		_animationStage = CustomLoaderAnimationStageFirst;
		_viewMask = [self shapeFromRect:CGRectMake ((self.viewToMask.frame.size.width - self.maskSize) / 2,
							    (self.viewToMask.frame.size.height - self.maskSize) / 2,
							    self.maskSize, self.maskSize)];
		_viewToMask.layer.mask = _viewMask;

		double delayInSeconds = _animationBeginDelay;
		dispatch_time_t popTime = dispatch_time (DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after (popTime, dispatch_get_main_queue (), ^(void) {
		  self.imageMaskingOperationTimer = [NSTimer timerWithTimeInterval:0.0167
									    target:self
									  selector:@selector (updateImageMaskSize)
									  userInfo:nil
									   repeats:YES];
		  self.methodStart = [NSDate date];
		  [[NSRunLoop mainRunLoop] addTimer:self.imageMaskingOperationTimer forMode:NSDefaultRunLoopMode];
		});
	}
}

- (void)updateImageMaskSize {

	self.viewToMask.layer.mask =
	    [self shapeFromRect:CGRectMake ((self.viewToMask.frame.size.width - self.maskSize) / 2,
					    (self.viewToMask.frame.size.height - self.maskSize) / 2, self.maskSize,
					    self.maskSize)];
	if (self.maskSize > _minimumAnimationMaskSize && self.animationStage == CustomLoaderAnimationStageFirst) {
		self.maskSize -= self.maskSizeIncrementPerFrame;
	} else {
		self.animationStage = CustomLoaderAnimationStageSecond;
		self.maskSize += self.maskSizeIncrementPerFrame;
	}

	if (self.maskSize >= self.maximumMaskSize) {
		[self.imageMaskingOperationTimer invalidate];
		self.imageMaskingOperationTimer = nil;
		self.viewToMask.layer.mask = nil;
		self.methodFinish = [NSDate date];
		NSTimeInterval executionTime = [self.methodFinish timeIntervalSinceDate:self.methodStart];
		NSLog (@"executionTime = %f", executionTime);
		if (self.customLoadingAnimationCompletedBlock) {
			self.customLoadingAnimationCompletedBlock ();
		}
	}
}

- (void)animateMask {
	CGFloat maximumMaskSize = self.maximumMaskSize;
	CAKeyframeAnimation* keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
	keyFrameAnimation.delegate = self;
	keyFrameAnimation.duration = _animationDuration;
	NSValue* initalBounds = [NSValue valueWithCGRect:self.viewMask.bounds];
	NSValue* secondBounds = [NSValue valueWithCGRect:CGRectMake (0, 0, self.viewMask.bounds.size.width / 2.0,
								     self.viewMask.bounds.size.height / 2.0)];
	NSValue* finalBounds = [NSValue valueWithCGRect:CGRectMake (0, 0, maximumMaskSize, maximumMaskSize)];
	keyFrameAnimation.values = @[ initalBounds, secondBounds, finalBounds ];
	keyFrameAnimation.beginTime = CACurrentMediaTime () + 1.0;
	keyFrameAnimation.keyTimes = @[ @0, @0.3, @1 ];
	keyFrameAnimation.removedOnCompletion = NO;
	keyFrameAnimation.fillMode = kCAFillModeForwards;
	keyFrameAnimation.timingFunctions = @[
		[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
		[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]
	];
	[self.viewMask addAnimation:keyFrameAnimation forKey:@"bounds"];
}

- (void)animationDidStop:(CAAnimation*)anim finished:(BOOL)flag {
	// Remove layer mask once animation is complete.
	self.viewToMask.layer.mask = nil;
	if (self.customLoadingAnimationCompletedBlock) {
		self.customLoadingAnimationCompletedBlock ();
	}
}

- (CAShapeLayer*)shapeFromRect:(CGRect)rectPathForMask {
	CAShapeLayer* shape = [CAShapeLayer layer];
	CGPathRef maskingPath;
	if (self.animationType == MaskShapeTypeStar) {
		JKBezierStarDrawer* bezierStarDrawer = [JKBezierStarDrawer new];
		maskingPath = [bezierStarDrawer drawStarBezierWithX:self.viewMidX
							       andY:self.viewMidY
							  andRadius:rectPathForMask.size.height
							   andSides:self.numberOfVerticesForPolygon
						      andPointiness:2]
				  .CGPath;
		shape.path = maskingPath;
		return shape;
	} else if (self.animationType == MaskShapeTypeCircle) {
		maskingPath = CGPathCreateWithEllipseInRect (rectPathForMask, nil);
	} else if (self.animationType == MaskShapeTypeRectangle) {
		maskingPath = CGPathCreateWithRect (rectPathForMask, nil);
	} else if (self.animationType == MaskShapeTypeTriangle) {
		maskingPath = [self triangleShapeWithSize:rectPathForMask.size.height];
	}
	shape.path = maskingPath;
	CGPathRelease (maskingPath);
	return shape;
}

- (CAShapeLayer*)shapeForImageAnimationFromRect:(CGRect)rectPathForMask {
	CAShapeLayer* shape = [self customMaskLayerFromRect:rectPathForMask];
	shape.anchorPoint = CGPointMake (0.5, 0.5);
	shape.position = CGPointMake (_viewMidX, _viewMidY);
	shape.bounds = CGRectMake (0, 0, _maskSize, _maskSize);
	return shape;
}

- (CGMutablePathRef)triangleShapeWithSize:(CGFloat)shapeSize {
	CGMutablePathRef path = CGPathCreateMutable ();
	CGPathMoveToPoint (path, nil, self.viewMidX, self.viewMidY - shapeSize); // start from here
	CGPathAddLineToPoint (path, nil, self.viewMidX - shapeSize, self.viewMidY + shapeSize);
	CGPathAddLineToPoint (path, nil, self.viewMidX + shapeSize, self.viewMidY + shapeSize);
	CGPathAddLineToPoint (path, nil, self.viewMidX, self.viewMidY - shapeSize);
	return path;
}

- (CAShapeLayer*)customMaskLayerFromRect:(CGRect)rectPathToMask {
	CAShapeLayer* maskLayer = [CAShapeLayer layer];
	maskLayer.frame = rectPathToMask;
	maskLayer.contentsGravity = kCAGravityResizeAspect;
	maskLayer.contents = (__bridge id)self.maskImage.CGImage;
	return maskLayer;
}

- (CGFloat)maximumMaskDimension {
	CGFloat maxDimension = MAX (self.viewToMask.frame.size.width, self.viewToMask.frame.size.height);
	return sqrt (pow (maxDimension, 2) + pow (maxDimension, 2));
}

@end
