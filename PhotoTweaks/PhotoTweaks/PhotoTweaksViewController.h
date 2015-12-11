//
//  PhotoTweaksViewController.h
//  PhotoTweaks
//
//  Created by Tu You on 14/12/5.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoTweakView.h"

@protocol PhotoTweaksViewControllerDelegate;

/**
 The photo tweaks controller.
 */
@interface PhotoTweaksViewController : UIViewController <CropOptionsViewDelegate>

/**
 Tint color for UI elements.
 */
@property (nonatomic, strong) UIColor *tintColor;

/**
 Image to process.
 */
@property (nonatomic, strong) UIImage *image;

/**
 Flag indicating whether the image cropped will be saved to photo library automatically. Defaults to YES.
 */
@property (nonatomic, assign) BOOL autoSaveToLibray;

/**
 The optional photo tweaks controller delegate.
 */
@property (nonatomic, weak) id<PhotoTweaksViewControllerDelegate> delegate;

/**
 Creates a photo tweaks view controller with the image to process.
 */
- (instancetype)initWithImage:(UIImage *)image;

@end

/**
 The photo tweaks controller delegate
 */
@protocol PhotoTweaksViewControllerDelegate <NSObject>

@optional
/**
 Called on image cropped.
 */
- (void)finishWithCroppedImage:(UIImage *)croppedImage;

@end