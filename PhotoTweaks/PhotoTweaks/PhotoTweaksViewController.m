//
//  PhotoTweaksViewController.m
//  PhotoTweaks
//
//  Created by Tu You on 14/12/5.
//  Copyright (c) 2014年 Tu You. All rights reserved.
//

#import "PhotoTweaksViewController.h"
#import "PhotoTweakView.h"
#import "UIColor+Tweak.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIButton+PTButtonTitleTweak.h"
#import "UIImage+PTBundleImages.h"

@interface PhotoTweaksViewController ()
@property(nonatomic, strong)UIImage *originalImage;
@property(nonatomic, strong)PhotoTweakView *photoView;
@property(nonatomic, assign)BOOL mirrorHorizontal;
@property(nonatomic, assign)BOOL mirrorVertical;
@property(nonatomic, strong)UIActivityIndicatorView *spinnerView;
@property(nonatomic, strong)CropOptionsView *cropOptionsView;
@end


@implementation PhotoTweaksViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if (self = [super init]) {
        _image = image;
        _originalImage = image;
        _autoSaveToLibray = YES;
        _tintColor = [UIColor saveButtonColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setTranslucent:NO];
    self.title = @"Editor";
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor photoTweakCanvasBackgroundColor];
    
    [self setUpNavigationBar];
}

-(void)setUpNavigationBar{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveBtnTapped)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"Reset Photo" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(resetBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = btn;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupSubviews];
}

- (void)setupSubviews
{
    self.photoView = [[PhotoTweakView alloc] initWithFrame:self.view.bounds image:self.image];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.photoView.tintColor = self.tintColor;
    [self.view addSubview:self.photoView];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinnerView.alpha = 0.0;
    [self.spinnerView startAnimating];
    self.spinnerView.center = self.view.center;
    [self.view addSubview:self.spinnerView];
    [self.view sendSubviewToBack:self.spinnerView];
    
    self.cropOptionsView = [[CropOptionsView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    self.cropOptionsView.delegate = self;
    [self.view addSubview:self.cropOptionsView];
}

- (CATransform3D)rotateTransform:(CATransform3D)initialTransform
{
    CATransform3D transform = initialTransform;
    transform = CATransform3DRotate(transform, self.mirrorHorizontal * M_PI, 0, 1, 0);
    transform = CATransform3DRotate(transform, self.mirrorVertical * M_PI, 1, 0, 0);
    return transform;
}

- (void)rotateStateDidChange:(BOOL)vertical
{
    UIViewAnimationOptions opts = (vertical ? UIViewAnimationOptionTransitionFlipFromTop : UIViewAnimationOptionTransitionFlipFromRight);
    [UIView transitionWithView:self.photoView.photoContentView.imageView
                      duration:0.4
                       options:opts
                    animations:^{
                        CATransform3D transform = [self rotateTransform:CATransform3DIdentity];
                        self.photoView.photoContentView.imageView.layer.transform = transform;
                    } completion:NULL];
}

-(void)mirrorVertical:(id)sender{
    self.mirrorVertical = !self.mirrorVertical;
    [self rotateStateDidChange:YES];
}

-(void)mirrorHorizontal:(id)sender{
    self.mirrorHorizontal = !self.mirrorHorizontal;
    [self rotateStateDidChange:NO];
}

- (void)cancelBtnTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetBtnTapped
{
    [self.photoView resetPhoto];
}

- (void)saveBtnTapped
{
    //Show spinner here
    typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        for (UIView *sView in self.view.subviews) {
            if(sView == self.spinnerView){
                //Show spinner
                sView.alpha = 1.0;
            }
            else{
                //Hide spinner
                sView.alpha = 0.0;
            }
        }
    } completion:^(BOOL finished) {
        [weakSelf actuallySaveImage];
    }];
}

-(void)actuallySaveImage{
    NSDate *start = [NSDate date];
    
    CGAffineTransform transform = CATransform3DGetAffineTransform([self rotateTransform:CATransform3DIdentity]);
    
    // translate
    CGPoint translation = [self.photoView photoTranslation];
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    // rotate
    transform = CGAffineTransformRotate(transform, self.photoView.angle);
    
    // scale
    CGAffineTransform t = self.photoView.photoContentView.transform;
    CGFloat xScale =  sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    transform = CGAffineTransformScale(transform, xScale, yScale);
    
    CGImageRef imageRef = [self newTransformedImage:transform
                                        sourceImage:self.image.CGImage
                                         sourceSize:self.image.size
                                  sourceOrientation:self.image.imageOrientation
                                        outputWidth:self.image.size.width
                                           cropSize:self.photoView.cropView.frame.size
                                      imageViewSize:self.photoView.photoContentView.bounds.size];
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    if ([self.delegate respondsToSelector:@selector(finishWithCroppedImage:)]) {
        [self.delegate finishWithCroppedImage:image];
    }
    
    if (self.autoSaveToLibray) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeImageToSavedPhotosAlbum:imageRef metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
            }
        }];
    }
    CGImageRelease(imageRef);
    
    NSDate *methodFinish = [NSDate date];
    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
    NSLog(@"PhotoTweaksViewController.m :: saveBtnTapped :: Execution Time: %f", executionTime);
}

- (CGImageRef)newScaledImage:(CGImageRef)source withOrientation:(UIImageOrientation)orientation toSize:(CGSize)size withQuality:(CGInterpolationQuality)quality
{
    CGSize srcSize = size;
    CGFloat rotation = 0.0;
    
    switch(orientation)
    {
        case UIImageOrientationUp: {
            rotation = 0;
        } break;
        case UIImageOrientationDown: {
            rotation = M_PI;
        } break;
        case UIImageOrientationLeft:{
            rotation = M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        case UIImageOrientationRight: {
            rotation = -M_PI_2;
            srcSize = CGSizeMake(size.height, size.width);
        } break;
        default:
            break;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 size.width,
                                                 size.height,
                                                 8,  //CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst  //CGImageGetBitmapInfo(source)
                                                 );
    if(!context){
        //Context was fucked.  This happens with Dexis images.  Lets try to build one using the true bits and bitmap info
        context = CGBitmapContextCreate(NULL,
                                        size.width,
                                        size.height,
                                        CGImageGetBitsPerComponent(source),
                                        0,
                                        CGImageGetColorSpace(source),
                                        CGImageGetBitmapInfo(source)
                                        );
        if(!context){
            //If the retry fails...fuck it lets bail!
            return nil;
        }
    }
    CGContextSetInterpolationQuality(context, quality);
    CGContextTranslateCTM(context,  size.width/2,  size.height/2);
    CGContextRotateCTM(context,rotation);
    
    CGContextDrawImage(context, CGRectMake(-srcSize.width/2 ,
                                           -srcSize.height/2,
                                           srcSize.width,
                                           srcSize.height),
                       source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    return resultRef;
}

- (CGImageRef)newTransformedImage:(CGAffineTransform)transform
                      sourceImage:(CGImageRef)sourceImage
                       sourceSize:(CGSize)sourceSize
                sourceOrientation:(UIImageOrientation)sourceOrientation
                      outputWidth:(CGFloat)outputWidth
                         cropSize:(CGSize)cropSize
                    imageViewSize:(CGSize)imageViewSize
{
    CGImageRef source = [self newScaledImage:sourceImage
                             withOrientation:sourceOrientation
                                      toSize:sourceSize
                                 withQuality:kCGInterpolationNone];
    
    CGFloat aspect = cropSize.height/cropSize.width;
    CGSize outputSize = CGSizeMake(outputWidth, outputWidth*aspect);
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 outputSize.width,
                                                 outputSize.height,
                                                 CGImageGetBitsPerComponent(source),
                                                 0,
                                                 CGImageGetColorSpace(source),
                                                 CGImageGetBitmapInfo(source));
    if(!context){
        return nil;
    }
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, outputSize.width, outputSize.height));
    
    CGAffineTransform uiCoords = CGAffineTransformMakeScale(outputSize.width / cropSize.width,
                                                            outputSize.height / cropSize.height);
    uiCoords = CGAffineTransformTranslate(uiCoords, cropSize.width/2.0, cropSize.height / 2.0);
    uiCoords = CGAffineTransformScale(uiCoords, 1.0, -1.0);
    CGContextConcatCTM(context, uiCoords);
    
    CGContextConcatCTM(context, transform);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(-imageViewSize.width/2.0,
                                           -imageViewSize.height/2.0,
                                           imageViewSize.width,
                                           imageViewSize.height)
                       , source);
    
    CGImageRef resultRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGImageRelease(source);
    return resultRef;
}

#pragma mark - Aspect Ratio Delegate

-(void)cropOptionsViewDidSelectAspectRatio:(CropAspectRatio)ratio{
    [UIView setAnimationsEnabled:NO];
    [self.photoView resetPhoto];
    [self.photoView.cropView setAspectRatio:ratio];
    [UIView setAnimationsEnabled:YES];
}

@end
