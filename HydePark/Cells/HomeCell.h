//
//  HomeCell.h
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "EDStarRating.h"
#import "UserChannelModel.h"
#import "VideoModel.h"

@interface HomeCell : UITableViewCell< EDStarRatingProtocol >
@property (strong, nonatomic) IBOutlet UIView *overlay;
@property (strong, nonatomic) IBOutlet UIButton *playVideo;
@property (strong, nonatomic) IBOutlet AsyncImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIButton *heart;
@property (strong, nonatomic) IBOutlet UILabel *heartCountlbl;
@property (strong, nonatomic) IBOutlet UIButton *commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *CommentscountLbl;
@property (strong, nonatomic) IBOutlet UILabel *seenLbl;
@property (strong, nonatomic) IBOutlet UIButton *flag;
@property (strong, nonatomic) IBOutlet UILabel *CH_userName;
@property (strong, nonatomic) IBOutlet UILabel *CH_VideoTitle;
@property (strong, nonatomic) IBOutlet UILabel *CH_hashTags;
@property (strong, nonatomic) IBOutlet AsyncImageView *videoThumbnail;
@property (strong, nonatomic) IBOutlet UILabel *videoLength;
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (strong, nonatomic) IBOutlet UIView *viewToRound;
@property (strong, nonatomic) IBOutlet NSString *videoId;


@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet EDStarRating *startRating;

@property (weak, nonatomic) IBOutlet UILabel *currentSelectedIndex;


@property (weak, nonatomic)   IBOutlet UIView *imgContainer;
@property (strong, nonatomic) IBOutlet UIButton *CH_playVideo;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_profileImage;
@property (strong, nonatomic) IBOutlet UIButton *CH_heart;
@property (strong, nonatomic) IBOutlet UILabel *CH_heartCountlbl;
@property (strong, nonatomic) IBOutlet UIButton *CH_commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *CH_CommentscountLbl;
@property (strong, nonatomic) IBOutlet UILabel *CH_seen;
@property (strong, nonatomic) IBOutlet UIButton *CH_flag;
@property (assign) BOOL isUserChannel;
@property (assign) BOOL isVCPlayer;
@property (strong, nonatomic) IBOutlet UIImageView *transthumb;
@property (strong, nonatomic) IBOutlet AsyncImageView *CH_Video_Thumbnail;
@property (strong, nonatomic) IBOutlet UILabel *Ch_videoLength;
@property (weak, nonatomic)   IBOutlet UIButton *userProfileView;
@property (weak, nonatomic)   IBOutlet UIActivityIndicatorView *activityInd;
@property (weak, nonatomic)   IBOutlet UIImageView *leftreplImg;
@property (weak, nonatomic)   IBOutlet UIImageView *anonyleft;
@property (weak, nonatomic)   IBOutlet UIImageView *anonyright;
@property (weak, nonatomic)   IBOutlet UIImageView *muteLeft;
@property (weak, nonatomic)   IBOutlet UIImageView *muteRight;
@property (weak, nonatomic) IBOutlet UIButton *btnUserProfile;

-(void)setupRating:(int)rating;


@end
