//
//  UIImageView+JKCustomLoader.h
//  JKCustomLoader
//
//  Created by Jayesh Kawli Backup on 3/20/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKCustomLoader:UIView
-(instancetype)initWithInputView:(UIView*)inputView andNumberOfFramesPerSecond:(NSInteger)animationFrameRate andAnimationType:(NSInteger)animationType;

-(void)loadViewWithPartialCompletionBlock:(void (^)(CGFloat partialCompletionPercentage))partialCompletion andCompletionBlock:(void (^)())completion;

typedef void (^PartialCompletionBlock)(CGFloat completionPercentage);
@property (strong, nonatomic) PartialCompletionBlock partialCompletionCallback;

typedef void (^CompletionBlock)();
@property (strong, nonatomic) CompletionBlock completionCallback;
@end