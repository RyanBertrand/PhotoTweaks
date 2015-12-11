//
//  CropOptionsView.m
//  PhotoTweaks
//
//  Created by Ryan Bertrand on 12/9/15.
//  Copyright (c) 2015 Tu You. All rights reserved.
//

#import "CropOptionsView.h"
#import "PhotoTweakView.h"
#import "UIButton+PTButtonTitleTweak.h"

@implementation CropOptionsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

-(void)layoutSubviews{
    __block CGFloat x = 10;
    void(^aspectRatioOption)(NSString *, NSString *, CropAspectRatio) = ^(NSString *imgName, NSString *title, CropAspectRatio ratio) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        btn.tag = 1000+ ratio;
        [btn addTarget:self action:@selector(didTapOption:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(x, 0, 60, self.frame.size.height);
        btn.titleLabel.font = [UIFont systemFontOfSize:8];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn centerVertically];
        [_optionsScrollView addSubview:btn];
        
        x += (10 + btn.frame.size.width);
    };
    
    if(!_optionsScrollView){
        _optionsScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _optionsScrollView.showsHorizontalScrollIndicator = NO;
        _optionsScrollView.showsVerticalScrollIndicator = NO;
        _optionsScrollView.contentSize = CGSizeMake(1000, self.frame.size.height);
        _optionsScrollView.canCancelContentTouches = YES;
        [self addSubview:_optionsScrollView];
        
        aspectRatioOption(@"aspect-ratio-original", @"Original", CropAspectRatioOriginal);
        aspectRatioOption(@"aspect-ratio-square", @"Square", CropAspectRatioSquare);
        aspectRatioOption(@"aspect-ratio-3-to-2", @"3:2", CropAspectRatio3to2);
        aspectRatioOption(@"aspect-ratio-5-to-3", @"5:3", CropAspectRatio5to3);
        aspectRatioOption(@"aspect-ratio-4-to-3", @"4:3", CropAspectRatio4to3);
        aspectRatioOption(@"aspect-ratio-5-to-4", @"5:4", CropAspectRatio5to4);
        aspectRatioOption(@"aspect-ratio-6-to-4", @"6:4", CropAspectRatio6to4);
        aspectRatioOption(@"aspect-ratio-7-to-5", @"7:5", CropAspectRatio7to5);
        aspectRatioOption(@"aspect-ratio-10-to-8", @"10:8", CropAspectRatio10to8);
        aspectRatioOption(@"aspect-ratio-16-to-9", @"16:9", CropAspectRatio16to9);
        
        _optionsScrollView.contentSize = CGSizeMake(x + 10, self.frame.size.height);
    }
    _optionsScrollView.frame = self.bounds;
}

-(void)didTapOption:(UIButton *)aspectRatioBtn{
    CropAspectRatio ratio = aspectRatioBtn.tag - 1000;
    if(self.delegate){
        [self.delegate cropOptionsViewDidSelectAspectRatio:ratio];
    }
}

@end
