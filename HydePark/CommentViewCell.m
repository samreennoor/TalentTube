//
//  CommentViewCell.m
//  HydePark
//
//  Created by Apple Txlabz on 08/06/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "CommentViewCell.h"

@implementation CommentViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userImg.layer.cornerRadius = 30.0;
    self.userImg.layer.masksToBounds = YES;
    
    [self.userImg.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [self.userImg.layer setBorderWidth: 2.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
