//
//  CropOptionsView.h
//  PhotoTweaks
//
//  Created by Ryan Bertrand on 12/9/15.
//  Copyright (c) 2015 Tu You. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CropAspectRatio) {
    CropAspectRatioOriginal = 0,
    CropAspectRatioSquare = 1,
    CropAspectRatio3to2 = 2,
    CropAspectRatio5to3 = 3,
    CropAspectRatio4to3 = 4,
    CropAspectRatio5to4 = 5,
    CropAspectRatio6to4 = 6,
    CropAspectRatio7to5 = 7,
    CropAspectRatio10to8 = 8,
    CropAspectRatio16to9 = 9,
};

@protocol CropOptionsViewDelegate <NSObject>

-(void)cropOptionsViewDidSelectAspectRatio:(CropAspectRatio)ratio;

@end

@interface CropOptionsView : UIView{
    
}
@property(nonatomic, assign)id<CropOptionsViewDelegate> delegate;
@property(nonatomic, strong)UIScrollView *optionsScrollView;

@end
