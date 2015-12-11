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
    NSString *resourceName = [NSString stringWithFormat:@"%@", name];
    //NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"png"];
    NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:@"png"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    NSLog(@"Trying to find from %@:\nImage = %@", path, img);
    return img;
}

@end
