//
//  VCPlayer.h
//  HydePark
//
//  Created by Apple on 12/04/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommentsModel.h"
#import "VideoModel.h"

@interface VCPlayer : UIViewController<UITableViewDataSource,UITableViewDelegate>
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
    BOOL isloadingOfCells;
    NSMutableArray *playerArray;
    CGRect frameForSix;
    NSInteger indexToPlay;
    AppDelegate *appDelegate;
    VideoModel *selectedVideo;
    NSMutableArray *videoObj;
    BOOL seenPost;
    long startRatingViewTag;
    float newRating;

}
@property (weak, nonatomic) IBOutlet UIView *viewItems;
@property (weak, nonatomic) IBOutlet UIButton *report;
@property (weak, nonatomic) IBOutlet UIButton *block;
@property (strong, nonatomic) NSMutableArray *videoObjs;
@property (nonatomic) NSUInteger indexToDisplay;
@property (nonatomic) BOOL isComment;
@property (strong, nonatomic) NSString *cPostId;
@property (nonatomic) BOOL isFirst;
@end
