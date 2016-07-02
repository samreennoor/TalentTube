//
//  HomeCell.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "HomeCell.h"

@implementation HomeCell
@synthesize CommentscountLbl,heartCountlbl,flag,commentsBtn,heart,CH_userName,CH_VideoTitle,playVideo,CH_hashTags,videoThumbnail,editBtn,overlay,viewToRound,CH_profileImage,CH_commentsBtn,btnMenu,CH_CommentscountLbl,anonyright,anonyleft,muteLeft,muteRight;

- (void)awakeFromNib {
    self.CH_profileImage.layer.cornerRadius = 30;
    self.CH_profileImage.layer.masksToBounds = YES;
    //[self setupRating:3];
}

-(void)setupRating:(int)rating{

    self.startRating.starImage = [UIImage imageNamed:@"star_unfill.png"];
    self.startRating.starHighlightedImage = [UIImage imageNamed:@"star_fill.png"];
    self.startRating.maxRating = 5.0;
    _startRating.delegate = self;
    _startRating.horizontalMargin = 12;
    _startRating.editable=YES;
    _startRating.displayMode=EDStarRatingDisplayFull;
    
    
    _startRating.rating = rating;
    
    
   // [self starsSelectionChanged:_startRating rating:rating];

  
}

-(void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating
{
    NSString *ratingString = [NSString stringWithFormat:@"Rating: %.1f", rating];
    //    if( [control isEqual:_starRating] )
    //        //_starRatingLabel.text = ratingString;
    //    else
    //       // _starRatingImageLabel.text = ratingString;
    NSLog(@"rating  %ld",(long)self.startRating.tag);
VideoModel *videos = [[VideoModel alloc] init];
    [videos setRating:rating];
    [videos setUserName:self.CH_userName.text];
    [videos setTitle:self.CH_VideoTitle.text];
    [videos setComments_count:self.CH_CommentscountLbl.text];
    [videos setVideoID:self.videoId];
    //[videos setCurrentIndex:[self.currentSelectedIndex.text intValue]];
    //// user channel object
    UserChannelModel *videochnl = [[UserChannelModel alloc] init];
    [videochnl setRating:rating];
    [videochnl setUserName:self.CH_userName.text];
    [videochnl setTitle:self.CH_VideoTitle.text];
    [videochnl setComments_count:self.CH_CommentscountLbl.text];
    [videochnl setVideoID:self.videoId];
    
    long rat = self.startRating.tag;
    NSLog(@"rating  %@",self.CH_userName.text);
    
    //NSDictionary *videoObj = [NSDictionary dictionaryWithObject:videos forKey:@"videoObj"];
    NSDictionary *videoObj = @{@"videoObj": videos,@"tag":[NSString stringWithFormat:@"%ld", rat]};
    NSDictionary *videoChnlObj = @{@"videoObj": videochnl,@"tag":[NSString stringWithFormat:@"%ld", rat]};
 

    if(self.isUserChannel){
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"updateRatingInUserChannel"
     object:videoChnlObj];
    }
    else if (self.isVCPlayer){
    
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"updateRatingInVCPlayer"
         object:videoObj];
    }
    else{
    
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"updateRating"
         object:videoObj];
    }
    
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
