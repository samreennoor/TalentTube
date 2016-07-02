//
//  VideoPlayerVC.h
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommentsModel.h"
#import "VideoModel.h"
#import "AsyncImageView.h"
#import "EDStarRating.h"

@interface VideoPlayerVC : UIViewController<UITableViewDataSource,UITableViewDelegate,EDStarRatingProtocol>
{
    IBOutlet UITableView *VideoPLayerTable;
    IBOutlet UILabel *scrollup;
    IBOutlet UILabel *scrollDown;
    IBOutlet UILabel *titleLbl;
    NSMutableDictionary *cache;
    NSUInteger currentSelectedIndex;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    NSArray *CommentsArray;
    VideoModel *videoModel;
    NSString *oldId;
    NSString *vId;
    BOOL isloadingOfCells;
    NSMutableArray *playerArray;
    CGRect frameForSix;
    NSInteger indexToPlay;
    AppDelegate *appDelegate;
    IBOutlet UIView *upperView;
     UIGestureRecognizer *tapper;
}
@property (weak, nonatomic) IBOutlet UIView *shareView;//share and replay view
@property (weak, nonatomic) IBOutlet UIView *fbAndTwitterView;
@property (strong, nonatomic) NSMutableArray *videoObjs;
@property (nonatomic) NSUInteger indexToDisplay;
@property (nonatomic) BOOL isComment;
@property (strong, nonatomic) NSString *cPostId;
@property (nonatomic) BOOL isFirst;
///////////////////////////////////////
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UILabel *VideoTitle;
@property (strong, nonatomic) IBOutlet AsyncImageView *profileImage;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *CH_heart;
@property (strong, nonatomic) IBOutlet UIButton *CH_commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *commentsCount;
@property (strong, nonatomic) IBOutlet UILabel *likesCount;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityind;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) MPMoviePlayerController * movieplayer;
@property (weak, nonatomic) IBOutlet EDStarRating *startRating;
@end
