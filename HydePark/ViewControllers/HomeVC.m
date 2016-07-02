//
//  HomeVC.m
//  HydePark
//
//  Created by Mr on 21/04/2015.
//  Copyright (c) 2015 TxLabz. All rights reserved.
//

#import "HomeVC.h"
#import "Constants.h"
#import "HomeCell.h"
#import "ChannelCell.h"
#import "DrawerVC.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayer.h"
#import "NavigationHandler.h"
#import "StatusCell.h"
#import "UIImageView+RoundImage.h"
#import "QuartzCore/CALayer.h"
#import "BeamRecorderViewController.h"
#import "Utils.h"
#import "ASIFormDataRequest.h"
#import "KxMenu.h"
#import "PBEmojiLabel.h"
#import <AudioToolbox/AudioServices.h>
#import "AdvertismentCell.h"
#import "SVProgressHUD.h"
#import "GetTrendingVideos.h"
#import "Followings.h"
#import "myChannelModel.h"
#import "AsyncImageView.h"
#import "SearchCell.h"
#import "UserChannelModel.h"
#import "CommentsModel.h"
#import "CommentsCell.h"
#import "AVFoundation/AVFoundation.h"
#import "UserChannel.h"
#import "CommentsVC.h"
#import "NewHomeCells.h"
#import "VideoPlayerVC.h"
#import "BeamUploadVC.h"
@interface HomeVC ()
@end

@implementation HomeVC
{
    VideoModel *selectedVideo;

}
@synthesize TablemyChannel,progressView;
- (id)init
{
    if (IS_IPAD) {
        self = [super initWithNibName:@"HomeVC_iPad" bundle:Nil];
    }
    else if(IS_IPHONE_5){
        self = [super initWithNibName:@"HomeVC_iPhone5" bundle:Nil];
    }
    else{
        self = [super initWithNibName:@"HomeVC" bundle:Nil];
    }
    

    return self;
}
- (void) updateNotication:(NSNotification *) notification
{
    pageNum = 1;
    isDownwards = FALSE;
    if(!([newsfeedsVideos count] == 0)){
        [newsfeedsVideos removeAllObjects];
        [_TableHome reloadData];
    }
    [self getHomeContent];
}

-(void) updateStarRating:(NSNotification *) notification{
    if ([notification.name isEqualToString:@"updateRating"])
    {
       
        NSDictionary* userInfo = notification.object;
      VideoModel  *vObj= userInfo[@"videoObj"];
        startRatingViewTag = [userInfo[@"tag"] longLongValue];
        //[newsfeedsVideos replaceObjectAtIndex:vObj.currentIndex withObject:vObj];
        //[_TableHome reloadData];
        [self updateRatingApi:vObj];
        
    }



}

-(void) reloadTablView {
    if(currentState == 0){
    
    VideoModel *vmodl = newsfeedsVideos[startRatingViewTag];
    [vmodl setRating:newRating];
    [newsfeedsVideos replaceObjectAtIndex:startRatingViewTag withObject:vmodl];
    [_TableHome reloadData];
    }
    else if (currentState == 2 ) {
        VideoModel *vmodl = forumsVideo[startRatingViewTag];
        [vmodl setRating:newRating];
        [forumsVideo replaceObjectAtIndex:startRatingViewTag withObject:vmodl];
        [_forumTable reloadData];
    }
    else if (currentState == 3) {
        VideoModel *vmodl = channelVideos[startRatingViewTag];
        [vmodl setRating:newRating];
        [channelVideos replaceObjectAtIndex:startRatingViewTag withObject:vmodl];
        [TablemyChannel reloadData];
    
    }
    
}





- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

    isRecording = false;
    if(currentState == 0){
//        if(!fromImagePicker){
//            [self getMyChannel];
//        }
        if(appDelegate.timeToupdateHome)
        {
//            appDelegate.timeToupdateHome = FALSE;
//            pageNum = 1;
//            isDownwards = FALSE;
//            [newsfeedsVideos removeAllObjects];
//            [self getHomeContent];
//            [_TableHome reloadData];
//        }
//        else{
//            [_TableHome reloadData];
//        }
        }
         [_TableHome reloadData];
    }
    else if(currentState == 2){
        if(appDelegate.timeToupdateHome){
//            appDelegate.timeToupdateHome = FALSE;
//            forumPageNumber = 1;
//            isDownwards = FALSE;
//            [forumsVideo removeAllObjects];
//            [_forumTable reloadData];
//            //[self getTrendingVideos];
//        }
//        else{
//            [_forumTable reloadData];
//        }
        }
         [_forumTable reloadData];
    }
    else if(currentState == 3 && !fromImagePicker){
//        myCornerPageNum = 1;
//        [channelVideos removeAllObjects];
//        [self getMyChannel];
        [TablemyChannel reloadData];
        [self getFollowingarray];
    }
    isDownwards = false;
    fetchingContent = false;
    fetchingFroum = false;
    fetchingCorner = false;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateRating" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStarRating:) name:@"updateRating" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMyCornerArray" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveUpadtecall:) name:@"updateMyCornerArray" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshmyCorner" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshmyCornerAtIndex:) name:@"refreshmyCorner" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"editBeamMyCorner" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshmyCornerAtIndex:) name:@"editBeamMyCorner" object:nil];

}
- (void)recieveUpadtecall:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"updateMyCornerArray"])
    {
       
        [channelVideos insertObject:appDelegate.videObj atIndex:0];
        [self.TablemyChannel reloadData];
        
        NSInteger BeamsCount =  [userBeams.text integerValue];
        BeamsCount++;
        userBeams.text = [[NSString alloc]initWithFormat:@"%ld Videos",(long)BeamsCount];
    }
}

- (void)refreshmyCornerAtIndex:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"refreshmyCorner"])
    {
        //
        if(currentState == 2)
        {
            [forumsVideo removeObjectAtIndex:appDelegate.currentMyCornerIndex];
            [self.forumTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            //[self getMyChannel];
        }
        
        else{
            [channelVideos removeObjectAtIndex:appDelegate.currentMyCornerIndex];
            [self.TablemyChannel reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            NSInteger BeamsCount =  [userBeams.text integerValue];
            BeamsCount--;
            userBeams.text = [[NSString alloc]initWithFormat:@"%ld Videos",(long)BeamsCount];
        }
    }
    if([[notification name] isEqualToString:@"editBeamMyCorner"])
    {
        [channelVideos replaceObjectAtIndex:appDelegate.currentMyCornerIndex withObject:appDelegate.videObj];
         [self.TablemyChannel reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }

}
-(void)GetMychannelAgain:(NSNotification *) notification{
    myCornerPageNum = 1;
    [channelVideos removeAllObjects];
    [self getMyChannel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    myProfile =[[myChannelModel alloc]init];
    // Do any additional setup after loading the view from its nib.
    //self.navigationController.navigationBarHidden = YES;
  selectedVideo = [[VideoModel alloc]init];
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    searchField.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Find others"
     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    searchField2.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:@"Find others"
     attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    _searchTable.dataSource = self;
    _searchTable.delegate = self;
    fromImagePicker = FALSE;
  
    [_searchTable setBackgroundColor:BlueThemeColor(241,245,248)];
    [commentsTable setBackgroundColor:BlueThemeColor(241, 245, 248)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStarRating:)
                                                 name:@"updateRating"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotication:)
                                                 name:@"TestNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(VideofromGallery:)
                                                 name:@"UploadFromGallery"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showProgress:)
                                                 name:@"ShowProgress"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProgressBar:)
                                                 name:@"updateProgress"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(GetMychannelAgain:) name:@"GetChannelAgain"
                                               object:nil];
    normalAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(145,151,163) forKey:NSForegroundColorAttributeName];
    highlightAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(54,78,141) forKey:NSForegroundColorAttributeName ];
    tagsString = @"";
    secondsLeft = 60;
    self.automaticallyAdjustsScrollViewInsets = NO;
    tabBarIsShown = true;
    IS_mute = @"NO";
    videotype = @"COLOUR";
    commentAllowed = @"-1";
    privacySelected = @"PUBLIC";
    TopicSelected = @"1";
    adsViewb = TRUE;
   
    totalBytesUploaded = 0.0;
    drawerBtn.contentEdgeInsets = UIEdgeInsetsMake(12, 12, 9 , 9);
    loadFollowings = false;
    self.editing = YES;
    _TableHome.delegate = self;
    self.TablemyChannel.delegate = self;
    _forumTable.delegate = self;
    
    _TableHome.dataSource = self;
    self.TablemyChannel.dataSource = self;
    _forumTable.dataSource = self;
    
    [self setUserCoverImage];
    [self setUserProfileImage];
    [self initWithDataArr];
    [self getFollowing];
    _statusText.delegate = self;
    [_uploadbeamScroller setContentSize:CGSizeMake(_uploadbeamScroller.frame.size.width,600)];
    count = 10;

    [self setContentResolutions];
    TabBarFrame = _BottomBar.frame;
    channelContainerHeight = channelContainerView.frame.size.height;
    channelContainerOriginalFrame = channelContainerView.frame;
    channelTableFrame = self.TablemyChannel.frame;
    
    [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    
    UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:sgr];
    
    mainScrollerFrame = _mainScroller.frame;
   // originalChannelFrame = self.TablemyChannel.frame;
    [self setupRefreshControl];
    [self setupRefreshControlHome];
    currentState = 0;
    [self sendDeviceToken];
    [self getHomeContent];
    [self getMyChannel];
    [self getTrendingVideos];
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [self setAudioRecordSettings];
    [self setcontentForCeleb];

}
-(void)showProgress:(NSNotification *) notification{
    progressView = [[WDUploadProgressView alloc] initWithTableView:self.TablemyChannel cancelButton:NO];
    [progressView setUploadMessage:@"Uploading..."];
    [progressView setPhotoImage:thumbnail];
    progressView.delegate = self;
    [progressView setProgressTintColor:[UIColor colorWithRed:54/255.0 green:78.0/255.0 blue:141/255.0 alpha:1]];
    [progressView setProgressTrackColor:[UIColor colorWithRed:145/255.0 green:151/255.0 blue:168/255.0 alpha:1]];
    BeamUploadVC *viewController = [[BeamUploadVC alloc]initWithDelegate:progressView];
    [self ChannelPressed:self];
    [TablemyChannel setContentOffset:CGPointZero animated:YES];
}
-(void)updateProgressBar:(NSNotification*)notification
{
    [progressView uploadDidUpdate:appDelegate.progressFloat];
}
#pragma mark - WDUploadProgressView Delegate Methods
- (void)uploadDidFinish:(WDUploadProgressView *)progressview {
    [progressview removeFromSuperview];
    [self.TablemyChannel setTableHeaderView:nil];
}

- (void)uploadDidCancel:(WDUploadProgressView *)progressview {
    [progressview removeFromSuperview];
    [self.TablemyChannel setTableHeaderView:nil];
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSInteger tag = gestureRecognizer.view.tag;
    CGPoint p = [gestureRecognizer locationInView:self.TablemyChannel];
    NSIndexPath *indexPath = [self.TablemyChannel indexPathForRowAtPoint:p];
    if (indexPath == nil) {
       // NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//NSLog(@"begin");
        [editView setAlpha:0];
        [editView setHidden:NO];
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [editView setAlpha:1];
        [UIView commitAnimations];
        currentSelectedIndex = tag;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        //NSLog(@"ENDED");
        
    }
}
-(void) setcontentForCeleb{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"is_celeb"]){
        _profileViews.center = CGPointMake(self.view.center.x, _profileViews.center.y);
        if(IS_IPHONE_6Plus)
            _profileViews.center = CGPointMake(self.view.center.x + 20, _profileViews.center.y);
        userName.hidden = YES;
        userNameMid.hidden = NO;
    }
      //  _adsBar.hidden = YES;
        btnBBC.enabled = NO;
        btnRedBull.enabled = NO;
        btnEmirates.enabled = NO;
        adsViewb = FALSE;
        self.TablemyChannel.frame = CGRectMake(self.TablemyChannel.frame.origin.x, self.TablemyChannel.frame.origin.y - 50, self.TablemyChannel.frame.size.width, self.TablemyChannel.frame.size.height );
        originalChannelFrame = self.TablemyChannel.frame;
        if(IS_IPHONE_6Plus)
        {
            self.TablemyChannel.frame = CGRectMake(self.TablemyChannel.frame.origin.x, 300, self.TablemyChannel.frame.size.width, self.TablemyChannel.frame.size.height + 50);
//            originalChannelFrame = self.TablemyChannel.frame;
//            originalChannelFrame.origin.y += 40;
        }
   // }
//    else{
//          self.TablemyChannel.frame = CGRectMake(self.TablemyChannel.frame.origin.x, self.TablemyChannel.frame.origin.y + 5, self.TablemyChannel.frame.size.width, self.TablemyChannel.frame.size.height - 40);
//    }
    
}
-(void)initWithDataArr{
    uploadBeamTag = true;
    uploadAnonymous = false;
    pageNum = 1;
    forumPageNumber = 1;
    myCornerPageNum= 1;
    //PostArray = [[NSMutableArray alloc]init];
    forumsVideo = [[NSMutableArray alloc] init];
    newsfeedsVideos = [[NSMutableArray alloc] init];
    getTrendingVideos  = [[GetTrendingVideos alloc]init];
    myChannelObj = [[myChannelModel alloc]init];
    userChannelObj = [[UserChannelModel alloc]init];
    UsersModel = [[PopularUsersModel alloc]init];
    CommentsModelObj = [[CommentsModel alloc]init];
    getFollowings = [[Followings alloc] init];
    FollowingsAM = [[NSMutableArray alloc]init];
    friendsArray = [[NSArray alloc] init];
    channelVideos = [[NSMutableArray alloc] init];
    videomodel = [[VideoModel alloc]init];
    videoObj = [[NSMutableArray alloc] init];
    _forumTable.backgroundColor = [UIColor clearColor];
    _forumTable.opaque = NO;
//    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
//    [tempImageView setFrame:_forumTable.frame];
//    _forumTable.backgroundView = tempImageView;
    _TableHome.backgroundColor = [UIColor clearColor];
    _TableHome.opaque = NO;
//    UIImageView *tempImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
//    [tempImageView1 setFrame:_TableHome.frame];
//    _TableHome.backgroundView = tempImageView1;
    self.TablemyChannel.opaque = NO;
    self.TablemyChannel.backgroundColor = [UIColor clearColor];
    countDownlabel.textAlignment = NSTextAlignmentCenter;
    _searchTable.opaque = NO;
    _searchTable.backgroundColor = [UIColor clearColor];

}
-(void)setContentResolutions{
  
    if (IS_IPHONE_4) {
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 433, 320, 47);
    }else if (IS_IPAD){
        _BottomBar.frame = CGRectMake(0, 870, 768, 154);
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        [_mainScroller setContentSize:CGSizeMake(2304, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        originalChannelFrame.size.width = 768;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y += 640;
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 22.0f;
    }
    else if(IS_IPHONE_6){
        originalChannelFrame.size.width = 375;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y = 390;
        _optionsView.frame = CGRectMake(0, 0, 375, 667);
        searchView.frame = CGRectMake(0, 0, 375, 667);
        commentsTable.frame = CGRectMake(0,297,375,370);
        [_mainScroller setContentSize:CGSizeMake(1125, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        profilePic.frame = CGRectMake(profilePic.frame.origin.x-10, profilePic.frame.origin.y+20, profilePic.frame.size.width+20, profilePic.frame.size.height+20);
        countDownlabel.frame = CGRectMake(120,200,countDownlabel.frame.size.width,countDownlabel.frame.size.height);
        audioBtnImage.frame = CGRectMake(140, 250, audioBtnImage.frame.size.width, audioBtnImage.frame.size.height);
        _audioRecordBtn.frame = CGRectMake(140, 250, _audioRecordBtn.frame.size.width, _audioRecordBtn.frame.size.height);
        closeBtnAudio.frame = CGRectMake(330, 30, closeBtnAudio.frame.size.width, closeBtnAudio.frame.size.height);
    
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 28.0f;
        
    }
    else if(IS_IPHONE_6Plus)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 626, 414, 110);
        _optionsView.frame = CGRectMake(0, 0, 414, 736);
        [_forumTable setContentSize:CGSizeMake(414, _forumTable.frame.size.height)];
        searchView.frame = CGRectMake(0, 0, 414, 736);
        [_mainScroller setContentSize:CGSizeMake(1242, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        _uploadBeamView.frame = CGRectMake(0,0,414,736);
       
        channgelInnerView.frame = CGRectMake(channgelInnerView.frame.origin.x, channgelInnerView.frame.origin.y - 30, 414, channgelInnerView.frame.size.height);
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y += 10.0f;
        self.TablemyChannel.frame = CGRectMake(0, 355, 414, self.TablemyChannel.frame.size.height + 15);
        originalChannelFrame = self.TablemyChannel.frame;
        //originalChannelFrame.origin.y += 40.0f;
        channelContainerView.frame = CGRectMake(channelContainerView.frame.origin.x, channelContainerView.frame.origin.y , channelContainerView.frame.size.width, channelContainerView.frame.size.height );
        channelContainerOriginalFrame = channelContainerView.frame;
    }else if(IS_IPHONE_5)
    {
        _BottomBar.autoresizingMask = UIViewAutoresizingNone;
        _BottomBar.frame = CGRectMake(0, 468, 320, 100);
        [_mainScroller setContentSize:CGSizeMake(960, _mainScroller.frame.size.height)];
        [_mainScroller setContentOffset:CGPointMake(0,0)];
        originalChannelInnerViewFrame = channgelInnerView.frame;
        originalChannelInnerViewFrame.origin.y -= 22.0f;
        originalChannelFrame.size.width = 320;
        originalChannelFrame.size.height = 568;
        originalChannelFrame.origin.y = 345;
        
    }
    adsFrame = _adsView.frame;
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    float fadeDuration = 0.5;
    [UIView beginAnimations:@"FadeOut" context:nil];
    [UIView setAnimationDuration:fadeDuration ];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [editView setAlpha:0];
    [UIView setAnimationDidStopSelector:@selector(removeView)];
    [UIView commitAnimations];
    
    [self.view endEditing:YES];
}
-(void) removeView {
    [editView setHidden:YES];
}
- (void)leftSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(self.isMenuVisible){
        [self ShowDrawer:nil];
    }
}
- (void)rightSwipe:(UISwipeGestureRecognizer *)gesture
{
    if(!self.isMenuVisible){
        [self ShowDrawer:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)editBeam:(id)sender{
   // VideoModel *tempVideos  = [channelVideos objectAtIndex:currentSelectedIndex];
    editTTView.hidden = true;
    NSString *postIDs = selectedVideo.videoID;
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.video_thumbnail = selectedVideo.video_thumbnail_link;
    uploadController.postID = postIDs;
    uploadController.caption = selectedVideo.title;
    uploadController.friendsArray = friendsArray;
    appDelegate.hasbeenEdited = TRUE;
    [[self navigationController] pushViewController:uploadController animated:YES];
}



- (IBAction)ReportBtn:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    editTTView.hidden = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"reportPost",@"method",
                              token,@"session_token",selectedVideo.videoID,@"post_id",@"For No Reason",@"reason",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}


-(IBAction)DeleteBtn:(id)sender{
    [editTTView setHidden:YES];
    //VideoModel *tempVideos  = [channelVideos objectAtIndex:currentSelectedIndex];
    NSString *postId = selectedVideo.videoID;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"deletePost",@"method",
                              token,@"session_token",postId,@"post_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                [channelVideos removeObjectAtIndex:currentSelectedIndex];
                [self.TablemyChannel reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                NSInteger BeamsCount =  [userBeams.text integerValue];
                BeamsCount--;
                userBeams.text = [[NSString alloc]initWithFormat:@"%ld Beams",(long)BeamsCount];
            }
        }
        else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to update" message:@"Please check your internet connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
-(IBAction)BlockPerson:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    editView.hidden = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"blockUser",@"method",
                              token,@"session_token",selectedVideo.user_id,@"blocking_user_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                appDelegate.timeToupdateHome = TRUE;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
        }
        
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark Server Calls

- (void) getTrendingVideos{
    fetchingFroum = true;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *pageStr = [NSString stringWithFormat:@"%d",forumPageNumber];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_TRENDING_VIDEOS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
           // _ForumRefreshBtn.hidden = YES;
             [self.refreshControl endRefreshing];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                if(tempArray.count > 0)
                {
                    trendArray = [result objectForKey:@"posts"];
                    if(forumPageNumber == 1){
                        [forumsVideo removeAllObjects];
                    }
                    for(NSDictionary *tempDict in trendArray){
                        VideoModel *_Videos = [[VideoModel alloc] init];
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.videoID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
                        _Videos.rating = [[tempDict objectForKey:@"rating"] floatValue];

                        [forumsVideo addObject:_Videos];
                        
                    }
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (forumPageNumber-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<forumsVideo.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i/2 inSection:0]];
                        }
                    }
                    if(isDownwards && !fetchingFroum) {
                       
                        [_forumTable beginUpdates];
                        [_forumTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }else{
                        
                        [_forumTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    fetchingFroum = false;
                }
            }else
                cannotScrollForum = true;
        }
        else{
            fetchingFroum = false;
            //_ForumRefreshBtn.hidden = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to update" message:@"Please check your internet connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
-(void)getFollowingarray{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FOLLOWING_AND_FOLLOWERS,@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"following",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                friendsArray    = [result objectForKey:@"following"];
                appDelegate.friendsArray = friendsArray;
            }
        }
    }];

}
-(void) getFollowing{
    [FollowingsAM removeAllObjects];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FOLLOWING_AND_FOLLOWERS,@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"following",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                FollowingsArray = [result objectForKey:@"following"];
                friendsArray    = FollowingsArray;
                appDelegate.friendsArray = friendsArray;
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [_searchTable reloadData];
            }
        }
    }];
}
-(void) getFollowers{
    [FollowingsAM removeAllObjects];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_FOLLOWING_AND_FOLLOWERS,@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"followers",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [SVProgressHUD dismiss];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                FollowingsArray = [result objectForKey:@"followers"];
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [_searchTable reloadData];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
        }
    }];
}
-(void)sendDeviceToken{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *deviceTokens = [AppDelegate getDeviceToken];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"registerDevice",@"method",deviceTokens,@"device_id",token,@"Session_token",@"IOS",@"device_type",@"notAndroid",@"gcm_reg_id",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@",result);
        }
    }];
}
- (void) getHomeContent{
    fetchingContent = true;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    secondsConsumed  = 0;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *pageStr = [NSString stringWithFormat:@"%d",pageNum];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_HOME_CONTENTS,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    // _homeRefreshBtn.hidden = YES;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
           
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.refreshControlHome endRefreshing];
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            
            
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                
                if(tempArray.count> 0) {
                    newsfeedPostArray = [result objectForKey:@"posts"];
                    if(pageNum == 1){
                        newsfeedsVideos = [[NSMutableArray alloc] init];
                    }
                    for(NSDictionary *tempDict in newsfeedPostArray){
                        VideoModel *_Videos = [[VideoModel alloc] init];
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.videoID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
                        _Videos.rating = [[tempDict objectForKey:@"rating"] floatValue];
                        [newsfeedsVideos addObject:_Videos];
                        
                    }
                    
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (pageNum-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i<newsfeedsVideos.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i/2 inSection:0]];
                        }
                    }
                    if(isDownwards && !fetchingContent) {
                        [_TableHome beginUpdates];
                        [_TableHome insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else {
                            [_TableHome reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    fetchingContent = false;
                }
            }
            else
            {
                cannotScroll = true;
            }
            if ([newsfeedsVideos count] == 0) {
                [noBeamsView setHidden:NO];
            }else{
                noBeamsView.hidden = YES;
            }
        }
        else{
          [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            fetchingContent = false;
           // _homeRefreshBtn.hidden = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to update" message:@"Please check your internet connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
}


- (void) getMyChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    fetchingCorner = TRUE;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *pageStr = [NSString stringWithFormat:@"%d",myCornerPageNum];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_MY_CHENNAL,@"method",
                              token,@"session_token",pageStr,@"page_no",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            _ChannelRefreshBtn.hidden = YES;
            fetchingCorner = FALSE;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *posts = [result objectForKey:@"profile"];
            
            if(success == 1) {
                NSArray *tempArray = [result objectForKey:@"posts"];
                myChannelModel *_profile = [[myChannelModel alloc] init];
                _profile.beams_count = [posts objectForKey:@"beams_count"];
                _profile.friends_count = [posts objectForKey:@"following_count"];
                _profile.full_name = [posts objectForKey:@"full_name"];
                // _profile.cover_link = [posts objectForKey:@"cover_link"];
                _profile.user_id = [posts objectForKey:@"id"];
                _profile.profile_image = [posts objectForKey:@"profile_link"];
                _profile.likes_count = [posts objectForKey:@"followers_count"];
                _profile.gender = [posts objectForKey:@"gender"];
                _profile.email = [posts objectForKey:@"email"];
                _profile.is_celeb = [posts objectForKey:@"is_celeb"];
                _profile.cover_image = [posts objectForKey:@"cover_link"];
                myProfile = _profile;
                appDelegate.myprofile = _profile;
                User_pic.imageURL = [NSURL URLWithString:_profile.profile_image];
                NSURL *url = [NSURL URLWithString:_profile.profile_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
                channelCover.imageURL = [NSURL URLWithString:_profile.cover_image];
                NSURL *url1 = [NSURL URLWithString:_profile.cover_image];
                [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
                
                chPostArray = [[NSArray alloc] init];
                userName.text = _profile.full_name;
                userNameMid.text = _profile.full_name;
                userBeams.text = _profile.beams_count ;
                int tcount = [_profile.beams_count intValue];
                if (tcount <=  1) {
                    [_btnVideos setTitle: @"Video" forState: UIControlStateNormal];
                    _lblVideos.text = @"Video";

                }
                userFriends.text = _profile.friends_count;
                userLikes.text = _profile.likes_count;
                if(tempArray.count > 0)
                {
                    //channelVideos = [[NSMutableArray alloc] init];
                    
                    chPostArray = [result objectForKey:@"posts"];
                
                   for(NSDictionary *tempDict in chPostArray){
                        VideoModel *_Videos = [[VideoModel alloc] init];
                        _Videos.title = [tempDict objectForKey:@"caption"];
                        _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                        _Videos.userName = [tempDict objectForKey:@"full_name"];
                        _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                        _Videos.user_id = [tempDict objectForKey:@"user_id"];
                        _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                        _Videos.like_count = [tempDict objectForKey:@"like_count"];
                        _Videos.like_by_me = [tempDict objectForKey:@"liked_by_me"];
                        _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                        _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                        _Videos.video_link = [tempDict objectForKey:@"video_link"];
                        _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                        _Videos.videoID = [tempDict objectForKey:@"id"];
                        _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                        _Videos.video_length = [tempDict objectForKey:@"video_length"];
                        _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                        _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
                       _Videos.rating = [[tempDict objectForKey:@"rating"] floatValue];

                        [channelVideos addObject:_Videos];
                   }
                    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                    int startIndex = (myCornerPageNum-1) *10;
                    for (int i = startIndex ; i < startIndex+10; i++) {
                        if(i < channelVideos.count) {
                            [indexPaths addObject:[NSIndexPath indexPathForRow:i/2 inSection:0]];
                        }
                    }
                    if(isDownwards)
                    {
                        [TablemyChannel beginUpdates];
                        [TablemyChannel insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [TablemyChannel endUpdates];
                    }else
                    {
                        [self.TablemyChannel reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
                else
                    cannotScrollMyCorner = true;
            }
            else{
                fetchingCorner = FALSE;
                _ChannelRefreshBtn.hidden = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to update" message:@"Please check your internet connection!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }];
}


#pragma mark - PulltoRefresh
- (IBAction)homeRefreshBtnPressed:(id)sender {
    pageNum = 1;
    [self getHomeContent];
    myCornerPageNum = 1;
    [self getMyChannel];
}

- (IBAction)ForumRefreshBtnPressed:(id)sender {
    forumPageNumber = 1;
    [self getTrendingVideos];
}
- (IBAction)ChannelRefreshBtnPressed:(id)sender {
    myCornerPageNum = 1;
    [self getMyChannel];
}
- (void)setupRefreshControl
{
    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = _forumTable;
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor       = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshForum:) forControlEvents:UIControlEventValueChanged];
    [_forumTable addSubview:_refreshControl];
}
//
- (void)refreshForum:(id)sender
{
    forumPageNumber = 1;
    [self getTrendingVideos];
    
}
- (void)setupRefreshControlHome
{
    self.refreshControlHome = [[UIRefreshControl alloc] init];
    self.refreshControlHome.backgroundColor = [UIColor clearColor];
    self.refreshControlHome.tintColor       = [UIColor whiteColor];
    [self.refreshControlHome addTarget:self action:@selector(refreshHome:) forControlEvents:UIControlEventValueChanged];
    [_TableHome addSubview:_refreshControlHome];
}
//
- (void)refreshHome:(id)sender
{
    pageNum = 1;
    [self getHomeContent];
    
}
//- (void)setupRefreshControlChannel
//{
//    
//    UITableViewController *tableViewController = [[UITableViewController alloc] init];
//    tableViewController.tableView = self.TablemyChannel;
//    self.refreshControlChannel = [[UIRefreshControl alloc] init];
//    _refreshControlChannel.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
//    [self.refreshControlChannel addTarget:self action:@selector(refreshChannel:) forControlEvents:UIControlEventValueChanged];
//    tableViewController.refreshControl = self.refreshControlChannel;
//}
//
//- (void)refreshChannel:(id)sender
//{
//    if(tabBarIsShown)
//        [self getMyChannel];
//    
//}
#pragma mark - IBButton Actions
- (IBAction)CancelEditBtn:(id)sender{
    viewItems.hidden = YES;
    editTTView.hidden = YES;

}
-(IBAction)fbshareBtn:(id)sender
{
    [editView setHidden:YES];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:selectedVideo.title];
        [mySLComposerSheet addURL:[NSURL URLWithString:selectedVideo.video_link]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else {
        
        NSString *message;
        NSString *title;
        NSString *cancel;
        message = @"Go to Device Settings and set up Facebook Account";
        title = @"Account Configuration Error";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
-(IBAction)twitterShareBtn:(id)sender
{
    [editView setHidden:YES];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:selectedVideo.title];
        [mySLComposerSheet addURL:[NSURL URLWithString:selectedVideo.video_link]];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    else {
        
        NSString *message;
        NSString *title;
        NSString *cancel;
        message = @"Go to Device Settings and set up Twitter Account";
        title   = @"Account Configuration Error";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    

}

-(IBAction)blockBtn:(id)sender{
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"] == selectedVideo.user_id){
        [self DeleteBtn:self];
    }
    else{
        [self BlockPerson:self];
    }
}
-(IBAction)reporttapped:(id)sender{
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"] == selectedVideo.user_id){
        [self editBeam:self];
    }
    else{
        [self ReportBtn:self];
    }
}

#pragma mark - Like Post
- (void) LikePost:(NSUInteger )indexToLike{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_POST,@"method",
                              token,@"session_token",postID,@"post_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                if ([message isEqualToString:@"Post is Successfully liked."]) {
                    liked = YES;
                    if(currentState == 2){
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [forumsVideo  objectAtIndex:indexToLike];
                        _Videos.like_count = [[forumsVideo objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [forumsVideo replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_forumTable beginUpdates];
                        [_forumTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }
                    else if (currentState == 0)
                    {
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [newsfeedsVideos objectAtIndex:indexToLike];
                        _Videos.like_count = [[newsfeedsVideos  objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [newsfeedsVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TableHome beginUpdates];
                        [_TableHome reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else if (currentState == 3)
                    {
                        myChannelModel *_Videos = [[myChannelModel alloc]init];
                        _Videos = [channelVideos  objectAtIndex:indexToLike];
                        _Videos.like_count = [[channelVideos objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        likeCount++;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"1";
                        [channelVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [self.TablemyChannel beginUpdates];
                        [self.TablemyChannel reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [self.TablemyChannel endUpdates];
                    }
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                {
                    liked = NO;
                    if(currentState == 2){
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [forumsVideo  objectAtIndex:indexToLike];
                        _Videos.like_count = [[forumsVideo objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [forumsVideo replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_forumTable beginUpdates];
                        [_forumTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_forumTable endUpdates];
                    }
                    else if (currentState == 0)
                    {
                        GetTrendingVideos *_Videos = [[GetTrendingVideos alloc] init];
                        _Videos = [newsfeedsVideos objectAtIndex:indexToLike];
                        _Videos.like_count = [[newsfeedsVideos  objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [newsfeedsVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [_TableHome beginUpdates];
                        [_TableHome reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [_TableHome endUpdates];
                    }
                    else if (currentState == 3)
                    {
                        myChannelModel *_Videos = [[myChannelModel alloc]init];
                        _Videos = [channelVideos  objectAtIndex:indexToLike];
                        _Videos.like_count = [[channelVideos objectAtIndex:indexToLike]valueForKey:@"like_count"];
                        NSInteger likeCount = [_Videos.like_count intValue];
                        if(likeCount > 0)
                            likeCount--;
                        _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                        _Videos.like_by_me = @"0";
                        [channelVideos replaceObjectAtIndex:indexToLike withObject:_Videos];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike/2 inSection:0];
                        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                        [self.TablemyChannel beginUpdates];
                        [self.TablemyChannel reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                        [self.TablemyChannel endUpdates];
                    }
                }
            }
        }
        
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void) SeenPost{
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_POST_SEEN,@"method",
                              token,@"session_token",postID,@"post_id",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            
            if(success == 1) {
                if ([message isEqualToString:@"Post is Successfully liked."]) {
                    seenPost = YES;
                }else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                    seenPost = NO;
                
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}


-(void) setUserProfileImage {
//    User_pic.layer.cornerRadius = User_pic.frame.size.width / 4;
//    User_pic.clipsToBounds = YES;
//    User_pic.layer.masksToBounds = YES;
    picBorder.layer.cornerRadius = picBorder.frame.size.width / 2;
    picBorder.clipsToBounds = YES;
    picBorder.layer.masksToBounds = NO;
    
      _viewToRound.layer.cornerRadius = _viewToRound.frame.size.width / 2;
      _viewToRound.layer.masksToBounds = YES;
     _viewToRound.clipsToBounds = YES;
}




#pragma mark - TableView Data Source





- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if(tableView.tag == 3) {
    //        if(indexPath.row == trendArray.count-1 && !self.isLoading){
    //            forumPageNumber++;
    //            [self getTrendingVideos];
    //        }
    //    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView.tag == 2) {
        //        if(appDelegate.IS_celeb && indexPath.row == 0) {
        //            if (IS_IPAD)
        //                returnValue = 200.0f;
        //            else
        //                returnValue = 112;
        //        }
        //        else {
        if (IS_IPAD)
            returnValue = 410.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 327.0f;
        //}
        
    }
    else {
        if (IsStatus== YES) {
            if (IS_IPAD)
                returnValue = 350.0f;
            else
                returnValue = 180.0f;
        }
        else {
            if (IS_IPAD)
                returnValue = 362.0f;
            else
                returnValue = 180.0f;
        }
    }
    if(tableView.tag == 10) {
        
        if (IS_IPAD)
            returnValue = 410.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 327.0;
    }
    
    if(tableView.tag == 3) {
        
        if (IS_IPAD)
            returnValue = 410.0f;
        else if(IS_IPHONE_5)
            returnValue = 150.0f;
        else
            returnValue = 327.0f;
    }
    if(tableView.tag == 20) {
        
        if (IS_IPAD)
            returnValue = 95.0f;
        else
            returnValue = 95.0f;
    }
    if(tableView.tag == 30) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    if(tableView.tag == 25) {
        
        if (IS_IPAD)
            returnValue = 362.0f;
        else
            returnValue = 250.0f;
    }
    
    return returnValue;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (tableView.tag == 10) {
//        int rows = (int)([newsfeedsVideos count]/2);
//        if([] %2 == 1) {
//            rows++;
     //   }
        return [newsfeedsVideos count];
        
    }else if (tableView.tag == 3 && forumsVideo != nil){
        int rows = (int)([forumsVideo count]/2);
        if([forumsVideo count] %2 == 1) {
            rows++;
        }
        return rows;
    }else if (tableView.tag == 2){
        int rows = (int)([channelVideos count]/2);
        if([channelVideos count] %2 == 1) {
            rows++;
        }
        return rows;
//        if(appDelegate.IS_celeb) {
//            value = value+1;
//        }
        //value = value ;
    }else if (tableView.tag == 20){
            value = FollowingsAM.count;
    }else if (tableView.tag == 25){
        
        value = chPostArray.count;
    }else if (tableView.tag == 30){
        
        value = CommentsArray.count;
    }
    return value;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 10) {
        //ChannelCell *cell;
        HomeCell *cell;
        IsStatus = NO;
        currentIndexHome = indexPath.row ;
        if (IS_IPAD) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }
        VideoModel *tempVideos = [[VideoModel alloc]init];
        tempVideos  = [newsfeedsVideos objectAtIndex:currentIndexHome];
        cell.CH_userName.text = tempVideos.userName;
        cell.videoId = tempVideos.videoID;
        cell.isUserChannel = false;
        cell.isVCPlayer = false;
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        //cell.CH_profileImage.image = [NSURL URLWithString:tempVideos.profile_image];
        cell.CH_profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        [cell setupRating:tempVideos.rating];
        cell.startRating.tag = indexPath.row;
        cell.CH_seen.text = tempVideos.seen_count;
        //tempVideos.video_link = [newsfeedVideosArray objectAtIndex:indexPath.row];
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.anonyleft.hidden = YES;
        }
        else{
            //cell.CH_Video_Thumbnail.image = [UIImage imageNamed:@"anonymousDp.png"];
            cell.anonyleft.hidden = NO;
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
        }
        
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        //[cell.btnMenu addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];

        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        //[cell.CH_Video_Thumbnail roundCorners];
 
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMenu setTag:currentIndexHome];

        [cell.btnMenu addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

        //appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = currentIndexHome;
        [cell.CH_heart setTag:currentIndexHome];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentIndexHome];
        
        [cell.CH_flag setTag:currentIndexHome];
        cell.CH_commentsBtn.enabled = YES;
        // cell.CH_RcommentsBtn.enabled = YES;
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentIndexHome];
//        currentIndexHome++;
//        if(currentIndexHome < newsfeedsVideos.count)
//        {
//            VideoModel *tempVideos = [[VideoModel alloc]init];
//            tempVideos  = [newsfeedsVideos objectAtIndex:currentIndexHome];
//            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RcommentsBtn setTag:currentIndexHome];
//            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RplayVideo setTag:currentIndexHome];
//            [cell.CH_Rheart setTag:currentIndexHome];
//            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
//            cell.CH_RVideoTitle.text = tempVideos.title;
//            cell.CH_Rseen.text = tempVideos.seen_count;
//            cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /6.2f;
//            if(IS_IPAD)
//                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
//            cell.RimgContainer.layer.masksToBounds = YES;
//            [cell.CH_RVideo_Thumbnail roundCorners];
//            cell.CH_RheartCountlbl.text             = tempVideos.like_count;
//            if([tempVideos.comments_count isEqualToString:@"0"])
//            {
//                cell.CH_RCommentscountLbl.hidden = YES;
//                cell.rightreplImg.hidden = YES;
//            }
//            else{
//                 cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
//            }
//            cell.CH_RuserName.text = tempVideos.userName;
//            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            if([tempVideos.is_anonymous  isEqualToString: @"0"]){
//                cell.anonyright.hidden = YES;
//            }
//            else{
//                //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
//                cell.anonyright.hidden = NO;
//                cell.CH_RuserName.text = @"Anonymous";
//            }
//            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//            }else{
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//            }
//            currentIndexHome++;
//        }
//        else{
//            cell.CH_RprofileImage.hidden = YES;
//            cell.CH_Rseen.hidden = YES;
//            cell.CH_RcommentsBtn.hidden = YES;
//            cell.CH_RuserName.hidden = YES;
//            cell.CH_Rheart.hidden = YES;
//            cell.RimgContainer.hidden = YES;
//            cell.CH_RplayVideo.hidden = YES;
//            cell.Rtransthumb.hidden = YES;
//            cell.CH_RVideoTitle.hidden = YES;
//            cell.rightreplImg.hidden = YES;
//            cell.CH_RCommentscountLbl.hidden = YES;
//            cell.playImage.hidden = YES;
//        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if(tableView.tag == 3){
        
        //ChannelCell *cell;
        HomeCell *cell;
        IsStatus = NO;
       // currentIndex = (indexPath.row * 2);
        currentIndex = indexPath.row ;

        if (IS_IPAD) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }
        float tableheight  = 0;
        if(forumsVideo.count % 2 == 0)
            tableheight = forumsVideo.count/1.8;
        else
            tableheight = forumsVideo.count/1.7;
//        _forumTable.contentSize = CGSizeMake(_forumTable.frame.size.width,(tableheight * cell.frame.size.height));
        VideoModel *tempVideos = [[VideoModel alloc]init];
        tempVideos  = [forumsVideo objectAtIndex:currentIndex];
        cell.CH_userName.text = tempVideos.userName;
        cell.videoId = tempVideos.videoID;
        cell.isUserChannel = false;
        cell.isVCPlayer = false;
        cell.Ch_videoLength.text = tempVideos.video_length;
        cell.CH_VideoTitle.text = tempVideos.title;
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        cell.CH_profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        [cell setupRating:tempVideos.rating];
        cell.startRating.tag = indexPath.row;
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        //tempVideos.video_link = [videosArray objectAtIndex:indexPath.row];
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.anonyleft.hidden  = YES;
        }
        else{
           // cell.CH_Video_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.userProfileView.enabled = false;
            cell.anonyleft.hidden  = NO;
        }
     
        [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
        cell.userProfileView.tag = indexPath.row;
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        //[cell.CH_Video_Thumbnail roundCorners];
        cell.CH_commentsBtn.enabled = YES;
        //cell.CH_RcommentsBtn.enabled = YES;
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMenu addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

        [cell.CH_heart setTag:currentIndex];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
      
        [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentIndex];
        [cell.btnMenu setTag:currentIndex];

        [cell.CH_flag setTag:currentIndex];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentIndex];
//        currentIndex++;
//        if(currentIndex < forumsVideo.count)
//        {
//            VideoModel *tempVideos = [[VideoModel alloc]init];
//            tempVideos  = [forumsVideo objectAtIndex:currentIndex];
//            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RcommentsBtn setTag:currentIndex];
//            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RplayVideo setTag:currentIndex];
//            [cell.CH_Rheart setTag:currentIndex];
//            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
//            cell.CH_RVideoTitle.text = tempVideos.title;
//            cell.CH_Rseen.text = tempVideos.seen_count;
//            cell.RimgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
//            if(IS_IPAD)
//                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
//            cell.RimgContainer.layer.masksToBounds = YES;
//            [cell.CH_RVideo_Thumbnail roundCorners];;
//
//            cell.CH_RheartCountlbl.text             = tempVideos.like_count;
//            if([tempVideos.comments_count isEqualToString:@"0"])
//            {
//                cell.CH_RCommentscountLbl.hidden = YES;
//                cell.rightreplImg.hidden = YES;
//            }
//            else{
//                cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
//            }
//            cell.CH_RuserName.text = tempVideos.userName;
//            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            if([tempVideos.is_anonymous  isEqualToString: @"0"]){
//                cell.anonyright.hidden = YES;
//            }
//            else{
//                //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
//                cell.CH_RuserName.text = @"Anonymous";
//                cell.anonyright.hidden = NO;
//            }
//            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//            }else{
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//            }
//            currentIndex++;
//        }
//        else{
//            cell.CH_RprofileImage.hidden = YES;
//            cell.CH_Rseen.hidden = YES;
//            cell.CH_RcommentsBtn.hidden = YES;
//            cell.CH_RuserName.hidden = YES;
//            cell.CH_Rheart.hidden = YES;
//            cell.RimgContainer.hidden = YES;
//            cell.CH_RplayVideo.hidden = YES;
//            cell.Rtransthumb.hidden = YES;
//            cell.CH_RVideoTitle.hidden = YES;
//            cell.rightreplImg.hidden = YES;
//            cell.CH_RCommentscountLbl.hidden = YES;
//            cell.playImage.hidden = YES;
//        }
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    if (tableView.tag == 2 ) {
        
//        if(indexPath.row == 0 && appDelegate.IS_celeb) {
//            AdvertismentCell *cell;
//            IsStatus = NO;
//            if (IS_IPAD) {
//                
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell_iPad" owner:self options:nil];
//                cell = [nib objectAtIndex:0];
//            }
//            else{
//                
//                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AdvertismentCell" owner:self options:nil];
//                cell = [nib objectAtIndex:0];
//            }
//            [cell setBackgroundColor:BlueThemeColor(241, 245, 248)];
//            cell.selectionStyle = UITableViewCellSeparatorStyleNone;
//            return cell;
//        }
//        else {
        HomeCell *cell;
        IsStatus = NO;
       // currentChanelIndex = (indexPath.row * 2);
        currentChanelIndex = indexPath.row ;

        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else if(IS_IPHONE_5){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        if(IS_IPHONE_6Plus){
            cell.leftreplImg.frame = CGRectMake(cell.leftreplImg.frame.origin.x + 15, cell.leftreplImg.frame.origin.y, cell.leftreplImg.frame.size.width, cell.leftreplImg.frame.size.width);
            cell.CH_CommentscountLbl.frame = CGRectMake(cell.CH_CommentscountLbl.frame.origin.x + 15, cell.CH_CommentscountLbl.frame.origin.y, cell.CH_CommentscountLbl.frame.size.width , cell.CH_CommentscountLbl.frame.size.height);
        }

        VideoModel *tempVideos = [[VideoModel alloc]init];
        tempVideos  = [channelVideos objectAtIndex:currentChanelIndex];
        [cell setupRating:tempVideos.rating];
        cell.startRating.tag = indexPath.row;
        cell.CH_userName.text = tempVideos.userName;
        cell.videoId = tempVideos.videoID;
        cell.isUserChannel = false;
        cell.isVCPlayer = false;
        cell.CH_VideoTitle.text = tempVideos.title;
        if([tempVideos.comments_count isEqualToString:@"0"])
        {
            cell.CH_CommentscountLbl.hidden = YES;
            cell.leftreplImg.hidden = YES;
        }
        else{
            cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        }
        cell.CH_profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_image];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        cell.Ch_videoLength.text = tempVideos.video_length;
        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
            cell.anonyleft.hidden  = YES;
        }
        else{
            // cell.CH_Video_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
            cell.CH_userName.text = @"Anonymous";
            cell.anonyleft.hidden  = NO;
        }

        NSURL *url1;
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
        if(IS_IPAD)
            cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /7.4f;
        cell.imgContainer.layer.masksToBounds = YES;
        //[cell.CH_Video_Thumbnail roundCorners];
        cell.CH_commentsBtn.enabled = YES;
        //cell.CH_RcommentsBtn.enabled = YES;
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0;
        [cell.CH_commentsBtn addGestureRecognizer:lpgr];
        [lpgr.view setTag:currentChanelIndex];
        [cell.CH_heart setTag:currentChanelIndex];
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnMenu setTag:currentChanelIndex];

        [cell.btnMenu addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:currentChanelIndex];

        [cell.CH_flag setTag:currentChanelIndex];
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:currentChanelIndex];
        
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
//        currentChanelIndex++;
//        if(currentChanelIndex < channelVideos.count)
//        {
//            VideoModel *tempVideos = [[VideoModel alloc]init];
//            tempVideos  = [channelVideos objectAtIndex:currentChanelIndex];
//            [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RcommentsBtn setTag:currentChanelIndex];
//            [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.CH_RplayVideo setTag:currentChanelIndex];
//            [cell.CH_Rheart setTag:currentChanelIndex];
//            [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
//            cell.CH_RVideoTitle.text = tempVideos.title;
//            cell.CH_Rseen.text = tempVideos.seen_count;
//            cell.RimgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
//            if(IS_IPAD)
//                cell.RimgContainer.layer.cornerRadius  = cell.RimgContainer.frame.size.width /7.4f;
//            cell.RimgContainer.layer.masksToBounds = YES;
//            UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
//                                                  initWithTarget:self action:@selector(handleLongPress:)];
//            lpgr.minimumPressDuration = 1.0;
//            [cell.CH_RcommentsBtn addGestureRecognizer:lpgr];
//            [cell.CH_heart setTag:currentChanelIndex];
//            cell.CH_RheartCountlbl.text  = tempVideos.like_count;
//            if([tempVideos.comments_count isEqualToString:@"0"])
//            {
//                cell.CH_RCommentscountLbl.hidden = YES;
//                cell.rightreplImg.hidden = YES;
//            }
//            else{
//                cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
//            }
//            if([tempVideos.is_anonymous  isEqualToString: @"0"]){
//                cell.anonyright.hidden  = YES;
//            }
//            else{
//                // cell.CH_Video_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
//                cell.CH_userName.text = @"Anonymous";
//                cell.anonyright.hidden  = NO;
//            }
//
//            cell.CH_RuserName.text = tempVideos.userName;
//            cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            [cell.CH_RVideo_Thumbnail roundCorners];
//            if ([tempVideos.like_by_me isEqualToString:@"1"]) {
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//            }else{
//                [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//            }
//            currentChanelIndex++;
//            
//        }else{
//            cell.CH_RprofileImage.hidden = YES;
//            cell.CH_Rseen.hidden = YES;
//            cell.CH_RcommentsBtn.hidden = YES;
//            cell.CH_RuserName.hidden = YES;
//            cell.CH_Rheart.hidden = YES;
//            cell.RimgContainer.hidden = YES;
//            cell.CH_RplayVideo.hidden = YES;
//            cell.Rtransthumb.hidden = YES;
//            cell.CH_RVideoTitle.hidden = YES;
//            cell.rightreplImg.hidden = YES;
//            cell.CH_RCommentscountLbl.hidden = YES;
//            cell.playImage.hidden = YES;
//        }
    
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        // }
    }
    if (tableView.tag == 20) {
        SearchCell *cell;
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SearchCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
//        if(!searchcorners){
            Followings *tempUsers = [[Followings alloc]init];
            tempUsers = [FollowingsAM objectAtIndex:indexPath.row];
            cell.friendsName.text = tempUsers.fullName;
            
            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
            
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
            for (UIView* subview in cell.profilePic.subviews)
                subview.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
            
            cell.profilePic.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.profilePic.layer.shadowOpacity = 0.7f;
            cell.profilePic.layer.shadowOffset = CGSizeMake(0, 5);
            // cell.profilePic.layer.shadowRadius = 5.0f;
            cell.profilePic.layer.masksToBounds = NO;
            
            cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width / 2;
            cell.profilePic.layer.masksToBounds = NO;
            cell.profilePic.clipsToBounds = YES;
            
            cell.profilePic.layer.backgroundColor = [UIColor clearColor].CGColor;
            cell.profilePic.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.profilePic.layer.borderWidth = 0.0f;
            
            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.statusImage setTag:indexPath.row];
            cell.statusImage.hidden = false;
            cell.activityInd.hidden = true;
            [cell.activityInd stopAnimating];
            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
                
               // [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                cell.statusImage.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
                [cell.statusImage setTitle:@"FOLLOW" forState:UIControlStateNormal];
                cell.statusImage.frame = CGRectMake(278,30,80,30);
            }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
                
                //[cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
                cell.statusImage.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1];
                [cell.statusImage setTitle:@"FOLLOWING" forState:UIControlStateNormal];
                cell.statusImage.frame = CGRectMake(260,30,100,30);

            }
            
            if ([tempUsers.status isEqualToString:@"PENDING"]) {
                cell.statusImage.hidden = true;
                cell.activityInd.hidden = false;
                [cell.activityInd startAnimating];
            }
            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
            [cell.friendsChannelBtn setTag:indexPath.row];
            
//            if (SearchforTag == YES) {
//                cell.tagbtn.hidden = NO;
//                cell.statusImage.hidden = YES;
//                
//            }else{
//                cell.tagbtn.hidden = YES;
//                cell.statusImage.hidden = NO;
//            }
            [cell.tagbtn addTarget:self action:@selector(TagFriend:) forControlEvents:UIControlEventTouchUpInside];
            [cell.tagbtn setTag:indexPath.row];
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        //}
//        else {
//            PopularUsersModel *tempUsers = [[PopularUsersModel alloc] init];
//            tempUsers =  [UsersModel.PopUsersArray objectAtIndex:indexPath.row];
//            cell.friendsName.text = tempUsers.full_name;
//            
//            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
//            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            [cell.profilePic roundImageCorner];
//            
//            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.statusImage setTag:indexPath.row];
//            cell.statusImage.hidden = false;
//            cell.activityInd.hidden = true;
//            [cell.activityInd stopAnimating];
//            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
//            }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
//            }
//            
//            if ([tempUsers.status isEqualToString:@"PENDING"]) {
//                cell.statusImage.hidden = true;
//                cell.activityInd.hidden = false;
//                [cell.activityInd startAnimating];
//            }
//            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.friendsChannelBtn setTag:indexPath.row];
//            [cell setBackgroundColor:[UIColor clearColor]];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//            
//        }
//        else{
//            
//            Followings *tempUsers = [[Followings alloc]init];
//            tempUsers = [FollowingsAM objectAtIndex:indexPath.row];
//            cell.friendsName.text = tempUsers.fullName;
//            
//            cell.profilePic.imageURL = [NSURL URLWithString:tempUsers.profile_link];
//            NSURL *url = [NSURL URLWithString:tempUsers.profile_link];
//            [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//            [cell.profilePic roundImageCorner];
//            
//            [cell.statusImage addTarget:self action:@selector(statusPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.statusImage setTag:indexPath.row];
//            cell.statusImage.hidden = false;
//            cell.activityInd.hidden = true;
//            [cell.activityInd stopAnimating];
//            if ([tempUsers.status isEqualToString:@"ADD_FRIEND"]) {
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
//            }else if ([tempUsers.status isEqualToString:@"FRIEND"]){
//                
//                [cell.statusImage setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
//            }
//            
//            if ([tempUsers.status isEqualToString:@"PENDING"]) {
//                cell.statusImage.hidden = true;
//                cell.activityInd.hidden = false;
//                [cell.activityInd startAnimating];
//            }
//            [cell.friendsChannelBtn addTarget:self action:@selector(OpenFriendsChannelPressed:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.friendsChannelBtn setTag:indexPath.row];
//            [cell setBackgroundColor:[UIColor clearColor]];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
    }
    
    if (tableView.tag == 25) {
        ChannelCell *cell;
        
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChannelCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
        
        tempVideos  = [chPostArray objectAtIndex:indexPath.row];
        cell.CH_userName.text = tempVideos.userName;
        
        cell.CH_VideoTitle.text = tempVideos.title;
        cell.CH_CommentscountLbl.text = tempVideos.comments_count;
        cell.CH_heartCountlbl.text = tempVideos.like_count;
        cell.CH_seen.text = tempVideos.seen_count;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.videotags = tempVideos.Tags;
        appDelegate.profile_pic_url = tempVideos.profile_image;
        cell.Ch_videoLength.text = tempVideos.video_length;
        tempVideos.video_link = [chVideosArray objectAtIndex:indexPath.row];
        
        cell.CH_profileImage.imageURL = [NSURL URLWithString:[chArrImage objectAtIndex:indexPath.row]];
        NSURL *url = [NSURL URLWithString:[chArrImage objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
        NSURL *url1 = [NSURL URLWithString:[chArrThumbnail objectAtIndex:indexPath.row]];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        
        cell.CH_profileImage.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
//        for (UIView* subview in cell.CH_profileImage.subviews)
//            subview.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
//        
//        cell.CH_profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
//        cell.CH_profileImage.layer.shadowOpacity = 0.7f;
//        cell.CH_profileImage.layer.shadowOffset = CGSizeMake(0, 5);
//        cell.CH_profileImage.layer.shadowRadius = 5.0f;
//        cell.CH_profileImage.layer.masksToBounds = NO;
//        
//        cell.CH_profileImage.layer.cornerRadius = cell.CH_profileImage.frame.size.width / 2;
//        cell.CH_profileImage.layer.masksToBounds = NO;
//        cell.CH_profileImage.clipsToBounds = YES;
//        
//        cell.CH_profileImage.layer.backgroundColor = [UIColor clearColor].CGColor;
//        cell.CH_profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
//        cell.CH_profileImage.layer.borderWidth = 0.0f;
//        
        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        [sgr setDirection:UISwipeGestureRecognizerDirectionRight];
        [cell addGestureRecognizer:sgr];
        
        
        [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
        appDelegate.videotoPlay = [userChannelObj.mainArray objectAtIndex:indexPath.row];
        [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_flag addTarget:self action:@selector(editPost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_playVideo setTag:indexPath.row];
        [cell.CH_heart setTag:indexPath.row];
        [cell.CH_flag setTag:indexPath.row];
        
        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        
        [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.CH_commentsBtn setTag:indexPath.row];
        
        
        return cell;
    }
    if(tableView.tag == 30){
        CommentsCell *cell;
        
        if (IS_IPAD) {
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        else{
            
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        commentsTable.contentSize = CGSizeMake(_forumTable.frame.size.width,CommentsArray.count * returnValue + _BottomBar.frame.size.height + 30);
        CommentsModel *tempVideos = [[CommentsModel alloc]init];
        tempVideos  = [CommentsArray objectAtIndex:indexPath.row];
        cell.userName.text = tempVideos.userName;
        cell.VideoTitle.text = tempVideos.title;
        
        cell.CommentscountLbl.text = tempVideos.comments_count;
        cell.heartCountlbl.text = tempVideos.like_count;
        cell.seenLbl.text = tempVideos.seen_count;
        cell.userName.text = tempVideos.userName;
        
        appDelegate.videotitle = tempVideos.title;
        appDelegate.profile_pic_url = tempVideos.profile_link;
        
        tempVideos.video_link = [CommentsModelObj.mainArray objectAtIndex:indexPath.row];
        cell.videoLength.text = tempVideos.video_length;
        
        //        cell.profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
        //
        //        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
        NSURL *url = [NSURL URLWithString:tempVideos.profile_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        
        cell.videoThumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
        if([tempVideos.video_thumbnail_link isEqualToString:@""] )
        {
            cell.videoThumbnail.imageURL = [NSURL URLWithString:tempVideos.image_link];
            url1 = [NSURL URLWithString:tempVideos.image_link];
            cell.playVideo.hidden = YES;
        }
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
        
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        for (UIView* subview in cell.profileImage.subviews)
            subview.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        
        cell.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.profileImage.layer.shadowOpacity = 0.7f;
        cell.profileImage.layer.shadowOffset = CGSizeMake(0, 5);
        cell.profileImage.layer.shadowRadius = 5.0f;
        cell.profileImage.layer.masksToBounds = NO;
        
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
        cell.profileImage.layer.masksToBounds = NO;
        cell.profileImage.clipsToBounds = YES;
        
        cell.profileImage.layer.backgroundColor = [UIColor clearColor].CGColor;
        cell.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.profileImage.layer.borderWidth = 0.0f;
        //
        cell.profileImagePost.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
        for (UIView* subview in cell.profileImagePost.subviews)
            subview.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
        
        cell.profileImagePost.layer.shadowColor = [UIColor blackColor].CGColor;
        cell.profileImagePost.layer.shadowOpacity = 0.7f;
        cell.profileImagePost.layer.shadowOffset = CGSizeMake(0, 5);
        cell.profileImagePost.layer.shadowRadius = 5.0f;
        cell.profileImagePost.layer.masksToBounds = NO;
        
        cell.profileImagePost.layer.cornerRadius = cell.profileImagePost.frame.size.width / 2;
        cell.profileImagePost.layer.masksToBounds = NO;
        cell.profileImagePost.clipsToBounds = YES;
        
        cell.profileImagePost.layer.backgroundColor = [UIColor clearColor].CGColor;
        cell.profileImagePost.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.profileImagePost.layer.borderWidth = 0.0f;
        
        [cell.playVideo addTarget:self action:@selector(playVideoComments:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playVideo setTag:indexPath.row];
        
        appDelegate.videotoPlay = [CommentsModelObj.mainArray objectAtIndex:indexPath.row];
        
        [cell.heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([tempVideos.liked_by_me isEqualToString:@"1"]) {
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        }else{
            [cell.heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        }
        
        [cell.heart setTag:indexPath.row];
        cell.heartCountlbl.tag = indexPath.row;
        
        [cell.commentsBtn addTarget:self action:@selector(ReplyCommentpressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentsBtn setTag:indexPath.row];
        
        cell.seenLbl.tag = indexPath.row;
        
        if(IS_IPHONE_6){
            cell.contentView.frame = CGRectMake(0, 0, 345, 220);
        }
        
        return cell;
    }
    
    
    return nil;
}

-(void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
        index = [self.TableHome indexPathForCell:cell];
        
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.tag == 5){
        movingInBwScrols = YES;
        int page = scrollView.contentOffset.x / scrollView.frame.size.width;
        if(page == 0){
            [self ShowBottomBar];
            [btnHome setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 0;
            tabLineHome.hidden      = false;
            tabLineChannel.hidden   = true;
            tabLineTrending.hidden  = true;
            movingInBwScrols = NO;
        }
        else if (page == 1) {
            [self ShowBottomBar];
            [btnChannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnTrending setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            currentState = 3;
            tabLineHome.hidden      = true;
            tabLineChannel.hidden   = false;
            tabLineTrending.hidden  = true;
            movingInBwScrols = NO;
        }
        else {
            currentState = 2;
            [btnTrending setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnChannel setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [btnHome setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            tabLineHome.hidden      = true;
            tabLineChannel.hidden   = true;
            tabLineTrending.hidden  = false;
            movingInBwScrols = NO;
        }
    }

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if(scrollView.tag == 10 || scrollView.tag == 3 || scrollView.tag == 2){
    CGPoint targetPoint = *targetContentOffset;
    CGPoint currentPoint = scrollView.contentOffset;
    if (targetPoint.y > currentPoint.y) {
        isDownwards = false;
    }
    else {
        isDownwards = true;

        return;
    }
        movingInBwScrols = TRUE;
    }
    isDownwards = false;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(isDownwards) {
        if (scrollView.tag == 10){
            NSArray *visibleRows = [_TableHome visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_TableHome indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == newsfeedsVideos.count/2 - 1)
            {
                if(!cannotScroll && !fetchingContent) {
                        pageNum++;
                        [self getHomeContent];
                    
                }
                
            }
        }
        else if(scrollView.tag == 3)
        {
            NSArray *visibleRows = [_forumTable visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [_forumTable indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == forumsVideo.count/2 - 1)
            {
                if(!cannotScrollForum && !fetchingFroum) {
                        forumPageNumber++;
                        [self getTrendingVideos];
                    
                }
                
            }
        }
        else if(scrollView.tag == 2){
            NSArray *visibleRows = [self.TablemyChannel visibleCells];
            UITableViewCell *lastVisibleCell = [visibleRows lastObject];
            NSIndexPath *path = [self.TablemyChannel indexPathForCell:lastVisibleCell];
            if(path.section == 0 && path.row == channelVideos.count/2 - 1)
            {
                if(!cannotScrollMyCorner && !fetchingCorner) {
                        myCornerPageNum++;
                        [self getMyChannel];
                }
                
            }
        }
 }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
//    if(scrollView.tag ==10) {
//        if (!decelerate) {
//            [self stoppedScrolling];
//        }
//    }
//    
}
- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if (frame.origin.y < 20) {
        [self animateNavBarTo:-(frame.size.height - 21)];
        
    }
    //[self getHomeContent];
}

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem* item, NSUInteger i, BOOL *stop) {
        item.customView.alpha = alpha;
    }];
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = self.navigationController.navigationBar.frame;
        if(IS_IPHONE_6) {
            frame.size.width = 375;
            frame.origin.y = 0;
        }
        if(IS_IPAD) {
            frame.size.width = 768;
            frame.origin.y = 0;
        }
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateBarButtonItems:alpha];
        
    }];
    
}
-(void)HideBottomBar{
    [UIView animateWithDuration:0.5
                     animations:^{
                         _BottomBar.frame =CGRectMake(TabBarFrame.origin.x, TabBarFrame.origin.y + 100, TabBarFrame.size.width, TabBarFrame.size.height) ;
                     }];
//    [UIView animateWithDuration:0.5 animations:^{
//        _BottomBar.frame =  CGRectMake(0, 700, 375, 100);
//        
//    }];
}
-(void)ShowBottomBar{
    [UIView animateWithDuration:0.5
                     animations:^{
                        _BottomBar.frame = TabBarFrame;
                     }];
//    [UIView animateWithDuration:0.5 animations:^{
//        _BottomBar.frame = TabBarFrame;
//    }];
}
#pragma mark - TableView Delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //  GetTrendingVideos *model = [forumsVideo objectAtIndex:indexPath.row];
    
}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return YES if you want the specified item to be editable.
//    return YES;
//}
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //add code here for when you hit delete
//    }
//}
-(void)playVideoComments:(UIButton*)sender{
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    CommentsModel *tempVideos = [CommentsArray objectAtIndex:currentSelectedIndex];
    appDelegate.videotoPlay = tempVideos.video_link;
    appDelegate.videoUploader = tempVideos.userName;
    appDelegate.videotitle = tempVideos.title;
    //appDelegate.videotags = tempVideos.Tags;
    appDelegate.profile_pic_url = tempVideos.profile_link;
    //appDelegate.currentScreen = screen;
    postID = tempVideos.VideoID;
    
    [self SeenPost];
    [[NavigationHandler getInstance]MoveToPlayer];
}
-(void)menuBtnPressed:(UIButton*)sender{
  //  NSInteger selectedIndex;
    currentSelectedIndex = sender.tag ;
   
   // selectedVideo  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
    if(currentState == 0){
        editTTView.hidden = true;
        viewItems.hidden = false;
        selectedVideo  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        postID = selectedVideo.videoID;
    }
    else if(currentState == 2)
    {
        editTTView.hidden = true;
        viewItems.hidden = false;
        selectedVideo =  [forumsVideo objectAtIndex:currentSelectedIndex];
        postID = selectedVideo.videoID;
    }
    else if(currentState == 3)
    {
        viewItems.hidden = true;
        editTTView.hidden = false;
        selectedVideo = [channelVideos objectAtIndex:currentSelectedIndex];
        postID = selectedVideo.videoID;
    }

    
    
    //User *user=userArray[index];
   // viewItems.hidden = false;
    CGAffineTransform gameModViewTransform = viewItems.transform;
    viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/2.0 animations:^{
        viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                viewItems.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    viewItems.transform = gameModViewTransform;


}
-(void)playVideo:(UIButton*)sender{
    
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    
    if(currentState == 3) {
        [videoObj removeAllObjects];
      //   myChannelModel *modelss = [channelVideos objectAtIndex:currentSelectedIndex];
      //   postID = modelss.Post_ID;
      //  for(int i = 0; i < channelVideos.count ; i++){
            VideoModel *tempModel = [channelVideos objectAtIndex:currentSelectedIndex];
//            VideoModel *temp = [[VideoModel alloc] init];
//            temp.is_anonymous           = models.is_anonymous;
//            temp.title                  = models.title;
//            temp.comments_count         = models.comments_count;
//            temp.userName               = models.userName;
//            temp.topic_id               = models.topic_id;
//            temp.user_id                = models.user_id;
//            temp.profile_image          = models.profile_image;
//            temp.video_link             = models.video_link;
//            temp.video_thumbnail_link   = models.video_thumbnail_link;
//            temp.image_link             = models.image_link;
//            temp.videoID                = models.VideoID;
//            temp.video_length           = models.video_length;
//            temp.like_count             = models.like_count;
//            temp.like_by_me             = models.like_by_me;
//            temp.seen_count             = models.seen_count;
//            temp.reply_count            = models.reply_count;
            [videoObj addObject:tempModel];
      //  }
        VideoPlayerVC *videoPlayer;
        if(IS_IPAD)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
        else if(IS_IPHONE_6Plus)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        else
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        videoPlayer.videoObjs       = videoObj;
        videoPlayer.indexToDisplay  = currentSelectedIndex;
        videoPlayer.isComment       = FALSE;
        videoPlayer.isFirst         = TRUE;
        videoPlayer.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.6
                         animations:^{
                             [self.view addSubview:videoPlayer.view];
                             videoPlayer.view.transform=CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){
                             [videoPlayer.view removeFromSuperview];
                             [self.navigationController pushViewController:videoPlayer animated:NO];
                         }];

        [self SeenPost];
    }
    else if (currentState == 2) {
        [videoObj removeAllObjects];
        // GetTrendingVideos *modelss = [forumsVideo objectAtIndex:currentSelectedIndex];
       // postID = modelss.Post_ID;
       // for(int i = 0; i < forumsVideo.count ; i++){
        VideoModel *tempModel = [forumsVideo objectAtIndex:currentSelectedIndex];
//            VideoModel *temp = [[VideoModel alloc] init];
//            temp.is_anonymous           = model.is_anonymous;
//            temp.title                  = model.title;
//            temp.comments_count         = model.comments_count;
//            temp.userName               = model.userName;
//            temp.topic_id               = model.topic_id;
//            temp.user_id                = model.user_id;
//            temp.profile_image          = model.profile_image;
//            temp.video_link             = model.video_link;
//            temp.video_thumbnail_link   = model.video_thumbnail_link;
//            temp.image_link             = model.image_link;
//            temp.videoID                = model.VideoID;
//            temp.video_length           = model.video_length;
//            temp.like_count             = model.like_count;
//            temp.like_by_me             = model.like_by_me;
//            temp.seen_count             = model.seen_count;
//            temp.reply_count            = model.reply_count;
            [videoObj addObject:tempModel];
     //   }
        VideoPlayerVC *videoPlayer;
        if(IS_IPAD)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
        else if(IS_IPHONE_6Plus)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        else
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        videoPlayer.videoObjs = videoObj;
        videoPlayer.indexToDisplay = currentSelectedIndex;
        videoPlayer.isComment       = FALSE;
        videoPlayer.isFirst         = TRUE;
        videoPlayer.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.6
                         animations:^{
                             [self.view addSubview:videoPlayer.view];
                             videoPlayer.view.transform=CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){
                             [videoPlayer.view removeFromSuperview];
                             [self.navigationController pushViewController:videoPlayer animated:NO];
                         }];
        
        [self SeenPost];
    }
    else if(currentState == 0){
        [videoObj removeAllObjects];
        //GetTrendingVideos *modelss = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        //postID = modelss.Post_ID;
       // for(int i = 0; i < newsfeedsVideos.count ; i++){
          VideoModel *tempModel = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
//            VideoModel *temp = [[VideoModel alloc] init];
//            temp.is_anonymous           = model.is_anonymous;
//            temp.title                  = model.title;
//            temp.comments_count         = model.comments_count;
//            temp.userName               = model.userName;
//            temp.topic_id               = model.topic_id;
//            temp.user_id                = model.user_id;
//            temp.profile_image          = model.profile_image;
//            temp.video_link             = model.video_link;
//            temp.video_thumbnail_link   = model.video_thumbnail_link;
//            temp.image_link             = model.image_link;
//            temp.videoID                = model.VideoID;
//            temp.video_length           = model.video_length;
//            temp.like_count             = model.like_count;
//            temp.like_by_me             = model.like_by_me;
//            temp.seen_count             = model.seen_count;
//            temp.reply_count            = model.reply_count;
        [videoObj addObject:tempModel];
       // }
        
        VideoPlayerVC *videoPlayer;
        if(IS_IPAD)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
        else if(IS_IPHONE_6Plus)
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        else
            videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
        videoPlayer.videoObjs = videoObj;
        videoPlayer.indexToDisplay = currentSelectedIndex;
        videoPlayer.isComment       = FALSE;
        videoPlayer.isFirst         = TRUE;
        videoPlayer.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.6
                         animations:^{
                             [self.view addSubview:videoPlayer.view];
                             videoPlayer.view.transform=CGAffineTransformMakeScale(1, 1);
                         }
                         completion:^(BOOL finished){
                             [videoPlayer.view removeFromSuperview];
                             [self.navigationController pushViewController:videoPlayer animated:NO];
                         }];
        
        [self SeenPost];
    }
    
}
-(void)MovetoUserProfile:(UIButton*)sender{
//    appDelegate.loaduserProfiel = TRUE;
//    UIButton *Senderid = (UIButton *)sender;
//    currentSelectedIndex = Senderid.tag;
//    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
//    tempVideos =  [newsfeedsVideos  objectAtIndex:currentSelectedIndex];
//    appDelegate.userToView = tempVideos.user_id;
//    [[NavigationHandler getInstance]MoveToProfile];
    /////////////////////////////////////////////////////////////
    
        UIButton *statusBtn = (UIButton *)sender;
        currentSelectedIndex = statusBtn.tag;
    if (currentState==0) {
        
    
        VideoModel *tempVideos = [[VideoModel alloc]init];
        tempVideos  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
    
        friendId = tempVideos.user_id;
       // UserRelation = tempVideos.status;
       // if ([UserRelation isEqualToString:@"ADD_FRIEND"]) {
    
            [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
//        }else if ([UserRelation isEqualToString:@"PENDING"]){
//    
//            [friendsStatusbtn setTitle:@"Pending" forState:UIControlStateNormal];
//        }else if ([UserRelation isEqualToString:@"FRIEND"]) {
//    
//            [friendsStatusbtn setTitle:@"Friend" forState:UIControlStateNormal];
//        }else if ([UserRelation isEqualToString:@"ACCEPT_REQUEST"]){
//    
//            [friendsStatusbtn setTitle:@"Accept Request" forState:UIControlStateNormal];
//        }
        
        [self GetUsersChannel];
    }
    else if (currentState==2){
    
        VideoModel *tempVideos = [[VideoModel alloc]init];
        tempVideos  = [forumsVideo objectAtIndex:currentSelectedIndex];
        
        friendId = tempVideos.user_id;
        // UserRelation = tempVideos.status;
        
            [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
      
        [self GetUsersChannel];
    }
    else{
    
    
    }
    
}
- (void)LikeHearts:(UIButton*)sender{
    //liked = nil;
    UIButton *LikeBtn = (UIButton *)sender;
    currentSelectedIndex = LikeBtn.tag;
    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
    myChannelModel *_profile = [[myChannelModel alloc]init];
    if(currentState == 0){
        tempVideos  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 2)
    {
        tempVideos =  [forumsVideo objectAtIndex:currentSelectedIndex];
        postID = tempVideos.VideoID;
    }
    else if(currentState == 3)
    {
        _profile = [channelVideos objectAtIndex:currentSelectedIndex];
        postID = _profile.VideoID;
    }
    
    [self LikePost:currentSelectedIndex];
    
    if (liked == YES) {
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else if (liked == NO){
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
}
#pragma mark UPDATE Rating api

-(void) updateRatingApi:(VideoModel *) vobj{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *rating = [NSString stringWithFormat:@"%f",vobj.rating];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_UPDATE_RATING,@"method",
                              token,@"Session_token",rating,@"rating",vobj.videoID,@"post_id", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];

    
    
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSString *message = [result objectForKey:@"message"];
            if(success == 1){
                newRating =[ [result objectForKey:@"total_rating"] floatValue];

                [self reloadTablView];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                //[alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    

}

#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    UIButton *senderBtn = sender;
    senderBtn.enabled = false;
    CommentsArray = nil;
    commentsTable.hidden = NO;
    Cm_VideoPlay.hidden = NO;
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
   
    
    [Cm_VideoPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [Cm_VideoPlay setTag:currentSelectedIndex];
    if(currentState == 2){
        VideoModel *_model = [forumsVideo objectAtIndex:currentSelectedIndex];
        videomodel  = _model;
        postID = videomodel.videoID;
        appDelegate.currentMyCornerIndex = currentSelectedIndex;
    }else if(currentState == 0){
        VideoModel *_model = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
        videomodel  = _model;
        postID = videomodel.videoID;
    }
    else if(currentState == 3){
        VideoModel *_model = [channelVideos objectAtIndex:currentSelectedIndex];
        videomodel  = _model;
        postID = videomodel.videoID;
        appDelegate.currentMyCornerIndex = currentSelectedIndex;
    }
    ParentCommentID = @"-1";
    CommentsVC *commentController ;
    if(IS_IPAD)
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    else
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    commentController.myprofile = myProfile;
    commentController.commentsObj   = Nil;
    commentController.postArray     = videomodel;
    commentController.cPostId       = postID;
    commentController.isFirstComment = TRUE;
    commentController.isComment     = FALSE;
    
    [[self navigationController] pushViewController:commentController animated:YES];
    //[self GetCommnetsOnPost];
    //[self.view addSubview:commentsView];
 //   .....................


}

-(void) ReplyCommentpressed:(UIButton *)sender{
    
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [CommentsArray objectAtIndex:currentSelectedIndex];
    NSString *Comments = tempVideos.comments_count;
    commentsCountCommnetview.text = Comments;
    usernameCommnet.text = tempVideos.userName;
    videoTitleComments.text = tempVideos.title;
    videoLengthComments.text = tempVideos.video_length;
    likeCountsComment.text = tempVideos.like_count;
    
    //postID = tempVideos.VideoID;
    
    userImage.imageURL = [NSURL URLWithString:tempVideos.profile_link];
    NSURL *url = [NSURL URLWithString:tempVideos.profile_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    
    coverimgComments.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    if([tempVideos.video_thumbnail_link isEqualToString:@""] )
    {
        coverimgComments.imageURL = [NSURL URLWithString:tempVideos.image_link];
        url1 = [NSURL URLWithString:tempVideos.image_link];
        
    }
    Cm_VideoPlay.hidden = YES;
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    
    ParentCommentID = tempVideos.VideoID;
    [self GetCommnetsOnPost];
    [self.view addSubview:commentsView];
}
-(void)getCommentsToPlay{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",postID,@"post_id", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"comments"];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if(success == 1) {
                
                //////Comments Videos Response //////
                CommentsArray = [result objectForKey:@"comments"];
               
                
                for(NSDictionary *tempDict in CommentsArray){
                    VideoModel *_comment = [[VideoModel alloc] init];
                    _comment.title = [tempDict objectForKey:@"caption"];
                    _comment.comments_count = [tempDict objectForKey:@"comment_count"];
                    _comment.userName = [tempDict objectForKey:@"full_name"];
                    _comment.topic_id = [tempDict objectForKey:@"topic_id"];
                    _comment.user_id = [tempDict objectForKey:@"user_id"];
                    _comment.profile_image = [tempDict objectForKey:@"profile_link"];
                    _comment.video_link = [tempDict objectForKey:@"video_link"];
                    _comment.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _comment.image_link = [tempDict objectForKey:@"image_link"];
                    _comment.videoID = [tempDict objectForKey:@"id"];
                    _comment.video_length = [tempDict objectForKey:@"video_length"];
                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    [videoObj addObject:_comment];
                }
                VideoPlayerVC *videoPlayer;
                if(IS_IPAD)
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPad" bundle:nil];
                else if(IS_IPHONE_6Plus)
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC_iPhonePlus" bundle:nil];
                else
                    videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
                videoPlayer.videoObjs = videoObj;
                videoPlayer.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                
                [UIView animateWithDuration:0.6
                                 animations:^{
                                     [self.view addSubview:videoPlayer.view];
                                     videoPlayer.view.transform=CGAffineTransformMakeScale(1, 1);
                                 }
                                 completion:^(BOOL finished){
                                     [videoPlayer.view removeFromSuperview];
                                     [self.navigationController pushViewController:videoPlayer animated:NO];
                                 }];

//                VideoPlayerVC *videoPlayer = [[VideoPlayerVC alloc] initWithNibName:@"VideoPlayerVC" bundle:nil];
//                videoPlayer.videoObjs = videoObj;
//                [[self navigationController] pushViewController:videoPlayer animated:YES];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",postID,@"post_id", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"comments"];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            if(success == 1) {
                
                //////Comments Videos Response //////
                CommentsArray = [result objectForKey:@"comments"];
                CommentsModelObj.CommentsArray = [[NSMutableArray alloc] init];
                CommentsModelObj.mainArray = [[NSMutableArray alloc]init];
                CommentsModelObj.ImagesArray = [[NSMutableArray alloc]init];
                CommentsModelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                
                for(NSDictionary *tempDict in CommentsArray){
                    
                    CommentsModel *_comment = [[CommentsModel alloc] init];
                    
                    _comment.title = [tempDict objectForKey:@"caption"];
                    _comment.comments_count = [tempDict objectForKey:@"comment_count"];
                    _comment.comment_like_count = [tempDict objectForKey:@"comment_like_count"];
                    _comment.seen_count = [tempDict objectForKey:@"seen_count"];
                    _comment.userName = [tempDict objectForKey:@"full_name"];
                    _comment.topic_id = [tempDict objectForKey:@"topic_id"];
                    _comment.user_id = [tempDict objectForKey:@"user_id"];
                    _comment.profile_link = [tempDict objectForKey:@"profile_link"];
                    _comment.liked_by_me = [tempDict objectForKey:@"liked_by_me"];
                    _comment.mute = [tempDict objectForKey:@"mute"];
                    _comment.video_link = [tempDict objectForKey:@"video_link"];
                    _comment.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _comment.image_link = [tempDict objectForKey:@"image_link"];
                    _comment.VideoID = [tempDict objectForKey:@"id"];
                    _comment.video_length = [tempDict objectForKey:@"video_length"];
                    _comment.timestamp = [tempDict objectForKey:@"timestamp"];
                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _comment.reply_count  = [tempDict objectForKey:@"reply_count"];
                    
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                    
                    CommentsArray = CommentsModelObj.CommentsArray;
                    chVideosArray = CommentsModelObj.mainArray;
                    chArrImage = CommentsModelObj.ImagesArray;
                    chArrThumbnail = CommentsModelObj.ThumbnailsArray;
                    
                }
                CommentsVC *commentController ;
                if(IS_IPAD)
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
                else
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                
                commentController.commentsObj   = CommentsModelObj;
                commentController.postArray     = videomodel;
                commentController.cPostId       = postID;
                commentController.isFirstComment = TRUE;
                commentController.isComment     = FALSE;
                [[self navigationController] pushViewController:commentController animated:YES];
            }
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (IBAction)CommentsBack:(id)sender {
    
    //CommentsArray = nil;
    [commentsView removeFromSuperview];
}



- (void)Flag:(UIButton*)sender{
    
    UIButton *seenBtn = (UIButton *)sender;
    currentSelectedIndex = seenBtn.tag;
    
    GetTrendingVideos *tempVideos = [[GetTrendingVideos alloc]init];
    tempVideos  = [getTrendingVideos.trendingArray objectAtIndex:currentSelectedIndex];
    
    postID = tempVideos.VideoID;
    [self SeenPost];
    
    if (seenPost == YES) {
    }else if (seenPost == NO){
    }
    
}

- (void)editPost:(UIButton*)sender{
    
    _optionsView.hidden = NO;
    [self.view addSubview:self.optionsView];
    
}


- (CGRect)offScreenFrame
{
    return CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark Open Friend's Channel Methods
//
//-(void)OpenUserChannel:(UIButton *)sender{
//    UIButton *statusBtn = (UIButton *)sender;
//    currentSelectedIndex = statusBtn.tag;
//    VideoModel *tempVideos = [[VideoModel alloc]init];
//    tempVideos  = [newsfeedsVideos objectAtIndex:currentSelectedIndex];
//
//    friendId = tempVideos.user_id;
//   // UserRelation = tempVideos.status;
//    if ([UserRelation isEqualToString:@"ADD_FRIEND"]) {
//        
//        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
//    }else if ([UserRelation isEqualToString:@"PENDING"]){
//        
//        [friendsStatusbtn setTitle:@"Pending" forState:UIControlStateNormal];
//    }else if ([UserRelation isEqualToString:@"FRIEND"]) {
//        
//        [friendsStatusbtn setTitle:@"Friend" forState:UIControlStateNormal];
//    }else if ([UserRelation isEqualToString:@"ACCEPT_REQUEST"]){
//        
//        [friendsStatusbtn setTitle:@"Accept Request" forState:UIControlStateNormal];
//    }
//    
//    [self GetUsersChannel];
//
//
//}

-(void) OpenFriendsChannelPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    UserRelation = _responseData.status;
    if ([UserRelation isEqualToString:@"ADD_FRIEND"]) {
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"PENDING"]){
        
        [friendsStatusbtn setTitle:@"Pending" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"FRIEND"]) {
        
        [friendsStatusbtn setTitle:@"Friend" forState:UIControlStateNormal];
    }else if ([UserRelation isEqualToString:@"ACCEPT_REQUEST"]){
        
        [friendsStatusbtn setTitle:@"Accept Request" forState:UIControlStateNormal];
    }
    
    [self GetUsersChannel];
    
    
}
-(IBAction)openBBC:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bbc.com"]];
}
-(IBAction)openEmirates:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.emirates.com"]];
}
-(IBAction)openREDBull:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.redbull.com/en"]];
}
-(IBAction)MoveToSearchView:(id)sender{
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [searchField2 becomeFirstResponder];
    [self.view addSubview:searchView];
}
- (IBAction)showFollowings:(id)sender {
    loadFollowings = true;
    searchcorners = false;
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self getFollowing];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
    
}

- (IBAction)showFollowers:(id)sender {
    loadFollowings = false;
    searchcorners = false;
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self getFollowers];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
}
-(void) GetFollowersCall{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"getFollowersFollowing",@"method",
                              token,@"session_token",@"1",@"page_no",userId,@"user_id",@"1",@"following",nil];
    NSData *postData = [Utils encodeDictionary:postDict];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1){
                FollowingsArray = [result objectForKey:@"following"];
                userFriends.text = [[NSString alloc]initWithFormat:@"%lu",(unsigned long)FollowingsArray.count];
            }
        }
    }];
}
- (IBAction)userChannelBackbtn:(id)sender {
    [friendsChannelView removeFromSuperview];
    [SVProgressHUD dismiss];
}

- (IBAction)UserStatusbtnPressed:(id)sender {
    
    if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Add Friend"]) {
        
        [friendsStatusbtn setTitle:@"Request Sent" forState:UIControlStateNormal];
        [self sendFriendRequest];
    }else if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Pending"]){
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self sendCancelRequest];
    }else if ([friendsStatusbtn.titleLabel.text isEqualToString:@"Friend"]) {
        
        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
        [self sendDeleteFriend];
    }
}



-(void) GetUsersChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_USERS_CHANNEL,@"method",
                              token,@"Session_token",@"1",@"page_no",friendId,@"user_id", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"profile"];
            userChannelObj.state = [result objectForKey:@"state"];
            if(success == 1) {
                //////Profile Response //////
                
                UserChannelModel *_profile = [[UserChannelModel alloc] init];
                ///Saving Data
                userChannelObj.beams_count = [users objectForKey:@"beams_count"];
                userChannelObj.friends_count = [users objectForKey:@"following_count"];
                userChannelObj.full_name = [users objectForKey:@"full_name"];
                userChannelObj.cover_link = [users objectForKey:@"cover_link"];
                userChannelObj.user_id = [users objectForKey:@"id"];
                userChannelObj.profile_image = [users objectForKey:@"profile_link"];
                userChannelObj.likes_count = [users objectForKey:@"followers_count"];
                userChannelObj.gender = [users objectForKey:@"gender"];
                userChannelObj.email = [users objectForKey:@"email"];
                userChannelObj.is_celeb = [users objectForKey:@"is_celeb"];
                
                chPostArray = [result objectForKey:@"posts"];
                userChannelObj.trendingArray = [[NSMutableArray alloc] init];
                userChannelObj.mainArray = [[NSMutableArray alloc]init];
                userChannelObj.ImagesArray = [[NSMutableArray alloc]init];
                userChannelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
                
                for(NSDictionary *tempDict in chPostArray){
                    
                    UserChannelModel *_Videos = [[UserChannelModel alloc] init];
                    
                    _Videos.title = [tempDict objectForKey:@"caption"];
                    _Videos.comments_count = [tempDict objectForKey:@"comment_count"];
                    _Videos.userName = [tempDict objectForKey:@"full_name"];
                    _Videos.topic_id = [tempDict objectForKey:@"topic_id"];
                    _Videos.user_id = [tempDict objectForKey:@"user_id"];
                    _Videos.profile_image = [tempDict objectForKey:@"profile_link"];
                    _Videos.like_count = [tempDict objectForKey:@"like_count"];
                    _Videos.seen_count = [tempDict objectForKey:@"seen_count"];
                    _Videos.video_angle = [[tempDict objectForKey:@"video_angle"] intValue];
                    _Videos.video_link = [tempDict objectForKey:@"video_link"];
                    _Videos.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
                    _Videos.VideoID = [tempDict objectForKey:@"id"];
                    _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                    _Videos.video_length = [tempDict objectForKey:@"video_length"];
                    _Videos.like_by_me = [tempDict objectForKey:@"like_by_me"];
                    _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _Videos.reply_count  = [tempDict objectForKey:@"reply_count"];
                    _Videos.rating = [[tempDict objectForKey:@"rating"] floatValue];
                    [userChannelObj.ImagesArray addObject:_Videos.profile_image];
                    [userChannelObj.ThumbnailsArray addObject:_Videos.video_thumbnail_link];
                    [userChannelObj.mainArray addObject:_Videos.video_link];
                    [userChannelObj.trendingArray addObject:_Videos];
                    
                    chPostArray = userChannelObj.trendingArray;
                    chVideosArray = userChannelObj.mainArray;
                    chArrImage = userChannelObj.ImagesArray;
                    chArrThumbnail = userChannelObj.ThumbnailsArray;
                }
                UserChannel *commentController = [[UserChannel alloc] initWithNibName:@"UserChannel" bundle:nil];
                commentController.ChannelObj = userChannelObj;
                [[self navigationController] pushViewController:commentController animated:YES];
                
                //[friendsChannelTable reloadData];
                //[self.view addSubview:friendsChannelView];
                if(IS_IPHONE_6){
                    friendsChannelView.frame = CGRectMake(0, 0, 375, 667);
                }
                else if(IS_IPHONE_6Plus)
                {
                    friendsChannelView.frame = CGRectMake(0, 0, 414, 736);
                }
            }
        }
        else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}


#pragma mark Search Methods

- (IBAction)hideShowsearchbar:(id)sender {
    
    [searchField resignFirstResponder];
    [searchField2 resignFirstResponder];
    loadFollowings = false;
    [FollowingsAM removeAllObjects];
    searchcorners = true;
    [_searchTable reloadData];
    [self SearchCorners];
    nousersFound.hidden = YES;
    [self.view addSubview:searchView];
    SearchforTag = NO;
}

- (IBAction)searchBack:(id)sender {
    [searchView removeFromSuperview];
    loadFollowings = false;
    [tagFriendsView removeFromSuperview];
    [self GetFollowersCall];
//    [[NSNotificationCenter defaultCenter]
//     postNotificationName:@"TestNotification"
//     object:self];
    [SVProgressHUD dismiss];
}

-(void) SearchCorners{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    searchKeyword = searchField.text;
    if ([searchKeyword isEqualToString:@""]) {
        searchKeyword = searchField2.text;
    }
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"Session_token",@"1",@"page_no",searchKeyword,@"keyword", nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
               
                searchField.text = nil;
                searchField2.text = nil;
//
//                usersArray = [result objectForKey:@"users_found"];
//                UsersModel.PopUsersArray = [[NSMutableArray alloc] init];
//                UsersModel.imagesArray = [[NSMutableArray alloc] init];
//                
//                for(NSDictionary *tempDict in usersArray){
//                    
//                    PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
//                    _Popusers.full_name = [tempDict objectForKey:@"full_name"];
//                    _Popusers.friendID = [tempDict objectForKey:@"id"];
//                    _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
//                    _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
//                    _Popusers.status = [tempDict objectForKey:@"state"];
//                    
//                    [UsersModel.imagesArray addObject:_Popusers.profile_link];
//                    [UsersModel.PopUsersArray addObject:_Popusers];
//                    usersArray = UsersModel.PopUsersArray;
//                    arrImages = UsersModel.imagesArray;
//                }
                FollowingsArray = [result objectForKey:@"users_found"];
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                [_searchTable reloadData];

            }
            else if(success == 0)
            {
                searchField.text = nil;
                searchField2.text = nil;
                [searchField2 becomeFirstResponder];
                nousersFound.hidden = NO;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alert show];

            }
        }
        else{
            searchField.text = nil;
            searchField2.text = nil;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}
- (void)statusPressed:(UIButton *)sender{
    
    UIButton *statusBtn = (UIButton *)sender;
    currentSelectedIndex = statusBtn.tag;
    
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
    friendId = _responseData.f_id;
    
    [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
    
    if ([_responseData.status isEqualToString:@"ADD_FRIEND"]) {
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        [self sendFriendRequest];
        
    }else if ([_responseData.status isEqualToString:@"PENDING"] || [_responseData.status isEqualToString:@"FRIEND"]){
        _responseData.status = @"PENDING";
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        [statusBtn setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        [self sendDeleteFriend];
    }
}

- (void) getUsers{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEARCH_FRIEND,@"method",
                              token,@"session_token",@"1",@"page_no",searchKeyword,@"keyword",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users_found"];
            
            if(success == 1) {
                
                usersArray = [result objectForKey:@"users_found"];
                UsersModel.PopUsersArray = [[NSMutableArray alloc] init];
                UsersModel.imagesArray = [[NSMutableArray alloc] init];
                
                for(NSDictionary *tempDict in usersArray){
                    
                    PopularUsersModel *_Popusers = [[PopularUsersModel alloc] init];
                    _Popusers.full_name = [tempDict objectForKey:@"full_name"];
                    _Popusers.friendID = [tempDict objectForKey:@"id"];
                    _Popusers.profile_link = [tempDict objectForKey:@"profile_link"];
                    _Popusers.profile_type = [tempDict objectForKey:@"profile_type"];
                    _Popusers.status = [tempDict objectForKey:@"state"];
                    
                    
                    [UsersModel.imagesArray addObject:_Popusers.profile_link];
                    [UsersModel.PopUsersArray addObject:_Popusers];
                    usersArray = UsersModel.PopUsersArray;
                    arrImages = UsersModel.imagesArray;
                }
                [_searchTable reloadData];
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void) sendDeleteFriend{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_FRIEND,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                if(loadFollowings){
                    // [self getFollowing];
                    _responseData.status = @"ADD_FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
                else{
                    //[self getFollowers];
                    _responseData.status = @"ADD_FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}


- (void) sendCancelRequest{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_REQUEST,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [SVProgressHUD dismiss];
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                
                [self getUsers];
                [_searchTable reloadData];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

- (void) sendFriendRequest{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    Followings *_responseData = [[Followings alloc] init];
    _responseData  = [FollowingsAM objectAtIndex:currentSelectedIndex];
//     [FollowingsAM removeAllObjects];
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_SEND_REQUEST,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        [SVProgressHUD dismiss];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            NSDictionary *users = [result objectForKey:@"users"];
            
            if(success == 1) {
                if(loadFollowings){
                       // [self getFollowing];
                    _responseData.status = @"FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    
                }
                else{
                        //[self getFollowers];
                    _responseData.status = @"FRIEND";
                    
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    [_searchTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                }
            }
        }else{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
#pragma mark - Top Bar Contorls

- (IBAction)ShowDrawer:(id)sender {
    
    //    CGSize size = self.view.frame.size;
    //
    //    if(self.isMenuVisible) {
    //        self.isMenuVisible = false;
    //        [overlayView removeFromSuperview];
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(0, 0, size.width, size.height);
    //        }];
    //    }
    //    else {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            self.view.frame = CGRectMake(236, 0, size.width, size.height);
    //        }];
    //        self.isMenuVisible = true;
    //        CGRect screenRect = [[UIScreen mainScreen] bounds];
    //        overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, screenRect.size.width, screenRect.size.height)];
    //        overlayView.backgroundColor = [UIColor clearColor];
    //
    //        [self.view addSubview:overlayView];
    //
    //        UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    //        [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    //        [overlayView addGestureRecognizer:sgr];
    //    }
    
    [[DrawerVC getInstance] AddInView:self.view];
    [[DrawerVC getInstance] ShowInView];
    
}

- (IBAction)showProfile:(id)sender {
    
    [[NavigationHandler getInstance]MoveToProfile];
}


- (IBAction)ChannelPressed:(id)sender {
    currentState = 3;
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 1;
    frame.origin.y = 0;
    [_mainScroller scrollRectToVisible:frame animated:YES];
    
}

- (IBAction)TrendingPressed:(id)sender {
    currentState = 2;
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 2;
    frame.origin.y = 0;
    [_mainScroller scrollRectToVisible:frame animated:YES];
    
}

- (IBAction)HomePressed:(id)sender {
    CGRect frame = _mainScroller.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    currentState = 0;
    
    [_mainScroller scrollRectToVisible:frame animated:YES];
}

- (IBAction)backBtn:(id)sender {
    _optionsView.hidden = YES;
    [_optionsView removeFromSuperview];
}

//- (IBAction)editBtn:(id)sender {
//}
//
//- (IBAction)deleteBtn:(id)sender {
//    
//}

- (IBAction)findFriends:(id)sender {
     nousersFound.hidden = YES;
    [searchField2 becomeFirstResponder];
    [FollowingsAM removeAllObjects];
    [_searchTable reloadData];
    [self.view addSubview:searchView];
}
#pragma mark - EditCover
- (IBAction)EditCoverImg:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryCover forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    fromImagePicker = TRUE;
    coverimagetocache =  channelCover.image;
    [SVProgressHUD dismiss];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    //[self setUserCoverImage];
    
    //[self.view addSubview:uploadimageView];
    
}

- (IBAction)PhotoOnComments:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryCommentPhoto forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:uploadimageView];
    
}

- (IBAction)VideoOnCommentsPressed:(id)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:VideoOnCommentsGallery forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:BeamTypeView];
}

- (IBAction)PrivacyEveryOne:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    everyOnelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PUBLIC";
    
}

- (IBAction)PrivacyOnlyMe:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    onlyMelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    Friendslbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"PRIVATE";
}

- (IBAction)PrivacyFriends:(id)sender {
    [_CPEveryone setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPOnlyMe setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_CPFriends setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    Friendslbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    privacySelected = @"FRIENDS";
}

- (IBAction)upto60Pressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    
    upto60.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    
    commentAllowed = @"60";
    
}

- (IBAction)noRepliesPressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    noreplies.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"0";
}

- (IBAction)UnlimitedPressed:(id)sender {
    [_upto60Comments setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_NoRepliesbtn setBackgroundImage:[UIImage imageNamed:@"greyradio.png"] forState:UIControlStateNormal];
    [_unlimitedRepliesbtn setBackgroundImage:[UIImage imageNamed:@"blueradio.png"] forState:UIControlStateNormal];
    Unlimited.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    noreplies.textColor = [UIColor colorWithRed:145.0/256.0 green:151.0/256.0 blue:163.0/256.0 alpha:1.0];
    commentAllowed = @"-1";
}
- (void) setUserCoverImage{
    NSURL *url1 = [NSURL URLWithString:ProfileObj.cover_image];
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    UIImage *img1 = [[UIImage alloc] initWithData:data1];
    channelCover.image = img1;
    
}
- (IBAction)uploadProfilePic:(id)sender{
    [[NSUserDefaults standardUserDefaults] setInteger:ProfilePIC forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    fromImagePicker = TRUE;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void) updateCover{
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    NSData *profileDatas = UIImagePNGRepresentation(channelCover.image);
    [requestc setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"cover_link"];
    
    [requestc setPostValue:METHOD_UPDATE_PROFILE forKey:@"method"];
    
    [requestc setRequestMethod:@"POST"];
    [requestc setTimeOutSeconds:300];
    [requestc setDelegate:self];
    [requestc startAsynchronous];
}
-(void) UpdateProfilePic{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    NSData *profileDatas = UIImagePNGRepresentation(User_pic.image);
    [requestc setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"profile_link"];
    
    [requestc setPostValue:METHOD_UPDATE_PROFILE forKey:@"method"];
    
    [requestc setRequestMethod:@"POST"];
    [requestc setTimeOutSeconds:300];
    [requestc setDelegate:self];
    [requestc startAsynchronous];
}
-(void) uploadImageComments{
    //[SVProgressHUD showWithStatus:@"uploading Comment"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Comment" message:@"Uploading Started, you will be notified when the process completes." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    
    requestc = [ASIFormDataRequest requestWithURL:url];
    [requestc addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [requestc setPostValue:token forKey:@"session_token"];
    
    
    [requestc setData:commentImageData withFileName:[NSString stringWithFormat:@"%@.png",@"image"] andContentType:@"image/png" forKey:@"image_link"];
    [requestc setPostValue:postID forKey:@"post_id"];
    [requestc setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [requestc setPostValue:@"-1" forKey:@"reply_count"];
    [requestc setPostValue:@"0" forKey:@"is_anonymous"];
    [requestc setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    
    [requestc setRequestMethod:@"POST"];
    [requestc setTimeOutSeconds:300];
    [requestc setDelegate:self];
    [requestc startAsynchronous];
    //[self imagepickerCross:self];
}
-(void) uploadBeamComments:(NSData*)file{
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.mp4",@"video"] andContentType:@"recording/video" forKey:@"video_link"];
    NSData *profileDatas = UIImagePNGRepresentation(_thumbnailImg1.image);
    [request setData:profileDatas withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"video_thumbnail_link"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    
    
    [request setPostValue:@"90" forKey:@"video_angle"];
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    [request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    
    [request setPostValue:METHOD_COMMENTS_POST forKey:@"method"];
    
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
- (IBAction)PhotoPressed:(id)sender {
    [SVProgressHUD dismiss];
    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryUpload forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.view addSubview:uploadimageView];
}

- (IBAction)fromCamera:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)fromGallery:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


- (IBAction)imagepickerCross:(id)sender {
    [uploadimageView removeFromSuperview];
    
}

- (IBAction)RecorderPressed:(id)sender {
    [self.view addSubview:_uploadAudioView];
    
}

#pragma mark - Beam Pressed

- (IBAction)beamPressed:(id)sender {
    appDelegate.hasbeenEdited = false;

    [[NSUserDefaults standardUserDefaults] setInteger:uploadBeamFromGallery forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([sender tag] == 100){
        uploadAnonymous = true;
        uploadBeamTag = false;
    }
    else if([sender tag ] == 101)
    {
        uploadAnonymous = false;
        uploadBeamTag = true;
    }
    
    //    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryBeam forKey:@"currentImageCategory"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        picker.videoMaximumDuration = 60;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)NormalBeantypePressed:(id)sender {
    [self.view addSubview:selctBeamSourceView];
}

- (IBAction)AnonymoueBeamPressed:(id)sender {
    [self.view addSubview:selctBeamSourceView];
}

- (IBAction)BeamTypeCross:(id)sender {
    
    [BeamTypeView removeFromSuperview];
}

- (IBAction)recordBeamfromCamera:(id)sender {
    
    [BeamTypeView removeFromSuperview];
    //    [[NSUserDefaults standardUserDefaults] setInteger:CurrentImageCategoryBeam forKey:@"currentImageCategory"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        picker.videoMaximumDuration = 60;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (IBAction)uploadfromGallery:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    //imagePicker.videoMaximumDuration = 60; // duration in seconds
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
}
- (IBAction)VideofromGallery:(id)sender
{    uploadAnonymous = false;
    [[NSUserDefaults standardUserDefaults] setInteger:uploadBeamFromGallery forKey:@"currentImageCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
    //imagePicker.videoMaximumDuration = 60; // duration in seconds
    imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:NULL];
    appDelegate.hasbeenEdited = false;

}
- (IBAction)uploadSourceCross:(id)sender {
    [BeamTypeView removeFromSuperview];
    [selctBeamSourceView removeFromSuperview];
}

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mute:(id)sender {
    IS_mute = @"YES";
    if (_muteBtn.tag == 0) {
        [_muteBtn setBackgroundImage:[UIImage imageNamed:@"unmute.png"] forState:UIControlStateNormal];
        IS_mute = @"YES";
        _muteBtn.tag = 1;
    }else if (_muteBtn.tag == 1) {
        [_muteBtn setBackgroundImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
        IS_mute = @"NO";
        _muteBtn.tag = 0;
    }
    
}
#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == CurrentImageCategoryCover)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        channelCover.image = chosenImage;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self updateCover];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == ProfilePIC)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        User_pic.image = chosenImage;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self UpdateProfilePic];
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] ==CurrentImageCategoryCommentPhoto)
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        commentImageData = UIImagePNGRepresentation(chosenImage);
        [picker dismissViewControllerAnimated:YES completion:NULL];
        [self uploadImageComments];
        
    }
    else if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == CurrentImageCategoryBeam  || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery   || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery ){
        // grab our movie URL
        NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:chosenMovie options:nil];
        
        NSTimeInterval durationInSeconds = 0.00;
        if (asset)
            durationInSeconds = CMTimeGetSeconds(asset.duration);
        
        NSUInteger dTotalSeconds = durationInSeconds;
        
        NSUInteger dSeconds =(dTotalSeconds  % 60);
        NSUInteger dMinutes = (dTotalSeconds / 60 ) % 60;
        
        video_duration = [[NSString alloc]initWithFormat:@"%02lu:%02lu",(unsigned long)dMinutes,(unsigned long)dSeconds];
        // save it to the documents directory (option 1)
        //NSURL *fileURL = [self grabFileURL:@"video.mov"];
        
        movieData = [NSData dataWithContentsOfURL:chosenMovie];
        //[movieData writeToURL:fileURL atomically:YES];
        
        // save it to the Camera Roll (option 2)
        //UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
        
        // and dismiss the picker
        [self dismissViewControllerAnimated:YES completion:nil];
        [self PrivacyEveryOne:nil];
        [self UnlimitedPressed:nil];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        imageGenerator.appliesPreferredTrackTransform = YES;
        CMTime time = [asset duration];
        time.value = 0;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        thumbnail = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        _thumbnailImageView.image = thumbnail;
        profileData = UIImagePNGRepresentation(thumbnail);
        [self movetoUploadBeamController];
        
        //[self.view addSubview:_uploadBeamView];
      
        
        // int i = 0;
        //        if(i == 0) {
        //            //AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 0;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_1 = thumbnail;
        //            _thumbnailImg1.image = thumbnail;
        //
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_1 = filteredImage;
        //
        //            i++;
        //        }
        //        if(i == 1) {
        //            AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 1000;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_2 = thumbnail;
        //            _thumbnailImg2.image = thumbnail;
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_2 = filteredImage;
        //
        //            i++;
        //        }
        //        if(i == 2) {
        //            AVAsset *asset = [AVAsset assetWithURL:chosenMovie];
        //            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        //            CMTime time = [asset duration];
        //            time.value = 2000;
        //            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
        //            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
        //            CGImageRelease(imageRef);
        //
        //            thumbnail_Color_3 = thumbnail;
        //            _thumbnailImg3.image = thumbnail;
        //            [self convertImageToGrayScale:thumbnail];
        //            thumbnail_BnW_3 = filteredImage;
        //            i++;
        //        }
        
        
        [[_thumbnail1 layer] setBorderWidth:2.0f];
        [[_thumbnail1 layer] setBorderColor:[UIColor greenColor].CGColor];
        
        emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
        emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        emojiKeyboardView.delegate = self;
        
    }
}
-(void) movetoUploadBeamController{
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.dataToUpload = movieData;
    uploadController.video_duration = video_duration;
    uploadController.ParentCommentID = @"-1";
    uploadController.postID = @"-1";
    uploadController.isAudio = false;
    uploadController.profileData = profileData;
    uploadController.thumbnailImage = thumbnail;
    uploadController.friendsArray   = friendsArray;
    if(uploadAnonymous)
        uploadController.isAnonymous = true;
    else
        uploadController.isAnonymous = false;
    [[self navigationController] pushViewController:uploadController animated:YES];
}
-(void) uploadBeam :(NSData*)file {
    totalBytestoUpload = file.length;
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSString *isAnonymous = @"";
    if(uploadAnonymous)
        isAnonymous = @"1";
    else if(uploadBeamTag)
        isAnonymous = @"0";
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.mp4",@"video"] andContentType:@"recording/video" forKey:@"video_link"];
    [request setData:profileData withFileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] andContentType:@"image/png" forKey:@"video_thumbnail_link"];
    
    [request setPostValue:@"90" forKey:@"video_angle"];
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:IS_mute forKey:@"mute"];
    [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:video_duration forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:isAnonymous forKey:@"is_anonymous"];
    [request setPostValue:METHOD_UPLOAD_STATUS forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
    
}
- (void)setProgress:(float)progress
{
//    if(progress > 1.0)
//        [_progressview setProgress:0.0];
//    else if(_progressview.progress < 0.8)
//        [_progressview setProgress:progress animated:YES];
//    
}
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
   
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:nil];
   
    fromImagePicker = FALSE;
    //[_progressview setProgress:1.0];
    //if(currentState == 0)
        //[self getHomeContent];
    
    AudioServicesPlaySystemSound(1003);
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
    fromImagePicker = FALSE;
    NSString *response = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
    
}


- (IBAction)thumbnail2Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor clearColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg2.image);
}

- (IBAction)thumbnail3Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor greenColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg3.image);
}

- (IBAction)uploadBeamBackPressed:(id)sender {
    [_uploadAudioView removeFromSuperview];
    [_uploadBeamView removeFromSuperview];
}



- (IBAction)emoticonPressed:(id)sender {
    
    UIButton *senderBtn = (UIButton*)sender;
    _statusText.inputView = emojiKeyboardView;
    [_statusText becomeFirstResponder];
    //    if(senderBtn.tag == 1) {
    //        senderBtn.tag = 2;
    //        _statusText.inputView = emojiKeyboardView;
    //        [_statusText becomeFirstResponder];
    //    }
    //    else {
    //        senderBtn.tag = 1;
    //        _statusText.inputView = UIKeyboardTypeDefault;
    //
    //        [_statusText resignFirstResponder];
    //    }
}

- (IBAction)privacyPressed:(id)sender {
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Privacy"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"Public"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Private"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Friends"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    KxMenuItem *selected = (KxMenuItem*)sender;
    if ( [selected.title isEqualToString:@"Private"] ){
        privacySelected = @"PRIVATE";
    }else if ([selected.title isEqualToString:@"Public"]){
        privacySelected = @"PUBLIC";
    }else if ([selected.title isEqualToString:@"Friends"]){
        privacySelected = @"FRIENDS";
        
    }else if ([selected.title isEqualToString:@"General"]){
        TopicSelected = @"1";
    }else if ([selected.title isEqualToString:@"Entertainment"]){
        TopicSelected = @"2";
    }else if ([selected.title isEqualToString:@"Sports"]){
        TopicSelected = @"3";
    }else if ([selected.title isEqualToString:@"Lifestyle"]){
        TopicSelected = @"4";
    }else if ([selected.title isEqualToString:@"Politics"]){
        TopicSelected = @"5";
        
    }else if ([selected.title isEqualToString:@"No Comment"]){
        commentAllowed = @"0";
    }else if ([selected.title isEqualToString:@"50 Comment"]){
        commentAllowed = @"50";
    }else if ([selected.title isEqualToString:@"Unlimited Comments"]){
        commentAllowed = @"-1";
    }
    
    
}

- (IBAction)selectTopicPressed:(id)sender {
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Topic"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"General"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Entertainment"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Sports"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      [KxMenuItem menuItem:@"Lifestyle"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Politics"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
}

- (IBAction)thumbnail1Pressed:(id)sender {
    
    [[_thumbnail1 layer] setBorderWidth:2.0f];
    [[_thumbnail1 layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[_thumbnail2 layer] setBorderWidth:2.0f];
    [[_thumbnail2 layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[_thumbnail3 layer] setBorderWidth:2.0f];
    [[_thumbnail3 layer] setBorderColor:[UIColor clearColor].CGColor];
    profileData = UIImagePNGRepresentation(_thumbnailImg1.image);
}

- (IBAction)uploadBeamPressed:(id)sender {
    
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Beam Upload" message:@"Uploading Started, you will be notified when the process completes." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    //    [alert show];
    [_uploadAudioView removeFromSuperview];
    [self.uploadBeamView removeFromSuperview];
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery)
    {
        [self uploadBeamComments:movieData];
    }
    else if ( [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery){
        [self uploadBeam:movieData];
    }
    else {
        [self uploadAduio:audioData];
    }
    [selctBeamSourceView removeFromSuperview];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    isFirstTimeClicked = false;
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == uploadBeamFromGallery   || [[NSUserDefaults standardUserDefaults] integerForKey:@"currentImageCategory"] == VideoOnCommentsGallery)
    {
        [self.uploadBeamView removeFromSuperview];
    }
}

- (IBAction)rotateThumbnails:(id)sender {
    self.thumbnailImg1.image = [self rotateImage:self.thumbnailImg1.image onDegrees:30];
    self.thumbnailImg2.image = [self rotateImage:self.thumbnailImg2.image onDegrees:30];
    self.thumbnailImg3.image = [self rotateImage:self.thumbnailImg3.image onDegrees:30];
    
    btnBnW.layer.borderWidth =2.0f;
    btnBnW.layer.borderColor =[UIColor clearColor].CGColor;
    
    btnColour.layer.borderWidth =2.0f;
    btnColour.layer.borderColor =[UIColor clearColor].CGColor;
    
    btnRotate.layer.borderWidth =2.0f;
    btnRotate.layer.borderColor = [UIColor greenColor].CGColor;
    
}

- (IBAction)colouredPressed:(id)sender {
    videotype = @"COLOUR";
    
    _thumbnailImg1.image = thumbnail_Color_1;
    _thumbnailImg2.image = thumbnail_Color_2;
    _thumbnailImg3.image = thumbnail_Color_3;
    
    [[btnBnW layer] setBorderWidth:2.0f];
    [[btnBnW layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[btnColour layer] setBorderWidth:2.0f];
    [[btnColour layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[btnRotate layer] setBorderWidth:2.0f];
    [[btnRotate layer] setBorderColor:[UIColor clearColor].CGColor];
    
}

- (IBAction)blacknWhitepressed:(id)sender {
    videotype = @"BLACK_AND_WHITE";
    
    _thumbnailImg1.image = thumbnail_BnW_1;
    _thumbnailImg2.image = thumbnail_BnW_2;
    _thumbnailImg3.image = thumbnail_BnW_3;
    
    [[btnBnW layer] setBorderWidth:2.0f];
    [[btnBnW layer] setBorderColor:[UIColor greenColor].CGColor];
    
    [[btnColour layer] setBorderWidth:2.0f];
    [[btnColour layer] setBorderColor:[UIColor clearColor].CGColor];
    
    [[btnRotate layer] setBorderWidth:2.0f];
    [[btnRotate layer] setBorderColor:[UIColor clearColor].CGColor];
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    filteredImage = [UIImage imageWithCGImage:imageRef];
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    return filteredImage;
}


- (IBAction)CommentsCountpressed:(id)sender {
    
    UIButton *senderBtn = (UIButton*) sender;
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"Select Option"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"No Comment"
                     image:[UIImage imageNamed:@"action_icon"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"50 Comments"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"Unlimited Comments"
                     image:[UIImage imageNamed:@"reload"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:senderBtn.frame
                 menuItems:menuItems];
    
}



- (IBAction)tagFriendsPressed:(id)sender {
    
    [self.view addSubview:tagFriendsView];
    
    
}


#pragma mark AUDIO RECORDING AND UPLOADING

-(void)setAudioRecordSettings
{
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                   //[NSNumber numberWithInt:kAudioFormatMPEGLayer3], AVFormatIDKey,
                                    [NSNumber numberWithInt:AVAudioQualityHigh],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 1],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];

    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    _audioRecorder.delegate = self;
    if (error)
    {
        
        
    } else {
        [_audioRecorder prepareToRecord];
    }
}

- (IBAction)recorderTapped:(id)sender {
    closeBtnAudio.hidden = true;
    
    if(!isRecording){
        [self animateImages];
        timerToupdateLbl = [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
        audioTimeOut = [NSTimer scheduledTimerWithTimeInterval: 60.0 target: self
                                                      selector: @selector(callAfterSixtySecond:) userInfo: nil repeats: NO];
        [_audioRecorder record];
    }
    else{
        
        [_audioRecorder stop];
        [audioBtnImage stopAnimating];
    }
    isRecording = true;
}
- (IBAction)AudioClosePressed:(id)sender {
    
    [_uploadAudioView removeFromSuperview];
}
-(void) callAfterSixtySecond:(NSTimer*) t
{
    [_audioRecorder stop];
    [timerToupdateLbl invalidate];
    [audioTimeOut invalidate];
    
}
-(void) updateCountdown {
    int minutes, seconds;
    secondsLeft--;
    minutes = (secondsLeft % 3600) / 60;
    seconds = (secondsLeft %3600) % 60;
    countDownlabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    secondsConsumed = [NSString stringWithFormat:@"%02d:%02d", 00, 60 - secondsLeft];
}
-(void)animateImages{
    NSArray *loaderImages = @[@"state1.png", @"state2.png", @"state3.png"];
    NSMutableArray *loaderImagesArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < loaderImages.count; i++) {
        [loaderImagesArr addObject:[UIImage imageNamed:[loaderImages objectAtIndex:i]]];
    }
    audioBtnImage.animationImages = loaderImagesArr;
    audioBtnImage.animationDuration = 0.5f;
    [audioBtnImage startAnimating];
}
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [timerToupdateLbl invalidate];
    [audioTimeOut invalidate];
    closeBtnAudio.hidden = false;
    isRecording = false;
    countDownlabel.text = @"01:00";
    secondsLeft = 60;
    audioData = [NSData dataWithContentsOfURL:_audioRecorder.url];
    [_uploadAudioView removeFromSuperview];
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.dataToUpload = audioData;
    uploadController.video_duration = secondsConsumed;
    uploadController.ParentCommentID = @"-1";
    uploadController.postID = @"-1";
    uploadController.isAudio = true;
    uploadController.friendsArray = friendsArray;
    thumbnail = [UIImage imageNamed: @"splash_audio_image.png"];
    uploadController.thumbnailImage = [UIImage imageNamed: @"splash_audio_image.png"];
    [[self navigationController] pushViewController:uploadController animated:YES];
 
    //[self.view addSubview:_uploadBeamView];
}
-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder
                                  error:(NSError *)error
{  isRecording = false;
    closeBtnAudio.hidden = false;
    countDownlabel.text = @"00:00";
    secondsLeft = 60;
    secondsConsumed = 0;
    NSLog(@"Encode Error occurred");
}

-(void)uploadAduio:(NSData*)file{
    
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    
    [request setData:file withFileName:[NSString stringWithFormat:@"%@.caf",@"sound"] andContentType:@"audio/caf" forKey:@"audio_link"];
    
    [request setPostValue:userSession forKey:@"session_token"];
    [request setPostValue:privacySelected forKey:@"privacy"];
    //[request setPostValue:TopicSelected forKey:@"topic_id"];
    [request setPostValue:commentAllowed forKey:@"reply_count"];
    [request setPostValue:_statusText.text forKey:@"caption"];
    //[request setPostValue:videotype forKey:@"filter"];
    [request setPostValue:@"0" forKey:@"is_anonymous"];
    [request setPostValue:@"0" forKey:@"mute"];
    [request setPostValue:tagsString forKey:@"topic_name"];
    [request setPostValue:secondsConsumed forKey:@"video_length"];
    [request setPostValue:postID forKey:@"post_id"];
    [request setPostValue:ParentCommentID forKey:@"parent_comment_id"];
    [request setPostValue:METHOD_UPLOAD_STATUS forKey:@"method"];
    //[request setShowAccurateProgress:YES];
    [request setUploadProgressDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:300];
    [request setDelegate:self];
    [request startAsynchronous];
}
#pragma mark -----------
- (IBAction)commentRadio:(RadioButton*)sender{
    
}

- (UIImage *)rotateImage:(UIImage *)image onDegrees:(float)degrees
{
    CGFloat rads = M_PI * degrees / 180;
    float newSide = MAX([image size].width, [image size].height);
    CGSize size =  CGSizeMake(newSide, newSide);
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, newSide/2, newSide/2);
    CGContextRotateCTM(ctx, rads);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(-[image size].width/2,-[image size].height/2,size.width, size.height),image.CGImage);
    UIImage *i = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return i;
}
#pragma mark - TextView Delegates
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if(!isFirstTimeClicked) {
        _statusText.text = @"";
        isFirstTimeClicked = true;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        changeColorForTag = false;
        [textView resignFirstResponder];
        return NO;
    }
    else if ([text isEqualToString:@"#"]) {
        textView.typingAttributes = highlightAttrdict;
    }
    else{
        textView.typingAttributes = normalAttrdict;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == searchField || searchField2){
        [textField resignFirstResponder]; // Dismiss the keyboard.
        [self hideShowsearchbar:self];
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(_statusText.text.length == 0){
        [_statusText resignFirstResponder];
    }
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [self extractTags];
    
    [textView resignFirstResponder];
    
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}
-(void) extractTags{
    tagsString = @"";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&error];
    NSArray *matches = [regex matchesInString:_statusText.text options:0 range:NSMakeRange(0,_statusText.text.length)];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* word = [_statusText.text substringWithRange:wordRange];
        tagsString = [tagsString stringByAppendingString:word];
        tagsString = [tagsString stringByAppendingString:@","];
    }
    if ([tagsString length] > 0)
        tagsString = [tagsString substringToIndex:[tagsString length] - 1];
}
#pragma  mark - custom keyboard

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    self.statusText.text = [self.statusText.text stringByAppendingString:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    
}

- (UIColor *)randomColor {
    return [UIColor colorWithRed:drand48()
                           green:drand48()
                            blue:drand48()
                           alpha:drand48()];
}

- (UIImage *)randomImage {
    CGSize size = CGSizeMake(30, 10);
    UIGraphicsBeginImageContextWithOptions(size , NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextFillRect(context, rect);
    
    fillColor = [self randomColor];
    CGContextSetFillColorWithColor(context, [fillColor CGColor]);
    CGFloat xxx = 3;
    rect = CGRectMake(xxx, xxx, size.width - 2 * xxx, size.height - 2 * xxx);
    CGContextFillRect(context, rect);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [self randomImage];
    [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

@end
