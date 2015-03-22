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
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (assign) MaskShapeType selectedMaskShapeType;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)loadImageWithSelectedMask {
    JKCustomLoader* loader = [[JKCustomLoader alloc] initWithInputView:self.testImageView andAnimationType:self.selectedMaskShapeType];
    loader.maskImage = [UIImage imageNamed:@"donald.png"];
    loader.numberOfSidesForStar = 5;
    loader.pointinessForStarCorners = 2;
    [loader loadViewWithPartialCompletionBlock:^(CGFloat partialCompletionPercentage) {
        NSLog(@"Percentage Completed %f", partialCompletionPercentage);
    } andCompletionBlock:^{
        NSLog(@"Image Loading Completed");
    }];
}

- (IBAction)loadRectangleAnimation:(id)sender {
    self.selectedMaskShapeType = MaskShapeTypeRectangle;
    [self loadImageWithSelectedMask];
}

- (IBAction)loadCircleAnimation:(id)sender {
    self.selectedMaskShapeType = MaskShapeTypeCircle;
    [self loadImageWithSelectedMask];
}

- (IBAction)loadTriangleAnimation:(id)sender {
    self.selectedMaskShapeType = MaskShapeTypeTriangle;
    [self loadImageWithSelectedMask];
}

- (IBAction)loadPolygonAnimation:(id)sender {
    self.selectedMaskShapeType = MaskShapeTypeStar;
    [self loadImageWithSelectedMask];
}

- (IBAction)loadImageAnimation:(id)sender {
    self.selectedMaskShapeType = MaskShapeTypeAlphaImage;
    [self loadImageWithSelectedMask];
}

@end
