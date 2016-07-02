//
//  VCPlayer.m
//  HydePark
//
//  Created by Apple on 12/04/2016.
//  Copyright © 2016 TxLabz. All rights reserved.

#import "VCPlayer.h"
#import "NavigationHandler.h"
#import "VideoCells.h"
#import "Constants.h"
#import "UIImageView+RoundImage.h"
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "GUIPlayerView.h"
#import "Utils.h"
#import "CommentsVC.h"
#import "ALMoviePlayerController.h"
#import "PBJVideoPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "HomeCell.h"
#import "VideoPlayerVC.h"
#import "BeamUploadVC.h"
@interface VCPlayer () <PBJVideoPlayerControllerDelegate>
{
    
}
@property (strong, nonatomic) PBJVideoPlayerController *videoPlayerController;
@property (strong, nonatomic) AsyncImageView *thumbnail;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
@implementation VCPlayer

@synthesize videoObjs,indexToDisplay,isComment,cPostId,isFirst;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    cache = [[NSMutableDictionary alloc] init];
    VideoPLayerTable.opaque = NO;
    VideoPLayerTable.backgroundColor = [UIColor clearColor];
    CommentsModelObj = [[CommentsModel alloc]init];
    videoModel = [[VideoModel alloc]init];
    playerArray = [[NSMutableArray alloc] init];
    videoObj =[[NSMutableArray alloc]init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRatingInVCPlayer:)
                                                 name:@"updateRatingInVCPlayer"
                                               object:nil];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:indexToDisplay inSection:0];
    [VideoPLayerTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateRatingInVCPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRatingInVCPlayer:) name:@"updateRatingInVCPlayer" object:nil];
    [VideoPLayerTable reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [_thumbnail removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --UPDATE Star Rating----
-(void) updateRatingInVCPlayer:(NSNotification *) notification{
    if ([notification.name isEqualToString:@"updateRatingInVCPlayer"])
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
        
        VideoModel *vmodl = videoObjs[startRatingViewTag];
        [vmodl setRating:newRating];
        [videoObjs replaceObjectAtIndex:startRatingViewTag withObject:vmodl];
        [VideoPLayerTable reloadData];
       
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





#pragma mark TableView Data
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD)
    {
        return 410;
    }
    else
    {
    
    return 327;
    }
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(IS_IPHONE_6Plus)
//        return  675;
//    return 617;
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [videoObjs count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    HomeCell *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else if(IS_IPHONE_5 || IS_IPHONE_6){
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
//    VideoModel *tempVideo = [videoObjs objectAtIndex:indexPath.row];
//    cell.profileImage.imageURL = [NSURL URLWithString:tempVideo.video_thumbnail_link];
//    NSURL *url = [NSURL URLWithString:tempVideo.video_thumbnail_link];
//    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//    [cell.profileImage roundImageCorner];
//    cell.activityInd.hidden = false;
//    [cell.activityInd startAnimating];
//    cell.CH_VideoTitle.text = tempVideo.title;
//    
//    if([tempVideo.is_anonymous isEqualToString:@"0"])
//    {
//        cell.CH_userName.text = tempVideo.userName;
//    }
//    else{
//        cell.CH_userName.text = @"Anonymous";
//    }
//    if ([tempVideo.like_by_me isEqualToString:@"1"]) {
//        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//    }else{
//        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//    }
//    cell.CH_commentsBtn.tag = indexPath.row;
//    cell.CH_heart.enabled = YES;
//    //cell.CH_commentsBtn.enabled = YES;
//    [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.CH_commentsBtn setTag:indexPath.row];
//    //cell.ch.text = tempVideo.like_count;
//    cell.CH_CommentscountLbl.text = tempVideo.comments_count;
//    
//    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.CH_heart setTag:indexPath.row];
//    //cell.containerView.layer.cornerRadius = cell.containerView.frame.size.width /10.0f;
//    //cell.containerView.layer.masksToBounds = YES;
//    
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, cell.contentView.frame.size.width, 480)];
//    frameForSix = bgView.frame;
//    if(IS_IPHONE_6Plus){
//        bgView.frame = CGRectMake(0,0, cell.contentView.frame.size.width, 500);
//        frameForSix = bgView.frame;
//    }else if(IS_IPAD)
//    {
//        bgView.frame = CGRectMake(0,11, cell.contentView.frame.size.width + 393, 700);
//        frameForSix = bgView.frame;
//    }else if(IS_IPHONE_5)
//    {
//        bgView.frame = CGRectMake(0,0, 320, 400);
//        frameForSix = bgView.frame;
//    }
//    bgView.backgroundColor = [UIColor blackColor];
//    [cell.contentView addSubview:bgView];
    VideoModel *tempVideos = [[VideoModel alloc]init];
    tempVideos  = [videoObjs objectAtIndex:indexPath.row];
    cell.CH_userName.text = tempVideos.userName;
    cell.videoId = tempVideos.videoID;
    cell.isUserChannel = false;
    cell.isVCPlayer = true;
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
    [cell.btnMenu setTag:indexPath.row];
    
    [cell.btnMenu addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
    [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    cell.userProfileView.tag = indexPath.row;
    [cell.CH_heart setTag:indexPath.row];
    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    if ([tempVideos.like_by_me isEqualToString:@"1"]) {
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
    [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_playVideo setTag:indexPath.row];
    
    [cell.CH_flag setTag:indexPath.row];
    cell.CH_commentsBtn.enabled = YES;
    // cell.CH_RcommentsBtn.enabled = YES;
    [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_commentsBtn setTag:indexPath.row];

    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark - IBButton Actions
- (IBAction)CancelEditBtn:(id)sender{
    _viewItems.hidden = YES;
    
}
-(IBAction)fbshareBtn:(id)sender
{
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



-(void)menuBtnPressed:(UIButton*)sender{
    //  NSInteger selectedIndex;
    currentSelectedIndex = sender.tag ;
    
        _viewItems.hidden = false;
        selectedVideo  = [videoObjs objectAtIndex:currentSelectedIndex];
        postID = selectedVideo.videoID;

    
    
    //User *user=userArray[index];
    // viewItems.hidden = false;
    CGAffineTransform gameModViewTransform = _viewItems.transform;
    _viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:0.3/2.0 animations:^{
        _viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            _viewItems.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                _viewItems.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
    _viewItems.transform = gameModViewTransform;
    
    
}
-(void)playVideo:(UIButton*)sender{
    
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    
        [videoObj removeAllObjects];
        //   myChannelModel *modelss = [channelVideos objectAtIndex:currentSelectedIndex];
        //   postID = modelss.Post_ID;
        //  for(int i = 0; i < channelVideos.count ; i++){
        VideoModel *tempModel = [videoObjs objectAtIndex:currentSelectedIndex];
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




- (IBAction)editBeam:(id)sender{
    // VideoModel *tempVideos  = [channelVideos objectAtIndex:currentSelectedIndex];
    NSString *postIDs = selectedVideo.videoID;
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.video_thumbnail = selectedVideo.video_thumbnail_link;
    uploadController.postID = postIDs;
    uploadController.caption = selectedVideo.title;
    //uploadController.friendsArray = friendsArray;
    appDelegate.hasbeenEdited = TRUE;
    [[self navigationController] pushViewController:uploadController animated:YES];
}



- (IBAction)ReportBtn:(id)sender{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
                [videoObjs removeObjectAtIndex:currentSelectedIndex];
                [VideoPLayerTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                //NSInteger BeamsCount =  [userBeams.text integerValue];
              //  BeamsCount--;
               // userBeams.text = [[NSString alloc]initWithFormat:@"%ld Beams",(long)BeamsCount];
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





-(void)scrollViewDidScroll:(UIScrollView *)sender
{
    //[self checkWhichVideoToEnable];
}

-(void)checkWhichVideoToEnable
{
    //    for(UITableViewCell *cell in [VideoPLayerTable visibleCells])
    //    {
    //        if([cell isKindOfClass:[VideoCells class]])
    //        {
    //            NSIndexPath *indexPath = [VideoPLayerTable indexPathForCell:cell];
    //            CGRect cellRect = [VideoPLayerTable rectForRowAtIndexPath:indexPath];
    //            UIView *superview = VideoPLayerTable.superview;
    //
    //            CGRect convertedRect=[VideoPLayerTable convertRect:cellRect toView:superview];
    //            CGRect intersect = CGRectIntersection(VideoPLayerTable.frame, convertedRect);
    //            float visibleHeight = CGRectGetHeight(intersect);
    //
    //            if(visibleHeight>620.0f*0.9) // only if 60% of the cell is visible
    //            {
    //
    //                break;
    //            }
    //            else
    //            {
    //
    //                break;
    //
    //            }
    //        }
    //    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        //end of loading
        isloadingOfCells = true;
    }
    if(isloadingOfCells) {
        //        AsyncImageView *thumbnail = (AsyncImageView *)[cell.contentView viewWithTag:cell.tag + 10];
        //[_thumbnail removeFromSuperview];
        //        UIActivityIndicatorView *activityIndicators = (UIActivityIndicatorView *)[cell.contentView viewWithTag:cell.tag + 999];
        //[_activityIndicator removeFromSuperview];
        [_videoPlayerController stop];
        [_videoPlayerController.view removeFromSuperview];
        _videoPlayerController = nil;
        
        VideoModel *tempVideo = [videoObjs objectAtIndex:indexPath.row];
        indexToPlay = indexPath.row;
        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
        _videoPlayerController.view.tag = indexPath.row+777;
        _videoPlayerController.delegate = self;
        _videoPlayerController.view.frame = frameForSix;
        _videoPlayerController.videoPath = tempVideo.video_link;
        [_videoPlayerController playFromBeginning];
        titleLbl.text = tempVideo.title;
        [self addChildViewController:_videoPlayerController];
        [cell.contentView addSubview:_videoPlayerController.view];
        
        _thumbnail = [[AsyncImageView alloc] initWithFrame:frameForSix];
        _thumbnail.imageURL = [NSURL URLWithString:tempVideo.video_thumbnail_link];
        NSURL *url = [NSURL URLWithString:tempVideo.video_thumbnail_link];
        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
        [cell.contentView addSubview:_thumbnail];
        _thumbnail.tag = indexPath.row + 10;
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.alpha = 1.0;
        _activityIndicator.center = CGPointMake(frameForSix.size.width/2, frameForSix.size.height/2);
        _activityIndicator.hidesWhenStopped = NO;
        [cell.contentView addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        _activityIndicator.tag = indexPath.row + 999;
        
        [_videoPlayerController didMoveToParentViewController:self];
        
        /*//create the controls
         ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleFullscreen];
         //[movieControls setAdjustsFullscreenImage:NO];
         [movieControls setBarColor:[UIColor blackColor]];
         [movieControls setTimeRemainingDecrements:YES];
         //[movieControls setFadeDelay:2.0];
         //[movieControls setBarHeight:100.f];
         //[movieControls setSeekRate:2.f];
         
         //assign controls
         [self.moviePlayer setControls:movieControls];*/
    }
}



- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isloadingOfCells) {
        
    }
    
}
- (void)LikeHearts:(UIButton*)sender{
    //liked = nil;
    UIButton *LikeBtn = (UIButton *)sender;
    //LikeBtn.enabled = false;
    currentSelectedIndex = LikeBtn.tag;
    VideoModel *tempVideo = [videoObjs objectAtIndex:currentSelectedIndex];
    postID = tempVideo.videoID;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    VideoCells *cell = [VideoPLayerTable cellForRowAtIndexPath:indexPath];
    
    if([tempVideo.like_by_me isEqualToString:@"1"])
    {
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
        
        tempVideo.like_count = [[videoObjs objectAtIndex:currentSelectedIndex]valueForKey:@"like_count"];
        NSInteger likeCount = [tempVideo.like_count intValue];
        likeCount--;
        tempVideo.like_count = [NSString stringWithFormat: @"%ld", likeCount];
        cell.likesCount.text = [NSString stringWithFormat: @"%ld", likeCount];
        tempVideo.like_by_me = @"0";
        //        [videoObjs replaceObjectAtIndex:currentSelectedIndex withObject:tempVideo];
        //        [VideoPLayerTable reloadData];
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        //        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        //        [VideoPLayerTable beginUpdates];
        //        [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        //        [VideoPLayerTable endUpdates];
    }
    else{
        [LikeBtn setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
        tempVideo.like_count = [[videoObjs objectAtIndex:currentSelectedIndex]valueForKey:@"like_count"];
        NSInteger likeCount = [tempVideo.like_count intValue];
        likeCount++;
        tempVideo.like_count = [NSString stringWithFormat: @"%ld", likeCount];
        cell.likesCount.text = [NSString stringWithFormat: @"%ld", likeCount];
        tempVideo.like_by_me = @"1";
        //        [videoObjs replaceObjectAtIndex:currentSelectedIndex withObject:tempVideo];
        //        [VideoPLayerTable reloadData];
        //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndex inSection:0];
        //        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        //        [VideoPLayerTable beginUpdates];
        //        [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        //        [VideoPLayerTable endUpdates];
    }
    if(isComment)
        [self LikeComment:currentSelectedIndex];
    else
        [self LikePost:currentSelectedIndex];
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
                    appDelegate.timeToupdateHome = TRUE;
                    //                    VideoModel *_Videos = [[VideoModel alloc]init];
                    //                    _Videos = [videoObjs objectAtIndex:indexToLike];
                    //                    _Videos.like_count = [[videoObjs objectAtIndex:indexToLike]valueForKey:@"like_count"];
                    //                    NSInteger likeCount = [_Videos.like_count intValue];
                    //                    likeCount++;
                    //                    _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    //                    _Videos.like_by_me = @"1";
                    //                    [videoObjs replaceObjectAtIndex:indexToLike withObject:_Videos];
                    //                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike inSection:0];
                    //                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    //                    [VideoPLayerTable beginUpdates];
                    //                    [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    //                    [VideoPLayerTable endUpdates];
                }
                else if ([message isEqualToString:@"Post is Successfully unliked by this user."])
                {
                    appDelegate.timeToupdateHome = TRUE;
                    //                    VideoModel *_Videos = [[VideoModel alloc]init];
                    //                    _Videos = [videoObjs objectAtIndex:indexToLike];
                    //                    _Videos.like_count = [[videoObjs objectAtIndex:indexToLike]valueForKey:@"like_count"];
                    //                    NSInteger likeCount = [_Videos.like_count intValue];
                    //                    likeCount--;
                    //                    _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    //                    _Videos.like_by_me = @"0";
                    //                    [videoObjs replaceObjectAtIndex:indexToLike withObject:_Videos];
                    //                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike inSection:0];
                    //                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    //                    [VideoPLayerTable beginUpdates];
                    //                    [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    //                    [VideoPLayerTable endUpdates];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}
#pragma mark - Like Post
- (void) LikeComment:(NSUInteger )indexToLike{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_LIKE_COMMENT,@"method",
                              token,@"session_token",postID,@"comment_id",nil];
    
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
                if ([message isEqualToString:@"Comment is Successfully Liked."]) {
                    
                    //                    VideoModel *_Videos = [[VideoModel alloc]init];
                    //                    _Videos = [videoObjs objectAtIndex:indexToLike];
                    //                    _Videos.like_count = [[videoObjs objectAtIndex:indexToLike]valueForKey:@"like_count"];
                    //                    NSInteger likeCount = [_Videos.like_count intValue];
                    //                    likeCount++;
                    //                    _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    //                    _Videos.like_by_me = @"1";
                    //                    [videoObjs replaceObjectAtIndex:indexToLike withObject:_Videos];
                    //                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike inSection:0];
                    //                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    //                    [VideoPLayerTable beginUpdates];
                    //                    [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    //                    [VideoPLayerTable endUpdates];
                }
                else if ([message isEqualToString:@"User have Successfully Unliked the comment"])
                {
                    
                    //                    VideoModel *_Videos = [[VideoModel alloc]init];
                    //                    _Videos = [videoObjs objectAtIndex:indexToLike];
                    //                    _Videos.like_count = [[videoObjs objectAtIndex:indexToLike]valueForKey:@"like_count"];
                    //                    NSInteger likeCount = [_Videos.like_count intValue];
                    //                    likeCount--;
                    //                    _Videos.like_count = [NSString stringWithFormat: @"%ld", likeCount];
                    //                    _Videos.like_by_me = @"0";
                    //                    [videoObjs replaceObjectAtIndex:indexToLike withObject:_Videos];
                    //                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexToLike inSection:0];
                    //                    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                    //                    [VideoPLayerTable beginUpdates];
                    //                    [VideoPLayerTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                    //                    [VideoPLayerTable endUpdates];
                }
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }];
}
#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    //[self.navigationController popViewControllerAnimated:YES];
    //    UIButton *senderBtn = sender;
    //    senderBtn.enabled = false;
    //    UIButton *CommentsBtn = (UIButton *)sender;
    //    currentSelectedIndex = CommentsBtn.tag;
    //    VideoModel *tempVideos = [[VideoModel alloc]init];
    //    tempVideos = [videoObjs objectAtIndex:currentSelectedIndex];
    //    videoModel.videoID = tempVideos.videoID;
    //    videoModel.video_thumbnail_link = tempVideos.video_thumbnail_link;
    //    videoModel.video_link = tempVideos.video_link;
    //    videoModel.profile_image =  tempVideos.profile_image;
    //    videoModel.userName = tempVideos.userName;
    //    videoModel.is_anonymous = tempVideos.is_anonymous;
    //    videoModel.title = tempVideos.title;
    //    videoModel.like_count = tempVideos.like_count;
    //    videoModel.like_by_me = tempVideos.like_by_me;
    //    videoModel.seen_count = tempVideos.seen_count;
    //    videoModel.title = tempVideos.title;
    //    videoModel.comments_count = tempVideos.comments_count;
    //    videoModel.user_id = tempVideos.user_id;
    //    videoModel.reply_count = tempVideos.reply_count;
    //    if(!isComment){
    //        ParentCommentID = @"-1";
    //        postID = tempVideos.videoID;
    //        cPostId = postID;
    //    }
    //    else {
    //        ParentCommentID = tempVideos.videoID;
    //        //postID = cPostId;
    //    }
    //    [self GetCommnetsOnPost];
    ///////////////////////////////////////////////////////////
    UIButton *senderBtn = sender;
    senderBtn.enabled = false;
    CommentsArray = nil;
    //  commentsTable.hidden = NO;
    //  Cm_VideoPlay.hidden = NO;
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    
    // [Cm_VideoPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    // [Cm_VideoPlay setTag:currentSelectedIndex];
    VideoModel *_model = [videoObjs objectAtIndex:currentSelectedIndex];
    videoModel  = _model;
    postID = videoModel.videoID;
    appDelegate.currentMyCornerIndex = currentSelectedIndex;
    ParentCommentID = @"-1";
    CommentsVC *commentController ;
    if(IS_IPAD)
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    else
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    commentController.myprofile = appDelegate.myprofile;
    commentController.commentsObj   = Nil;
    commentController.postArray     = videoModel;
    commentController.cPostId       = postID;
    commentController.isFirstComment = TRUE;
    commentController.isComment     = FALSE;
    
    [[self navigationController] pushViewController:commentController animated:YES];

    
    
    
    
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",cPostId,@"post_id", nil];
    
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
                    _comment.seen_count   = [tempDict objectForKey:@"seen_count"];
                    _comment.reply_count = [tempDict objectForKey:@"reply_count"];
                    
                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
                    [CommentsModelObj.mainArray addObject:_comment.video_link];
                    [CommentsModelObj.CommentsArray addObject:_comment];
                    
                }
                CommentsVC *commentController ;
                if(IS_IPAD)
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
                else
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
                commentController.commentsObj = CommentsModelObj;
                commentController.postArray = videoModel;
                commentController.cPostId = cPostId;
                commentController.isFirstComment = isFirst;
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
#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
    //    NSIndexPath *path = [NSIndexPath indexPathForRow:indexToPlay inSection:0];
    //    UITableViewCell *cell = [VideoPLayerTable cellForRowAtIndexPath:path];
    //    NSLog(@"%ld",(long)indexToPlay);
    //AsyncImageView *thumbnail = (AsyncImageView *)[cell.contentView viewWithTag:cell.tag + 10];
    
    //UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:cell.tag + 999];
    [_thumbnail removeFromSuperview];
    [_activityIndicator removeFromSuperview];
    
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    switch (videoPlayer.bufferingState) {
        case PBJVideoPlayerBufferingStateUnknown:
            //     NSLog(@"Buffering state unknown!");
            break;
            
        case PBJVideoPlayerBufferingStateReady:
            // NSLog(@"Buffering state Ready! Video will start/ready playing now.");
            
            [_activityIndicator removeFromSuperview];
            break;
            
        case PBJVideoPlayerBufferingStateDelayed:
            //NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
            //            [self.view addSubview:_activityIndicator];
            //                [_activityIndicator startAnimating];
            break;
        default:
            break;
    }
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    
}
@end

