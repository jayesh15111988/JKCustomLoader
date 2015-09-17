//
//  ViewController.m
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ViewController.h"
#import "JKCustomLoader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView* testImageView;
@property (assign) MaskShapeType selectedMaskShapeType;
@property (weak, nonatomic) IBOutlet UILabel* animationCompleteLabel;
@property (assign) BOOL isAnimationComplete;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.isAnimationComplete = YES;
}

- (void)loadImageWithSelectedMask {
	if (self.isAnimationComplete) {
		self.animationCompleteLabel.text = @"Working on Animation......";
		JKCustomLoader* loader = [[JKCustomLoader alloc] initWithInputView:self.testImageView
								  andAnimationType:self.selectedMaskShapeType];
		loader.maskImage = [UIImage imageNamed:@"donald.png"];
		loader.numberOfVerticesForPolygon = 6;
		[loader loadViewWithCompletionBlock:^{
		  self.animationCompleteLabel.text = @"Complete";
		  self.isAnimationComplete = YES;
		  NSLog (@"View Mask Loading Finished");
		}];
    } else {
        UIAlertView* animationInProgressAlert = [[UIAlertView alloc] initWithTitle:@"Custom Animation" message:@"Please wait until last animation completed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [animationInProgressAlert show];
    }
}

- (IBAction)loadRectangleAnimation:(id)sender {
	self.selectedMaskShapeType = MaskShapeTypeRectangle;
	[self loadImageWithSelectedMask];
	self.isAnimationComplete = NO;
}

- (IBAction)loadCircleAnimation:(id)sender {
	self.selectedMaskShapeType = MaskShapeTypeCircle;
	[self loadImageWithSelectedMask];
	self.isAnimationComplete = NO;
}

- (IBAction)loadTriangleAnimation:(id)sender {
	self.selectedMaskShapeType = MaskShapeTypeTriangle;
	[self loadImageWithSelectedMask];
	self.isAnimationComplete = NO;
}

- (IBAction)loadPolygonAnimation:(id)sender {
	self.selectedMaskShapeType = MaskShapeTypeStar;
	[self loadImageWithSelectedMask];
	self.isAnimationComplete = NO;
}

- (IBAction)loadImageAnimation:(id)sender {
	self.selectedMaskShapeType = MaskShapeTypeAlphaImage;
	[self loadImageWithSelectedMask];
	self.isAnimationComplete = NO;
}

@end
