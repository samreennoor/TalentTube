//
//  CommentsVC.h
//  HydePark
//
//  Created by Apple on 18/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsModel.h"
#import "AppDelegate.h"
#import "AVFoundation/AVFoundation.h"
#import "AsyncImageView.h"
#import "VideoModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WDUploadProgressView.h"
#import "Alert.h"
#import "ASIFormDataRequest.h"
#import "autocompleteHandle.h"
#import "myChannelModel.h"
@interface CommentsVC : UIViewController<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,AVAudioRecorderDelegate,MPMediaPickerControllerDelegate,WDUploadProgressDelegate,ASIHTTPRequestDelegate,AlertDelegate,WDClientUploadDelegate,AutocompleteHandleDelegate>
{
    
    
    Alert *alert;

    float uploadingProgress;

    NSString *textToshare;
    float keyboardSize;
    NSMutableArray *finalArray;

    
    IBOutlet UITableView *commentsTable;
    AppDelegate *appDelegate;
    NSUInteger currentSelectedIndex;
    NSString *postID;
    NSString *ParentCommentID;
    CommentsModel *CommentsModelObj;
    VideoModel *videoModel;
    NSArray *CommentsArray;
    IBOutlet AsyncImageView *coverimgComments;
    IBOutlet AsyncImageView *UserImg;
    IBOutlet UILabel *Postusername;
    IBOutlet UILabel *videoLengthComments;
    IBOutlet UILabel *titleComments;
    IBOutlet UIView *cointerView;
    IBOutlet UILabel *likes;
    IBOutlet UILabel *views;
    IBOutlet UILabel *replies;
    IBOutlet UIButton *editButto;
    NSUInteger currentIndex;
    IBOutlet UIButton *likeBtn;
    NSMutableArray *videoObj;
    BOOL uploadBeamTag;
    BOOL uploadAnonymous;
    IBOutlet UIView *editView;
    NSString *video_duration;
    NSData *movieData;
    NSData *profileData; // for Thumbnail selected
    NSData *audioData;
    IBOutlet UIButton *closeBtnAudio;
    NSTimer *timerToupdateLbl;
    BOOL isRecording;
    NSTimer* audioTimeOut;
    IBOutlet UILabel *countDownlabel;
    IBOutlet UIImageView *audioBtnImage;
    int secondsLeft;
    NSString *secondsConsumed;
    IBOutlet UIView *bottomBarView;
    UIImage *thumbnailToUpload;
    UIGestureRecognizer *tapper;
    IBOutlet UIImageView *editImage;
    CGFloat tableHeight;
    IBOutlet UILabel *likeslbl;
    IBOutlet UILabel *viewslbl;
    IBOutlet UILabel *replieslbl;
    UIActivityIndicatorView *activityIndicator;
    BOOL usersPost;
    BOOL isNewlyVideoAdded;
    long arrayCount;
}

@property (weak, nonatomic) IBOutlet UITableView *tblView;

@property (weak, nonatomic) IBOutlet UITextField *tfComment;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayOutConstain;
@property (strong, nonatomic) myChannelModel *myprofile;

@property (strong, nonatomic) WDUploadProgressView *progressView;
@property (strong, nonatomic) CommentsModel *commentsObj;
@property (strong, nonatomic) VideoModel *postArray;
@property (strong, nonatomic) NSString *cPostId;
@property (nonatomic) BOOL isComment;
@property (nonatomic) BOOL isFirstComment;
@property (strong, nonatomic) NSString *pID;
@property (nonatomic) BOOL isAnonymous;

@property (weak, nonatomic) IBOutlet UIButton *audioRecordBtn;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) IBOutlet UIView *uploadAudioView;
@property (weak, nonatomic) IBOutlet UILabel *reportThisbeamlbl;
@property (weak, nonatomic) IBOutlet UILabel *blockThispersonlbl;
@property (weak, nonatomic) IBOutlet UIButton *report;
@property (weak, nonatomic) IBOutlet UIButton *block;
@property (weak, nonatomic) IBOutlet UIImageView *flagImg;
@property (weak, nonatomic) IBOutlet UIImageView *blockImg;
@property (weak, nonatomic) IBOutlet UIView *viewToRound;
@property (weak, nonatomic) IBOutlet UIView *muteDialog;
@property (weak, nonatomic) IBOutlet UIImageView *muteImage;
@property (weak, nonatomic) IBOutlet UIImageView *anonyImage;
@property (weak, nonatomic) IBOutlet UIView *sharePersonalComment;
- (IBAction)editBtnPressed:(id)sender;
- (IBAction)likeComment:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)MainPlayBtn:(id)sender;
- (IBAction)CancelEditBtn:(id)sender;
- (IBAction)ReportBtn:(id)sender;
- (IBAction)BlockPerson:(id)sender;
- (IBAction)beamPressed:(id)sender;
- (IBAction)RecorderPressed:(id)sender;
- (IBAction)AudioClosePressed:(id)sender;
- (void)updateCommentsArray:(CommentsModel*)cObj;
@property (weak, nonatomic) IBOutlet UIButton *btnSendComment;


@end
