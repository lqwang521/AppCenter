//
//  VibrateCollectionViewCell.m
//  CollectionView抖动后拖拽
//
//  Created by songshu on 16/9/9.
//  Copyright © 2016年 SongShu. All rights reserved.
//

#import "VibrateCollectionViewCell.h"
//#define kWidth [UIScreen mainScreen].bounds.size.width

@interface VibrateCollectionViewCell ()


@end

@implementation VibrateCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self CreateUI];
    }
    return self;
}

//-(void)layoutSubviews{
- (void)CreateUI{
    if(!_headImageView){
        _headImageView = [[UIImageView alloc]init];
        _headImageView.frame = CGRectMake(0, 0, 114*kWidth/750.00, 114*kWidth/750.00);
        _headImageView.layer.cornerRadius = 57*kWidth/750.00;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_headImageView];
    }
    if(!_nameLable){
        _nameLable = [[UILabel alloc]init];
        _nameLable.frame = CGRectMake(0, 60*kWidth/750.00, 114*kWidth/750.00, 40*kWidth/750.00);
        _nameLable.font = [UIFont systemFontOfSize:30*kWidth/750.00];
        [_nameLable setTextAlignment:NSTextAlignmentCenter];
        _nameLable.textColor = [UIColor blackColor];
        [_headImageView addSubview:_nameLable];
    }
//    if(_nameLableStr){
//        _nameLable.text = _nameLableStr;
//    }
//    if(_imageStr){
//        _headImageView.image = [UIImage imageNamed:_imageStr];
//    }
}

@end
