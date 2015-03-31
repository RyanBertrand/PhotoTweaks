//
//  UIImage+PTBundleImages.m
//  PhotoTweaks
//
//  Created by Ryan Bertrand on 3/31/15.
//  Copyright (c) 2015 Tu You. All rights reserved.
//

#import "UIImage+PTBundleImages.h"

static NSString * const kBundle = @"PhotoTweaks.bundle";

@implementation UIImage (PTBundleImages)

+(UIImage *)bundleImageNamed:(NSString *)name
{
    NSString *resourceName = [NSString stringWithFormat:@"%@/%@", kBundle, name];
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"ttf"];
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    UIImage *img = [UIImage imageWithData:imgData];
    return img;
}

@end
