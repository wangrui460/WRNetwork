//
//  WeiXinCell.m
//  WRNetWrapper
//
//  Created by itwangrui on 2018/1/30.
//  Copyright © 2018年 itwangrui. All rights reserved.
//

#import "WeiXinCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface WeiXinCell ()
@property (weak, nonatomic) IBOutlet UIImageView *firImageView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation WeiXinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setData:(NSDictionary *)dict {
    NSString *title = dict[@"title"];
    NSString *source = dict[@"source"];
    NSString *firstImgStr = dict[@"firstImg"];
    [self.firImageView sd_setImageWithURL:[NSURL URLWithString:firstImgStr]];
    self.fromLabel.text = source;
    self.detailLabel.text = title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
