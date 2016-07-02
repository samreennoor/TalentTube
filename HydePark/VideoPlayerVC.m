//
//  VideoPlayerVC.m
//  HydePark
//
//  Created by Apple on 25/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "VideoPlayerVC.h"
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
@interface VideoPlayerVC () <PBJVideoPlayerControllerDelegate,GUIPlayerViewDelegate>
{
    NSString *urlToShare;
    NSString *statusTxt;
}
@property (strong, nonatomic) PBJVideoPlayerController *videoPlayerController;
@property (strong, nonatomic) AsyncImageView *thumbnail;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) GUIPlayerView *playerView;

@end


@implementation VideoPlayerVC
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
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
}

- (void)playerWillEnterFullscreen {
    [UIView animateWithDuration:0.5
                     animations:^{
                         if(IS_IPAD)
                              upperView.frame = CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y - 100, upperView.frame.size.width, upperView.frame.size.height);
                             else
                                 upperView.frame = CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y - 60, upperView.frame.size.width, upperView.frame.size.height);
                     }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)playerWillLeaveFullscreen {
    [UIView animateWithDuration:0.2
                     animations:^{
                         if(IS_IPAD)
                             upperView.frame = CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y + 100, upperView.frame.size.width, upperView.frame.size.height);
                         else
                             upperView.frame = CGRectMake(upperView.frame.origin.x, upperView.frame.origin.y + 60, upperView.frame.size.width, upperView.frame.size.height);
                     }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}
- (void)playerDidEndPlaying {
    [_shareView setHidden:NO];
}

- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [_playerView clean];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setUpView];

//    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:indexToDisplay inSection:0];
//    [VideoPLayerTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    //[VideoPLayerTable reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    
    [_playerView clean];
    _playerView = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark setupView-

-(void) setUpView{
    VideoModel *tempVideo = [videoObjs objectAtIndex:0];

    self.profileImage.imageURL = [NSURL URLWithString:tempVideo.video_thumbnail_link];
    NSURL *url = [NSURL URLWithString:tempVideo.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    [self.profileImage roundImageCorner];
    self.activityind.hidden = false;
    [self.activityind startAnimating];
    self.VideoTitle.text = tempVideo.title;
    statusTxt = tempVideo.title;
    vId = tempVideo.videoID;
    [self setupRating:tempVideo.rating];
    if([tempVideo.is_anonymous isEqualToString:@"0"])
    {
        self.username.text = tempVideo.userName;
    }
    else{
        self.username.text = @"Anonymous";
    }
    if ([tempVideo.like_by_me isEqualToString:@"1"]) {
        [self.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [self.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    self.CH_heart.enabled = YES;
    self.CH_commentsBtn.enabled = YES;
    [self.CH_commentsBtn addTarget:self action:@selector(ShowCommentsPressed:) forControlEvents:UIControlEventTouchUpInside];
    //[self.CH_commentsBtn setTag:indexPath.row];
    self.likesCount.text = tempVideo.like_count;
    self.commentsCount.text = tempVideo.comments_count;
    
    [self.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
   // [cell.CH_heart setTag:indexPath.row];
    //cell.containerView.layer.cornerRadius = cell.containerView.frame.size.width /10.0f;
    //cell.containerView.layer.masksToBounds = YES;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.contentView.frame.size.width, 480)];
    frameForSix = bgView.frame;
    if(IS_IPHONE_6Plus){
        bgView.frame = CGRectMake(0,0, self.contentView.frame.size.width+40, 500);
        frameForSix = bgView.frame;
    }else if(IS_IPAD)
    {
        bgView.frame = CGRectMake(0,0, self.contentView.frame.size.width  , 700);
        frameForSix = bgView.frame;
    }else if(IS_IPHONE_5)
    {
        bgView.frame = CGRectMake(0,0, 320, 400);
        frameForSix = bgView.frame;
    }
    _shareView.frame = frameForSix;
    bgView.backgroundColor = [UIColor blackColor];
    //[cell.contentView addSubview:bgView];
    _playerView = [[GUIPlayerView alloc] initWithFrame:bgView.frame];
    NSURL *URL = [NSURL URLWithString:tempVideo.video_link];
    urlToShare = tempVideo.video_link;
    [self.contentView addSubview:_playerView];
    [_playerView setVideoURL:URL];
    [_playerView prepareAndPlayAutomatically:YES];
    [_playerView setDelegate:self];



}


-(void)setupRating:(float)rating{
    
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
    [self updateRatingApi:rating];
    
}
#pragma mark UPDATE Rating api

-(void) updateRatingApi:(float) rat{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *rating = [NSString stringWithFormat:@"%f",rat];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_UPDATE_RATING,@"method",
                              token,@"Session_token",rating,@"rating",vId,@"post_id", nil];
    
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
               float newRating =[ [result objectForKey:@"total_rating"] floatValue];
                
                VideoModel *tempVideo = [videoObjs objectAtIndex:0];
                [tempVideo setRating:newRating];
                
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
    return tableView.frame.size.height;
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
    
    
    VideoCells *cell;
    
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCells_Iphone6Plus" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else if(IS_IPHONE_5 || IS_IPHONE_6){
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCells" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    else {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VideoCells_Iphone6Plus" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    VideoModel *tempVideo = [videoObjs objectAtIndex:indexPath.row];
    cell.profileImage.imageURL = [NSURL URLWithString:tempVideo.video_thumbnail_link];
    NSURL *url = [NSURL URLWithString:tempVideo.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    [cell.profileImage roundImageCorner];
    cell.activityind.hidden = false;
    [cell.activityind startAnimating];
    cell.VideoTitle.text = tempVideo.title;
    statusTxt = tempVideo.title;
    if([tempVideo.is_anonymous isEqualToString:@"0"])
    {
        cell.username.text = tempVideo.userName;
    }
    else{
        cell.username.text = @"Anonymous";
    }
    if ([tempVideo.like_by_me isEqualToString:@"1"]) {
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    cell.CH_heart.enabled = YES;
    cell.CH_commentsBtn.enabled = YES;
    [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentsPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_commentsBtn setTag:indexPath.row];
    cell.likesCount.text = tempVideo.like_count;
    cell.commentsCount.text = tempVideo.comments_count;
    
    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_heart setTag:indexPath.row];
    //cell.containerView.layer.cornerRadius = cell.containerView.frame.size.width /10.0f;
    //cell.containerView.layer.masksToBounds = YES;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,50, cell.contentView.frame.size.width, 480)];
    frameForSix = bgView.frame;
    if(IS_IPHONE_6Plus){
        bgView.frame = CGRectMake(0,55, cell.contentView.frame.size.width, 500);
        frameForSix = bgView.frame;
    }else if(IS_IPAD)
    {
        bgView.frame = CGRectMake(0,85, cell.contentView.frame.size.width + 350 , 700);
        frameForSix = bgView.frame;
    }else if(IS_IPHONE_5)
    {
        bgView.frame = CGRectMake(0,50, 320, 400);
        frameForSix = bgView.frame;
    }
    _shareView.frame = frameForSix;
    bgView.backgroundColor = [UIColor blackColor];
    //[cell.contentView addSubview:bgView];
    _playerView = [[GUIPlayerView alloc] initWithFrame:bgView.frame];
    NSURL *URL = [NSURL URLWithString:tempVideo.video_link];
    urlToShare = tempVideo.video_link;
    [cell.contentView addSubview:_playerView];
     [_playerView setVideoURL:URL];
     [_playerView prepareAndPlayAutomatically:YES];
     [_playerView setDelegate:self];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
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

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
//        //end of loading
//        isloadingOfCells = true;
//    }
//    if(isloadingOfCells) {
////        AsyncImageView *thumbnail = (AsyncImageView *)[cell.contentView viewWithTag:cell.tag + 10];
//        //[_thumbnail removeFromSuperview];
////        UIActivityIndicatorView *activityIndicators = (UIActivityIndicatorView *)[cell.contentView viewWithTag:cell.tag + 999];
//        //[_activityIndicator removeFromSuperview];
//        [_videoPlayerController stop];
//        [_videoPlayerController.view removeFromSuperview];
//        _videoPlayerController = nil;
//        
//        VideoModel *tempVideo = [videoObjs objectAtIndex:indexPath.row];
//        indexToPlay = indexPath.row;
//        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
//        _videoPlayerController.view.tag = indexPath.row+777;
//        _videoPlayerController.delegate = self;
//        _videoPlayerController.view.frame = frameForSix;
//        _videoPlayerController.videoPath = tempVideo.video_link;
//        [_videoPlayerController playFromBeginning];
//        titleLbl.text = tempVideo.title;
//        [self addChildViewController:_videoPlayerController];
//        [cell.contentView addSubview:_videoPlayerController.view];
//        
//        _thumbnail = [[AsyncImageView alloc] initWithFrame:frameForSix];
//        _thumbnail.imageURL = [NSURL URLWithString:tempVideo.video_thumbnail_link];
//        NSURL *url = [NSURL URLWithString:tempVideo.video_thumbnail_link];
//        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//        [cell.contentView addSubview:_thumbnail];
//        _thumbnail.tag = indexPath.row + 10;
//        
//        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//        _activityIndicator.alpha = 1.0;
//        _activityIndicator.center = CGPointMake(frameForSix.size.width/2, frameForSix.size.height/2);
//        _activityIndicator.hidesWhenStopped = NO;
//        [cell.contentView addSubview:_activityIndicator];
//        [_activityIndicator startAnimating];
//        _activityIndicator.tag = indexPath.row + 999;
//        
//        [_videoPlayerController didMoveToParentViewController:self];
//        
//        /*//create the controls
//         ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:self.moviePlayer style:ALMoviePlayerControlsStyleFullscreen];
//         //[movieControls setAdjustsFullscreenImage:NO];
//         [movieControls setBarColor:[UIColor blackColor]];
//         [movieControls setTimeRemainingDecrements:YES];
//         //[movieControls setFadeDelay:2.0];
//         //[movieControls setBarHeight:100.f];
//         //[movieControls setSeekRate:2.f];
//         
//         //assign controls
//         [self.moviePlayer setControls:movieControls];*/
//    }
//}



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
- (IBAction)ShowCommentsPressed:(id)sender {
//    [_playerView clean];
//    _playerView = nil;
//    [self.navigationController popViewControllerAnimated:NO];
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
    ////////////////////////////////////////////
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
       // videoModel  = _model;
        postID = _model.videoID;
        appDelegate.currentMyCornerIndex = currentSelectedIndex;
        ParentCommentID = @"-1";
    CommentsVC *commentController ;
    if(IS_IPAD)
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    else
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    commentController.myprofile = appDelegate.myprofile;
    commentController.commentsObj   = Nil;
    commentController.postArray     = _model;
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
                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
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
-(IBAction)sharePressed:(id)sender{
    [_fbAndTwitterView setHidden:NO];
   // tapper.enabled = YES;
}
-(IBAction)replayPressed:(id)sender{
    [_shareView setHidden:YES];
    [_playerView play];
}
-(IBAction)fbshareBtn:(id)sender
{
    [_fbAndTwitterView setHidden:YES];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:statusTxt];
        [mySLComposerSheet addURL:[NSURL URLWithString:urlToShare]];
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
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self removeView];
}
-(void) removeView {
    [_fbAndTwitterView setHidden:YES];
}
-(IBAction)twitterShareBtn:(id)sender
{
    [_fbAndTwitterView setHidden:YES];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:statusTxt];
        [mySLComposerSheet addURL:[NSURL URLWithString:urlToShare]];
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
#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
//    NSIndexPath *path = [NSIndexPath indexPathForRow:indexToPlay inSection:0];
//    UITableViewCell *cell = [VideoPLayerTable cellForRowAtIndexPath:path];
//    NSLog(@"%ld",(long)indexToPlay);
    //AsyncImageView *thumbnail = (AsyncImageView *)[cell.contentView viewWithTag:cell.tag + 10];
    
    //UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:cell.tag + 999];
//    [_thumbnail removeFromSuperview];
//    [_activityIndicator removeFromSuperview];
    
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
