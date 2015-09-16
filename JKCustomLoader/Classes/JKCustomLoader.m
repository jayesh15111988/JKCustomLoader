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

@property (nonatomic, strong) UIView* viewToMask;
@property (nonatomic, assign) MaskShapeType animationType;
@property (nonatomic, assign) CGFloat maximumMaskSize;
@property (nonatomic, assign) CGFloat viewMidX;
@property (nonatomic, assign) CGFloat viewMidY;
@property (nonatomic, assign) CGFloat animationRate;
@property (nonatomic, strong) CALayer* viewMask;

typedef void (^CustomLoadingAnimationCompleted)();
@property (nonatomic, copy) CustomLoadingAnimationCompleted customLoadingAnimationCompletedBlock;

@end

@implementation JKCustomLoader

- (instancetype)initWithInputView:(UIView*)inputView andAnimationType:(MaskShapeType)animationType {
	if (self = [super init]) {
		_viewToMask = inputView;
		_initialMaskSize = 50;
		_viewMidX = self.viewToMask.frame.size.width / 2;
		_viewMidY = self.viewToMask.frame.size.height / 2;
		_animationType = animationType;
		// Default values in case we want to draw a polygon
		_numberOfVerticesForPolygon = 6;
		_pointinessForStarCorners = 2;
		_animationDuration = 1.0;
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
		self.maximumMaskSize = [self calculateMaximumMaskDimension];
	} else if (self.animationType == MaskShapeTypeRectangle) {
		self.maximumMaskSize = maximumViewDimension;
	}
	_viewMask.anchorPoint = CGPointMake (0.5, 0.5);
	_viewMask.position = CGPointMake (_viewMidX, _viewMidY);
	_viewMask.bounds = CGRectMake (0, 0, 100, 100);
	_viewMask = [self getShapeFromRect:CGRectMake (0, 0, _initialMaskSize, _initialMaskSize)];
	_viewToMask.layer.mask = _viewMask;
	[self animateMask];
}

- (void)animateMask {
	CGFloat maximumMaskSize = self.maximumMaskSize;
	CAKeyframeAnimation* keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
	keyFrameAnimation.delegate = self;
	keyFrameAnimation.duration = 1.0;
	NSValue* initalBounds = [NSValue valueWithCGRect:self.viewMask.bounds];
	NSValue* secondBounds = [NSValue valueWithCGRect:CGRectMake (0, 0, self.viewMask.bounds.size.width/2.0, self.viewMask.bounds.size.height/2.0)];
	NSValue* finalBounds = [NSValue valueWithCGRect:CGRectMake (0, 0, maximumMaskSize, maximumMaskSize)];
	keyFrameAnimation.values = @[ initalBounds, secondBounds, finalBounds ];
	keyFrameAnimation.beginTime = CACurrentMediaTime () + 0.5;
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

- (CAShapeLayer*)getShapeFromRect:(CGRect)rectPathForMask {
	CAShapeLayer* shape = [CAShapeLayer layer];
	CGPathRef maskingPath;
	if (self.animationType == MaskShapeTypeStar) {
		JKBezierStarDrawer* bezierStarDrawer = [JKBezierStarDrawer new];
		maskingPath = [bezierStarDrawer drawStarBezierWithX:self.viewMidX
							       andY:self.viewMidY
							  andRadius:rectPathForMask.size.height
							   andSides:self.numberOfVerticesForPolygon
						      andPointiness:self.pointinessForStarCorners]
				  .CGPath;
		shape.path = maskingPath;
	} else if (self.animationType == MaskShapeTypeCircle) {
		maskingPath = CGPathCreateWithEllipseInRect (rectPathForMask, nil);
		shape.path = maskingPath;
	} else if (self.animationType == MaskShapeTypeRectangle) {
		maskingPath = CGPathCreateWithRect (rectPathForMask, nil);
		shape.path = maskingPath;
	} else if (self.animationType == MaskShapeTypeTriangle) {
		maskingPath = [self getTriangleShapeWithSize:rectPathForMask.size.height];
		shape.path = maskingPath;
	} else if (self.animationType == MaskShapeTypeAlphaImage) {
		shape = [self getCustomMaskLayerFromRect:rectPathForMask];
	}
	shape.anchorPoint = CGPointMake (0.5, 0.5);
	shape.position = CGPointMake (self.viewToMask.frame.size.width / 2, self.viewToMask.frame.size.height / 2);
	shape.bounds = CGRectMake (0, 0, _initialMaskSize, _initialMaskSize);
	CGPathRelease (maskingPath);
	return shape;
}

- (CGMutablePathRef)getTriangleShapeWithSize:(CGFloat)shapeSize {
	CGMutablePathRef path = CGPathCreateMutable ();
	CGPathMoveToPoint (path, nil, self.viewMidX, self.viewMidY - shapeSize); // start from here
	CGPathAddLineToPoint (path, nil, self.viewMidX - shapeSize, self.viewMidY + shapeSize);
	CGPathAddLineToPoint (path, nil, self.viewMidX + shapeSize, self.viewMidY + shapeSize);
	CGPathAddLineToPoint (path, nil, self.viewMidX, self.viewMidY - shapeSize);
	return path;
}

- (CAShapeLayer*)getCustomMaskLayerFromRect:(CGRect)rectPathToMask {
	CAShapeLayer* maskLayer = [CAShapeLayer layer];
	maskLayer.frame = rectPathToMask;
	maskLayer.contentsGravity = kCAGravityResizeAspect;
	maskLayer.contents = (__bridge id)self.maskImage.CGImage;
	return maskLayer;
}

- (CGFloat)calculateMaximumMaskDimension {
	CGFloat maxDimension = MAX (self.viewToMask.frame.size.width, self.viewToMask.frame.size.height);
	return sqrt (pow (maxDimension, 2) + pow (maxDimension, 2));
}

@end
