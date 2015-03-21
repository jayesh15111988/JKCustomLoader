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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JKCustomLoader* loader = [[JKCustomLoader alloc] initWithInputView:self.testImageView andNumberOfFramesPerSecond:60 andAnimationType:MaskShapeTypeTriangle];
    [loader loadViewWithPartialCompletionBlock:^(CGFloat partialCompletionPercentage) {
        
    } andCompletionBlock:^{
        
    }];
}

@end
