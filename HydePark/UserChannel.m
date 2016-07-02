//
//  UserChannel.m
//  HydePark
//
//  Created by Apple on 22/02/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "UserChannel.h"
#import "NavigationHandler.h"
#import "Utils.h"
#import "UIImageView+RoundImage.h"
#import "AVFoundation/AVFoundation.h"
#import "AsyncImageView.h"
#import "ChannelCell.h"
#import "Constants.h"
#import "CommentsVC.h"
#import "NewHomeCells.h"
#import "VideoModel.h"
#import "VideoPlayerVC.h"
#import "Followings.h"
#import "FriendsVC.h"
#import "HomeCell.h"
#import "BeamUploadVC.h"

@interface UserChannel ()

@end

@implementation UserChannel
@synthesize ChannelObj,friendID;
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate.IS_userChannel = true;
    // Do any additional setup after loading the view from its nib.
    videomodel = [[VideoModel alloc]init];
    CommentsModelObj = [[CommentsModel alloc] init];
    userChannelObj = [[UserChannelModel alloc]init];
    videoObj = [[NSMutableArray alloc] init];
    FollowingsArray = [[NSArray alloc] init];
    FollowingsAM    = [[NSMutableArray alloc] init];
    selectedVideo = [[UserChannelModel alloc]init];

    if(ChannelObj.trendingArray == nil)
        [self GetUsersChannel];
    [self initViewWithData];
    if(IS_IPAD){
        _boxLeftLayoutconstrain.constant = 150;
    
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateRatingInUserChannel:)
                                                 name:@"updateRatingInUserChannel"
                                               object:nil];
}


- (void)viewWillDisappear:(BOOL)animated{

  //  appDelegate.IS_userChannel = false;


}
-(void)viewDidDisappear:(BOOL)animated{
   
    appDelegate.IS_userChannel = false;


}
-(void)viewWillAppear:(BOOL)animated{


    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateRatingInUserChannel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRatingInUserChannel:) name:@"updateRatingInUserChannel" object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initViewWithData{
  
    friendsImage.imageURL = [NSURL URLWithString:ChannelObj.profile_image];
    NSURL *url = [NSURL URLWithString:ChannelObj.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    appDelegate.IS_celeb = ChannelObj.is_celeb;
    friendId = ChannelObj.user_id;
    _userNameMid.text = ChannelObj.full_name;
    _viewToRound.layer.cornerRadius = 55;
    _viewToRound.layer.masksToBounds = YES;
   _viewToRound.clipsToBounds = YES;
//    _picBorder.layer.cornerRadius = _picBorder.frame.size.width / 4;
//    _picBorder.clipsToBounds = YES;
//    _picBorder.layer.masksToBounds = NO;
//    friendsCover.imageURL = [NSURL URLWithString:ChannelObj.cover_link];
//    NSURL *url1 = [NSURL URLWithString:ChannelObj.cover_link];
//    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"User_Id"] == ChannelObj.user_id){
        friendsStatusbtn.hidden = YES;
        _Followlbl.hidden = YES;
    }
    else{
        friendsStatusbtn.hidden = NO;
        _Followlbl.hidden = NO;
    }
    if ([ChannelObj.state isEqualToString:@"ADD_FRIEND"]) {
        _Followlbl.text =  @"FOLLOW";
        _followlblMid.text = @"FOLLOW";
    }
    else{
        _Followlbl.text = @"FOLLOWING";
        _followlblMid.text = @"FOLLOWING";
    }
//    if(IS_IPHONE_6Plus){
//        _countImage.frame = CGRectMake(_countImage.frame.origin.x - 8, _countImage.frame.origin.y + 5, _countImage.frame.size.width, _countImage.frame.size.width);
//        _follwersCount.frame = _countImage.frame;
//    }
    if([ChannelObj.is_celeb isEqualToString:@"1"])
    {
        //_profileViews.center = CGPointMake(self.view.center.x, _profileViews.center.y);
        friendsNamelbl.hidden = YES;
        _followersBtn.enabled = FALSE;
        _followingBtn.enabled = FALSE;
        _bbcbtn.enabled = YES;
        _emiratesbtn.enabled = YES;
        _redbullbtn.enabled = YES;
        bgView.hidden = YES;
        friendsBeamcount.hidden = YES;
        friendsFollowings.hidden = YES;
        friendsFollowers.hidden = YES;
       // _follwersCount.hidden = NO;
       // _countImage.hidden    = NO;
       // _follwersCount.text = ChannelObj.likes_count;
        _userNameMid.text = ChannelObj.full_name;
    }
    else {
        _picBorderMid.hidden = YES;
        _friendsImageMid.hidden = YES;
        _followBorderMid.hidden = YES;
        _followlblMid.hidden = YES;
        _adsBar.hidden = YES;
    }
    friendsNamelbl.text = ChannelObj.full_name;
    if(ChannelObj.beams_count)
        friendsBeamcount.text =ChannelObj.beams_count ;
    if(ChannelObj.friends_count)
        friendsFollowings.text = ChannelObj.friends_count;
    if(ChannelObj.likes_count)
        friendsFollowers.text = ChannelObj.likes_count;
    
    int tcount = [userChannelObj.beams_count intValue];
    if (tcount <=  1) {
        _lblVideos.text = @"Video";
        
    }
    
    
}


-(void) updateRatingInUserChannel:(NSNotification *) notification{
   

    if ([notification.name isEqualToString:@"updateRatingInUserChannel"])
    {
       
    
            NSDictionary* userInfo = notification.object;
            UserChannelModel  *vObj= userInfo[@"videoObj"];
            startRatingViewTag = [userInfo[@"tag"] longLongValue];
            //[newsfeedsVideos replaceObjectAtIndex:vObj.currentIndex withObject:vObj];
            //[_TableHome reloadData];
           [self updateRatingApi:vObj];
        
    }
    
    
    
}
-(void) reloadTablView {
    
        UserChannelModel *vmodl = ChannelObj.trendingArray[startRatingViewTag];
        [vmodl setRating:newRating];
        [ChannelObj.trendingArray replaceObjectAtIndex:startRatingViewTag withObject:vmodl];
        [friendsChannelTable reloadData];
    }

#pragma mark UPDATE Rating api

-(void) updateRatingApi:(UserChannelModel *) vobj{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSString *rating = [NSString stringWithFormat:@"%f",vobj.rating];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_UPDATE_RATING,@"method",
                              token,@"Session_token",rating,@"rating",vobj.VideoID,@"post_id", nil];
    
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





-(IBAction)openBBC:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bbc.com"]];
}
-(IBAction)openEmirates:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.emirates.com"]];
}
-(IBAction)openREDBull:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.redbull.com/en"]];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)getProfile:(id)sender{
    appDelegate.loaduserProfiel = TRUE;
    UIButton *Senderid = (UIButton *)sender;
    currentSelectedIndex = Senderid.tag;
    appDelegate.userToView = ChannelObj.user_id;
    [[NavigationHandler getInstance]MoveToProfile];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPAD) {
        
        return 415.0;

    
    }
    return 327.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    int rows = (int)([ChannelObj.trendingArray count]/2);
//    if([ChannelObj.trendingArray count] %2 == 1) {
//        rows++;
//    }
    return ChannelObj.trendingArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeCell *cell;
    currentIndex = indexPath.row;
    if (IS_IPAD) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeCell_iPad" owner:self options:nil];
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
    UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
    tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentIndex];

    cell.videoId = tempVideos.VideoID;
    cell.isUserChannel = true;
    cell.isVCPlayer = false;
    cell.CH_userName.text = tempVideos.userName;
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
    
    [cell setupRating:tempVideos.rating];
    cell.startRating.tag = indexPath.row;
    cell.CH_heartCountlbl.text = tempVideos.like_count;
    cell.CH_seen.text = tempVideos.seen_count;
    cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    if([tempVideos.is_anonymous  isEqualToString: @"0"]){
        
    }
    else{
        //cell.CH_Video_Thumbnail.image = [UIImage imageNamed:@"anonymousDp.png"];
        cell.CH_userName.text = @"Anonymous";
        cell.userProfileView.enabled = false;
    }
//    cell.imgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
//    cell.imgContainer.layer.masksToBounds = YES;
//    [cell.CH_Video_Thumbnail roundCorners];
    cell.CH_Video_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    NSURL *url1 = [NSURL URLWithString:tempVideos.video_thumbnail_link];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url1];
    cell.CH_profileImage.imageURL = [NSURL URLWithString:tempVideos.profile_image];
    NSURL *url2 = [NSURL URLWithString:tempVideos.profile_image];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url2];
    [cell.CH_playVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    //appDelegate.videotoPlay = [getTrendingVideos.mainhomeArray objectAtIndex:indexPath.row];
    [cell.userProfileView addTarget:self action:@selector(MovetoUserProfile:) forControlEvents:UIControlEventTouchUpInside];
    cell.userProfileView.tag = currentIndex;
    [cell.CH_heart setTag:currentIndex];
    [cell.CH_heart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
    if ([tempVideos.like_by_me isEqualToString:@"1"]) {
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
    }else{
        [cell.CH_heart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
    }
    
    [cell.CH_flag addTarget:self action:@selector(Flag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_playVideo setTag:currentIndex];
    
    [cell.CH_flag setTag:currentIndex];
    cell.CH_commentsBtn.enabled = YES;
    //cell.CH_RcommentsBtn.enabled = YES;
    [cell.CH_commentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.CH_commentsBtn setTag:currentIndex];
    [cell.btnMenu setTag:currentIndex];
    
    [cell.btnMenu addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    currentIndex++;
//    if(currentIndex < ChannelObj.trendingArray.count)
//    {
//        UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
//        tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentIndex];
//        [cell.CH_RcommentsBtn addTarget:self action:@selector(ShowCommentspressed:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.CH_RcommentsBtn setTag:currentIndex];
//        [cell.CH_RplayVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.CH_RplayVideo setTag:currentIndex];
//        [cell.CH_Rheart setTag:currentIndex];
//        [cell.CH_Rheart addTarget:self action:@selector(LikeHearts:) forControlEvents:UIControlEventTouchUpInside];
//        cell.CH_RVideoTitle.text = tempVideos.title;
//        cell.CH_Rseen.text = tempVideos.seen_count;
//        cell.RimgContainer.layer.cornerRadius  = cell.imgContainer.frame.size.width /6.2f;
//        cell.RimgContainer.layer.masksToBounds = YES;
//        [cell.CH_RVideo_Thumbnail roundCorners];
//        cell.CH_RheartCountlbl.text             = tempVideos.like_count;
//        if([tempVideos.comments_count isEqualToString:@"0"])
//        {
//            cell.CH_RCommentscountLbl.hidden = YES;
//            cell.rightreplImg.hidden = YES;
//        }
//        else{
//            cell.CH_RCommentscountLbl.text = tempVideos.comments_count;
//        }
//        cell.CH_RuserName.text = tempVideos.userName;
//        cell.CH_RVideo_Thumbnail.imageURL = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//        NSURL *url = [NSURL URLWithString:tempVideos.video_thumbnail_link];
//        [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
//        if([tempVideos.is_anonymous  isEqualToString: @"0"]){
//            
//        }
//        else{
//            //cell.CH_RVideo_Thumbnail.image =[UIImage imageNamed:@"anonymousDp.png"];
//            cell.CH_RuserName.text = @"Anonymous";
//        }
//        if ([tempVideos.like_by_me isEqualToString:@"1"]) {
//            [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likeblue.png"] forState:UIControlStateNormal];
//        }else{
//            [cell.CH_Rheart setBackgroundImage:[UIImage imageNamed:@"likenew.png"] forState:UIControlStateNormal];
//        }
//        currentIndex++;
//    }
//    else{
//        cell.CH_RprofileImage.hidden = YES;
//        cell.CH_Rseen.hidden = YES;
//        cell.CH_RcommentsBtn.hidden = YES;
//        cell.CH_RuserName.hidden = YES;
//        cell.CH_Rheart.hidden = YES;
//        cell.RimgContainer.hidden = YES;
//        cell.CH_RplayVideo.hidden = YES;
//        cell.Rtransthumb.hidden = YES;
//        cell.CH_RVideoTitle.hidden = YES;
//        cell.rightreplImg.hidden = YES;
//        cell.CH_RCommentscountLbl.hidden = YES;
//        cell.playImage.hidden = YES;
//    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)MovetoUserProfile:(UIButton*)sender{

    
//    UIButton *statusBtn = (UIButton *)sender;
//    currentSelectedIndex = statusBtn.tag;
//    
//        
//        VideoModel *tempVideos = [[VideoModel alloc]init];
//        tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
//        
//        friendId = tempVideos.user_id;
//        // UserRelation = tempVideos.status;
//        // if ([UserRelation isEqualToString:@"ADD_FRIEND"]) {
//        
//        [friendsStatusbtn setTitle:@"Add Friend" forState:UIControlStateNormal];
// 
//        [self GetUsersChannel];
    
}



-(void) GetUsersChannel{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_GET_USERS_CHANNEL,@"method",
                              token,@"Session_token",@"1",@"page_no",friendID,@"user_id", nil];
    
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
                
                int tcount = [userChannelObj.beams_count intValue];
            if (tcount <=  1) {
                    _lblVideos.text = @"Video";
                    
                }
                //////My Videos Response //////
                
                chPostArray = [result objectForKey:@"posts"];
                userChannelObj.trendingArray = [[NSMutableArray alloc] init];

                
                for(NSDictionary *tempDict in chPostArray){
                    
                    UserChannelModel *_Videos = [[UserChannelModel alloc] init];
                    
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
                    _Videos.VideoID = [tempDict objectForKey:@"id"];
                    _Videos.Tags = [tempDict objectForKey:@"tag_friends"];
                    _Videos.video_length = [tempDict objectForKey:@"video_length"];
                    _Videos.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
                    _Videos.reply_count = [tempDict objectForKey:@"reply_count"];
           
                    [userChannelObj.trendingArray addObject:_Videos];
                    chPostArray = userChannelObj.trendingArray;
                }
                ChannelObj = userChannelObj;
                [self initViewWithData];
                [friendsChannelTable reloadData];
            }
        }
        else{
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
}

-(void) ReplyCommentpressed:(UIButton *)sender{
    UIButton *CommentsBtn = (UIButton *)sender;
    CommentsBtn.enabled = false;
    currentSelectedIndex = CommentsBtn.tag;
    CommentsModel *tempVideos = [[CommentsModel alloc]init];
    tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    ParentCommentID = tempVideos.VideoID;
    
    videomodel.videoID              = tempVideos.VideoID;
    videomodel.video_thumbnail_link = tempVideos.video_thumbnail_link;
    videomodel.video_link           = tempVideos.video_link;
    videomodel.profile_image        =  tempVideos.profile_link;
    videomodel.userName             = tempVideos.userName;
    videomodel.is_anonymous         = tempVideos.is_anonymous;
    videomodel.title                = tempVideos.title;
    videomodel.like_count           = tempVideos.comment_like_count;
    videomodel.like_by_me           = tempVideos.liked_by_me;
    videomodel.seen_count           = tempVideos.seen_count;
    videomodel.title                = tempVideos.title;
    videomodel.comments_count       = tempVideos.comments_count;
    videomodel.reply_count          = tempVideos.reply_count;
    
    [self GetCommnetsOnPost];
}
//-(void) GetCommnetsOnPost{
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    NSURL *url = [NSURL URLWithString:SERVER_URL];
//
//    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
//
//    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
//                              token,@"Session_token",@"1",@"page_no",ParentCommentID,@"parent_id",,@"post_id", nil];
//
//    NSData *postData = [Utils encodeDictionary:postDict];
//
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    [request setURL:url];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:postData];
//
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
//        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
//        {
//            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//
//            int success = [[result objectForKey:@"success"] intValue];
//            if(success == 1) {
//
//                //////Comments Videos Response //////
//                CommentsArray = [result objectForKey:@"comments"];
//                CommentsModelObj.CommentsArray = [[NSMutableArray alloc] init];
//                CommentsModelObj.mainArray = [[NSMutableArray alloc]init];
//                CommentsModelObj.ImagesArray = [[NSMutableArray alloc]init];
//                CommentsModelObj.ThumbnailsArray = [[NSMutableArray alloc]init];
//
//                for(NSDictionary *tempDict in CommentsArray){
//
//                    CommentsModel *_comment = [[CommentsModel alloc] init];
//
//                    _comment.title = [tempDict objectForKey:@"caption"];
//                    _comment.comments_count = [tempDict objectForKey:@"comment_count"];
//                    _comment.comment_like_count = [tempDict objectForKey:@"comment_like_count"];
//                    _comment.userName = [tempDict objectForKey:@"full_name"];
//                    _comment.topic_id = [tempDict objectForKey:@"topic_id"];
//                    _comment.user_id = [tempDict objectForKey:@"user_id"];
//                    _comment.profile_link = [tempDict objectForKey:@"profile_link"];
//                    _comment.liked_by_me = [tempDict objectForKey:@"liked_by_me"];
//                    _comment.mute = [tempDict objectForKey:@"mute"];
//                    _comment.video_link = [tempDict objectForKey:@"video_link"];
//                    _comment.video_thumbnail_link = [tempDict objectForKey:@"video_thumbnail_link"];
//                    _comment.image_link = [tempDict objectForKey:@"image_link"];
//                    _comment.VideoID = [tempDict objectForKey:@"id"];
//                    _comment.video_length = [tempDict objectForKey:@"video_length"];
//                    _comment.timestamp = [tempDict objectForKey:@"timestamp"];
//                    _comment.is_anonymous = [tempDict objectForKey:@"is_anonymous"];
//                    _comment.seen_count = [tempDict objectForKey:@"seen_count"];
//                    _comment.reply_count = [tempDict objectForKey:@"reply_count"];
//
//                    [CommentsModelObj.ImagesArray addObject:_comment.profile_link];
//                    [CommentsModelObj.ThumbnailsArray addObject:_comment.video_thumbnail_link];
//                    [CommentsModelObj.mainArray addObject:_comment.video_link];
//                    [CommentsModelObj.CommentsArray addObject:_comment];
//                }
//                // commentsObj = CommentsModelObj;
//                CommentsVC *commentController ;
//                if(IS_IPAD)
//                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC_iPad" bundle:nil];
//                else
//                    commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
//                commentController.commentsObj = CommentsModelObj;
//                commentController.postArray = videoModel;
//                commentController.cPostId   = cPostId;
//                commentController.isFirstComment = FALSE;
//                commentController.isComment     = TRUE;
//                [[self navigationController] pushViewController:commentController animated:YES];
//            }
//            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        }
//        else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Network Problem. Try Again" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [alert show];
//        }
//    }];
//}
- (IBAction)UserStatusbtnPressed:(id)sender {
    
    if ([ChannelObj.state isEqualToString:@"ADD_FRIEND"]) {
        _Followlbl.text = @"UNFOLLOW";
        [self sendFriendRequest];
    }
    else  {
         _Followlbl.text = @"FOLLOW";
        [self sendDeleteFriend];
    }
}
- (void) sendFriendRequest{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
                ChannelObj.state = @"FRIEND";
            }
        }else{
            _Followlbl.text = @"FOLLOW";
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
- (void) sendDeleteFriend{
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_DELETE_FRIEND,@"method",
                              token,@"session_token",friendId,@"friend_id",nil];
    
    NSData *postData = [Utils encodeDictionary:postDict];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response , NSData  *data, NSError *error) {
        
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int success = [[result objectForKey:@"success"] intValue];
            if(success == 1) {
                ChannelObj.state = @"ADD_FRIEND";
               
            }
        }else{
            _Followlbl.text = @"UNFOLLOW";
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
    
}

#pragma mark Get Comments

-(void) ShowCommentspressed:(UIButton *)sender{
    
//    UIButton *CommentsBtn = (UIButton *)sender;
//    currentSelectedIndex = CommentsBtn.tag;
//    
//    UserChannelModel *tempVideos = [[UserChannelModel alloc]init];
//    tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
//    
//    videomodel.videoID = tempVideos.VideoID;
//    videomodel.video_thumbnail_link = tempVideos.video_thumbnail_link;
//    videomodel.video_link = tempVideos.video_link;
//    videomodel.profile_image =  tempVideos.profile_image;
//    videomodel.userName = tempVideos.userName;
//    videomodel.is_anonymous = tempVideos.is_anonymous;
//    videomodel.title = tempVideos.title;
//    videomodel.like_count = tempVideos.like_count;
//    videomodel.like_by_me = tempVideos.like_by_me;
//    videomodel.seen_count = tempVideos.seen_count;
//    videomodel.title = tempVideos.title;
//    
//    postID = tempVideos.VideoID;
//    
//    ParentCommentID = @"-1";
//    [self GetCommnetsOnPost];
    /////////////////////////////////////////////////////////////
    
    UIButton *senderBtn = sender;
    senderBtn.enabled = false;
    CommentsArray = nil;
    //  commentsTable.hidden = NO;
    //  Cm_VideoPlay.hidden = NO;
    UIButton *CommentsBtn = (UIButton *)sender;
    currentSelectedIndex = CommentsBtn.tag;
    
    
    // [Cm_VideoPlay addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    // [Cm_VideoPlay setTag:currentSelectedIndex];
    UserChannelModel *_chmodel = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    VideoModel *_model = [[VideoModel alloc]init];
    [_model setTitle:_chmodel.title];
    [_model setUser_id:_chmodel.user_id];
    [_model setUserName:_chmodel.userName];
    [_model setVideoID:_chmodel.VideoID];
    [_model setProfile_image:_chmodel.profile_image];
    [_model setRating:_chmodel.rating];
    [_model setComments_count:_chmodel.comments_count];
    [_model setVideo_link:_chmodel.video_link];
    [_model setVideo_thumbnail_link:_chmodel.video_thumbnail_link];
    [_model setVideo_length:_chmodel.video_length];
    videomodel  = _model;
    postID = videomodel.videoID;
    appDelegate.currentMyCornerIndex = currentSelectedIndex;
    ParentCommentID = @"-1";
    CommentsVC *commentController ;
    if(IS_IPAD)
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    else
        commentController = [[CommentsVC alloc] initWithNibName:@"CommentsVC" bundle:nil];
    commentController.myprofile = appDelegate.myprofile;
    commentController.commentsObj   = Nil;
    commentController.postArray     = videomodel;
    commentController.cPostId       = postID;
    commentController.isFirstComment = TRUE;
    commentController.isComment     = FALSE;
    
    [[self navigationController] pushViewController:commentController animated:YES];
    
   
}
-(void)playVideo:(UIButton*)sender{
    
    UIButton *playBtn = (UIButton *)sender;
    currentSelectedIndex = playBtn.tag;
    [videoObj removeAllObjects];
    
    for(int i = 0; i < ChannelObj.trendingArray.count ; i++){
        UserChannelModel *model = [ChannelObj.trendingArray objectAtIndex:i];
        VideoModel *temp = [[VideoModel alloc] init];
        temp.is_anonymous           = model.is_anonymous;
        temp.title                  = model.title;
        temp.comments_count         = model.comments_count;
        temp.userName               = model.userName;
        temp.topic_id               = model.topic_id;
        temp.user_id                = model.user_id;
        temp.profile_image          = model.profile_image;
        temp.video_link             = model.video_link;
        temp.video_thumbnail_link   = model.video_thumbnail_link;
        temp.videoID                = model.VideoID;
        temp.video_length           = model.video_length;
        temp.like_count             = model.like_count;
        temp.like_by_me             = model.like_by_me;
        temp.seen_count             = model.seen_count;
        temp.reply_count            = model.reply_count;
        [videoObj addObject:temp];
    }
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
        if ( [(NSHTTPURLResponse *)response statusCode] == 200 )
        {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:@"Please try again later!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}
-(void) GetCommnetsOnPost{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_BY_PARENT_ID,@"method",
                              token,@"Session_token",@"1",@"page_no",@"-1",@"parent_id",postID,@"post_id", nil];
    
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
                commentController.postArray = videomodel;
                commentController.cPostId = postID;
                commentController.isFirstComment = YES;
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

- (IBAction)getFollowings:(id)sender {
    [FollowingsAM removeAllObjects];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"getFollowersFollowing",@"method",
                              token,@"session_token",@"1",@"page_no",ChannelObj.user_id,@"user_id",@"1",@"following",nil];
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
                
                for(NSDictionary *tempDict in FollowingsArray){
                    Followings *_responseData = [[Followings alloc] init];
                    
                    _responseData.f_id = [tempDict objectForKey:@"id"];
                    _responseData.fullName = [tempDict objectForKey:@"full_name"];
                    _responseData.is_celeb = [tempDict objectForKey:@"is_celeb"];
                    _responseData.profile_link = [tempDict objectForKey:@"profile_link"];
                    _responseData.status = [tempDict objectForKey:@"state"];
                    [FollowingsAM addObject:_responseData];
                }
                
                FriendsVC *commentController = [[FriendsVC alloc] initWithNibName:@"FriendsVC" bundle:nil];
                commentController.friendsArray = FollowingsAM;
                commentController.titles        = @"Followings";
                commentController.NoFriends     = FALSE;
                [[self navigationController] pushViewController:commentController animated:YES];
            }
        }
    }];
}

- (IBAction)getFollowers:(id)sender {
    [FollowingsAM removeAllObjects];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSString *userId = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"id"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"getFollowersFollowing",@"method",
                              token,@"session_token",@"1",@"page_no",ChannelObj.user_id,@"user_id",@"1",@"followers",nil];
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
                
                FriendsVC *commentController = [[FriendsVC alloc] initWithNibName:@"FriendsVC" bundle:nil];
                commentController.friendsArray = FollowingsAM;
                commentController.titles        = @"Followers";
                commentController.NoFriends     = FALSE;
                [[self navigationController] pushViewController:commentController animated:YES];
            }
        }
    }];
}




#pragma mark - IBButton Actions
- (IBAction)CancelEditBtn:(id)sender{
    _viewItems.hidden = YES;
}
-(IBAction)fbshareBtn:(id)sender
{
    //[editView setHidden:YES];
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
    //[editView setHidden:YES];
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


#pragma mark - IBButton Actions helper


- (IBAction)editBeam:(id)sender{
   // VideoModel *tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    NSString *postIDs = selectedVideo.VideoID;
    BeamUploadVC *uploadController = [[BeamUploadVC alloc] initWithNibName:@"BeamUploadVC" bundle:nil];
    uploadController.video_thumbnail = selectedVideo.video_thumbnail_link;
    uploadController.postID = postIDs;
    uploadController.caption = selectedVideo.title;
    uploadController.friendsArray = FollowingsAM;
    appDelegate.hasbeenEdited = TRUE;
    [[self navigationController] pushViewController:uploadController animated:YES];
}



- (IBAction)ReportBtn:(id)sender{
    
  //  VideoModel *tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    //NSString *postID = tempVideos.videoID;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //editView.hidden = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"reportPost",@"method",
                              token,@"session_token",selectedVideo.VideoID ,@"post_id",@"For No Reason",@"reason",nil];
    
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
    //[editView setHidden:YES];
    //VideoModel *tempVideos  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    NSString *postIDs = selectedVideo.VideoID;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *token = (NSString *)[[NSUserDefaults standardUserDefaults]objectForKey:@"session_token"];
    NSURL *url = [NSURL URLWithString:SERVER_URL];
    NSDictionary *postDict = [NSDictionary dictionaryWithObjectsAndKeys:@"deletePost",@"method",
                              token,@"session_token",postIDs,@"post_id",nil];
    
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
                [ChannelObj.trendingArray removeObjectAtIndex:currentSelectedIndex];
                [self->friendsChannelTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
               // NSInteger BeamsCount =  [userBeams.text integerValue];
               // BeamsCount--;
                //userBeams.text = [[NSString alloc]initWithFormat:@"%ld Beams",(long)BeamsCount];
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
   // editView.hidden = YES;
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

-(void)menuBtnPressed:(UIButton*)sender{
    //NSInteger selectedIndex;
    currentSelectedIndex = sender.tag ;
    selectedVideo  = [ChannelObj.trendingArray objectAtIndex:currentSelectedIndex];
    
    
    
    //User *user=userArray[index]; //userchannel
    
    
    
    _viewItems.hidden = false;
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

@end
