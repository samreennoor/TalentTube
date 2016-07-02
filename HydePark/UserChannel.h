//
//  UserChannel.h
//  HydePark
//
//  Created by Apple on 22/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import "UserChannelModel.h"
#import "VideoModel.h"
#import "CommentsModel.h"
@interface UserChannel : ViewController<UITableViewDataSource,UITableViewDelegate>{
    IBOutlet UITableView *friendsChannelTable;
    IBOutlet UIView *FriendsProfileView;
    IBOutlet UILabel *friendsFollowings;
    IBOutlet UILabel *friendsFollowers;
    IBOutlet UILabel *friendsBeamcount;
    IBOutlet UIButton *friendsStatusbtn;
    IBOutlet UIImageView *friendsCover;
    IBOutlet UIImageView *friendsImage;
    IBOutlet UILabel *friendsNamelbl;
    IBOutlet UIButton *friendsStatusbtnMid;
    IBOutlet UIView *bgView;
    NSUInteger currentSelectedIndex;
    NSString *friendId;
    VideoModel *videomodel;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    NSArray *arrImages;
    NSArray *arrThumbnail;
    NSArray *CommentsArray;
    NSArray *commentsVideosArray;
    NSUInteger currentIndex;
    NSMutableArray *videoObj;
    NSArray *FollowingsArray;
    NSMutableArray *FollowingsAM;
    UserChannelModel *userChannelObj;
    NSArray *chPostArray;
    long startRatingViewTag;
    UserChannelModel *selectedVideo;
    float newRating;
   
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boxview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boxLeftLayoutconstrain;
@property (weak, nonatomic) IBOutlet UILabel *lblVideos;

- (IBAction)getFollowings:(id)sender;
- (IBAction)getFollowers:(id)sender;
- (IBAction)getProfile:(id)sender;
@property (weak, nonatomic) IBOutlet  UIView *picBorder;
@property (weak, nonatomic) IBOutlet  UIImageView *followBorder;
@property (weak, nonatomic) IBOutlet  UIView *picBorderMid;
@property (weak, nonatomic) IBOutlet  UIImageView *followBorderMid;
@property (weak, nonatomic) IBOutlet  UIImageView *friendsImageMid;
@property (weak, nonatomic) IBOutlet  UILabel *Followlbl;
@property (weak, nonatomic) IBOutlet  UILabel *followlblMid;
@property (weak, nonatomic) IBOutlet  UILabel *userNameMid;
@property (weak, nonatomic) IBOutlet  UIImageView *countImage;
@property (weak, nonatomic) IBOutlet  UILabel *follwersCount;
@property (weak, nonatomic) IBOutlet  UIImageView *adsBar;
@property (weak, nonatomic) IBOutlet  UIButton *followingBtn;
@property (weak, nonatomic) IBOutlet  UIButton *followersBtn;
@property (weak, nonatomic) IBOutlet  UIButton *emiratesbtn;
@property (weak, nonatomic) IBOutlet  UIButton *redbullbtn;
@property (weak, nonatomic) IBOutlet  UIButton *bbcbtn;
@property (weak, nonatomic) IBOutlet UIView *viewToRound;
@property (weak, nonatomic)   IBOutlet UIView *profileViews;
@property (strong, nonatomic) UserChannelModel *ChannelObj;
@property (strong, nonatomic) NSString *friendID;

@property (weak, nonatomic) IBOutlet UIButton *report;
@property (weak, nonatomic) IBOutlet UIButton *block;

@property (weak, nonatomic) IBOutlet UIView *viewItems;


@end
