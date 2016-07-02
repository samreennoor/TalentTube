//
//  BeamUploadVC.m
//  HydePark
//
//  Created by Apple on 21/03/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "BeamUploadVC.h"
#import "ASIFormDataRequest.h"
#import "Utils.h"
#import <AudioToolbox/AudioServices.h>
#import "CommentsModel.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Alert.h"
#import "HomeVC.h"
#import "WDUploadProgressView.h"

@interface BeamUploadVC ()
{
    Alert *alert;
    NSString *textToshare;
}

@end
@implementation BeamUploadVC
@synthesize dataToUpload,isAnonymous,isAudio,thumbnailImage,profileData,postID,ParentCommentID,video_duration,video_thumbnail,isComment,caption,friendsArray;
-(id)initWithDelegate:(id<WDClientUploadDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        // Start a background process to update the upload view
        // [self startUploadProgress:uploadingProgress];
    }
    return self;
}
- (void)startUploadProgress:(float)progress
{
    //[self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:0.1];
    
    //    [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:1];
    //
    //    [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:2];
    //
    //    [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:3];
    //
    //    [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:4];
    //
    //    [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:8];
}

- (void)setUploadProgress:(NSNumber *)progress
{
    [self.delegate uploadDidUpdate:[progress floatValue]];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    apDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    finalArray = [[NSMutableArray alloc] init];
    normalAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(145,151,163) forKey:NSForegroundColorAttributeName];
    highlightAttrdict = [NSDictionary dictionaryWithObject:BlueThemeColor(54,78,141) forKey:NSForegroundColorAttributeName ];
    tepper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(keyboardEnd:)];
    tepper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tepper];
    if(IS_IPHONE_5)
        [_uploadbeamScroller setContentSize:CGSizeMake(320,500)];
    else if (IS_IPHONE_6)
        [_uploadbeamScroller setContentSize:CGSizeMake(375,580)];
    else if (IS_IPHONE_6Plus)
        [_uploadbeamScroller setContentSize:CGSizeMake(375,600)];
    else if(IS_IPAD)
    {
        upperView.frame = CGRectMake(0, 0, 768, 86);
        //        frameBeamscroller = _uploadbeamScroller.frame;
        //        frameBeamscroller.origin.y += 86;
        //        _uploadbeamScroller.frame = frameBeamscroller;
    }
    if (thumbnailImage != nil) {
        _thumbnailImageView.image = thumbnailImage;

    }
    else
    {
        
        _thumbnailImageView.imageURL = [NSURL URLWithString:video_thumbnail];
    NSURL *url = [NSURL URLWithString:video_thumbnail];
    [[AsyncImageLoader sharedLoader] loadImageWithURL:url];
    }

    textToshare = @"Your thoughts...";
    if(appDelegate.hasbeenEdited)
    {
        NSURL *url = [NSURL URLWithString:[video_thumbnail stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self downloadImageWithURL:url completionBlock:^(BOOL succeeded, UIImage *image) {
            if (succeeded) {
                _thumbnailImageView.image = image;
            }
        }];
         textToshare = caption;
    }
   

   // AutocompleteHandle *_text = [[AutocompleteHandle alloc] initWithFrame:_textView.frame backgroundColor:[UIColor whiteColor] textToDisp:textToshare];
    //_text.delegate = self;
   // [self.uploadbeamScroller addSubview:_text];
   // _text.delegate = self;
    IS_mute = @"NO";
    _statusText.delegate = self;
    _statusText.text = textToshare;
    usersName = [NSMutableArray array];
    usersId = [NSMutableArray array];
    for (NSDictionary *dict in friendsArray) {
        [usersName addObject:[dict objectForKey:@"full_name"]];
        [usersId   addObject:[dict objectForKey:@"id"]];
    }
   // [_text setUserNames:usersName];
   
    commentAllowed = @"-1";
    privacySelected = @"PUBLIC";
    tagsString = @"";
    
    if(isAnonymous)
        is_Anonymous = @"1";
    else
        is_Anonymous = @"0";
    if(isAudio)
        _thumbnailImageView.image = [UIImage imageNamed: @"splash_audio_image.png"];
    
    appDelegate.latestVideoAdded = false;
    [self PrivacyEveryOne:nil];
    [self UnlimitedPressed:nil];
}
- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"textViewDidChange");
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    NSLog(@"textViewDidChangeSelection");
}

-(void)autocompleteHandleSelectedHandle:(NSString *)handle {
    NSLog(@"autocompleteHandleSelectedHandle:%@", handle);
    NSInteger index =  [usersName indexOfObject:handle];
    [finalArray addObject:[usersId objectAtIndex:index]];
}

-(void)autocompleteHandleHeightDidChange:(CGFloat)height {
    NSLog(@"autocompleteHandleHeightDidChange:%f", height);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    //    const int movementDistance = 145; // tweak as needed
    //    const float movementDuration = 0.3f; // tweak as needed
    //
    //    int movement = (up ? -movementDistance : movementDistance);
    //
    //    [UIView beginAnimations: @"anim" context: nil];
    //    [UIView setAnimationBeginsFromCurrentState: YES];
    //    [UIView setAnimationDuration: movementDuration];
    //    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    //    [UIView commitAnimations];
}
- (void)keyboardEnd:(UITapGestureRecognizer *) sender
{
    //[self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TextView Delegates
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    textToshare = _statusText.text;

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

//-(void) textViewDidChange:(UITextView *)textView
//{
//    if(_statusText.text.length == 0){
//        [_statusText resignFirstResponder];
//    }
//}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
   // [self extractTags];
    textToshare = _statusText.text;
    [_statusText resignFirstResponder];
    return YES;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
}
- (IBAction)uploadBeamPressed:(id)sender{
    if(!apDelegate.hasbeenEdited){
        if(isAudio && !isComment)
            [self uploadAduio:dataToUpload];
        else if(isComment && !isAudio)
            [self uploadComment:dataToUpload];
        else if (isComment && isAudio)
            [self uploadAudioComment:dataToUpload];
        else
            [self uploadBeam:dataToUpload];
    }
    else{
        appDelegate.hasbeenEdited = FALSE;
        [self editUploadedBeam];
    }
    appDelegate.navigationControllersCount = self.navigationController.viewControllers.count-2;
    [self.navigationController popViewControllerAnimated:YES];
    //[self.view addSubview:blockerView];
    
}
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                                   //rewardsiconimgview.image = [UIImage imageNamed:@"rewardsicon.png"];
                               }
                           }];
}
-(void) editUploadedBeam{
    //[SVProgressHUD showWithStatus:@"Saving Changes"];
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    
    if([textToshare isEqualToString:@"Your thoughts..."] || textToshare.length == 0)
        textToshare = @"";
    NSString *tag_string;
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"editPost",@"method",
                              userSession,@"Session_token",commentAllowed,@"reply_count",textToshare,
                              @"caption",@"0",@"is_anonymous",@"0",@"mute",postID,@"post_id",@"-1",
                              @"parent_comment_id",privacySelected,@"privacy",@"COLOUR",@"filter",nil];
    if(finalArray == nil || [finalArray count] == 0){
        
    }
    else
    {
        tag_string = [finalArray componentsJoinedByString:@","];
        [postDict setObject:tag_string forKey:@"tag_friends"];
    }
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:SERVER_URL parameters:postDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [responseObject objectForKey:@"post_data"];
        VideoModel *_Videos = [[VideoModel alloc] init];
        _Videos.title             = [dict objectForKey:@"caption"];
        _Videos.comments_count    = [dict objectForKey:@"comment_count"];
        _Videos.userName          = [dict objectForKey:@"full_name"];
        _Videos.topic_id          = [dict objectForKey:@"topic_id"];
        _Videos.user_id           = [dict objectForKey:@"user_id"];
        _Videos.profile_image     = [dict objectForKey:@"profile_link"];
        _Videos.like_count        = [dict objectForKey:@"like_count"];
        _Videos.like_by_me        = [dict objectForKey:@"liked_by_me"];
        _Videos.seen_count        = [dict objectForKey:@"seen_count"];
        _Videos.video_angle       = [[dict objectForKey:@"video_angle"] intValue];
        _Videos.video_link        = [dict objectForKey:@"video_link"];
        _Videos.video_thumbnail_link = [dict objectForKey:@"video_thumbnail_link"];
        _Videos.videoID           = [dict objectForKey:@"id"];
        _Videos.Tags              = [dict objectForKey:@"tag_friends"];
        _Videos.video_length      = [dict objectForKey:@"video_length"];
        _Videos.is_anonymous      = [dict objectForKey:@"is_anonymous"];
        _Videos.reply_count       = [dict objectForKey:@"reply_count"];
        appDelegate.videObj = _Videos;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GetChannelAgain"
         object:nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"updateMyArchive"
         object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error: %@", error);
    }];
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

-(void) uploadBeam :(NSData*)file {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowProgress"
     object:nil];
    NSString *anony = (isAnonymous) ? @"1" : @"0";
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
 
    if([textToshare isEqualToString:@"Your thoughts..."] || textToshare.length == 0)
        textToshare = @"";
    NSString *tag_string;
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:METHOD_UPLOAD_STATUS,@"method",userSession,@"Session_token",commentAllowed,@"reply_count",textToshare,@"caption",anony,@"is_anonymous",@"0",@"mute",video_duration,@"video_length",postID,@"post_id",ParentCommentID,@"parent_comment_id",privacySelected,@"privacy",nil];
    if(finalArray == nil || [finalArray count] == 0){
        
    }
    else
    {
        tag_string = [finalArray componentsJoinedByString:@","];
        [postDict setObject:tag_string forKey:@"tag_friends"];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_URL parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:file name:@"video_link" fileName:[NSString stringWithFormat:@"%@.mp4",@"video"] mimeType:@"recording/video"];
        [formData appendPartWithFileData:profileData name:@"video_thumbnail_link" fileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] mimeType:@"image/png"];
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //[SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Loading"];
                          uploadingProgress = uploadProgress.fractionCompleted;
                          apDelegate.progressFloat = uploadingProgress;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateProgress"
                           object:nil];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                      } else {
                          //[SVProgressHUD dismiss];
                          
                          NSDictionary *dict = [responseObject objectForKey:@"post"];
                          VideoModel *_Videos = [[VideoModel alloc] init];
                          _Videos.title             = [dict objectForKey:@"caption"];
                          _Videos.comments_count    = [dict objectForKey:@"comment_count"];
                          _Videos.userName          = [dict objectForKey:@"full_name"];
                          _Videos.topic_id          = [dict objectForKey:@"topic_id"];
                          _Videos.user_id           = [dict objectForKey:@"user_id"];
                          _Videos.profile_image     = [dict objectForKey:@"profile_link"];
                          _Videos.like_count        = [dict objectForKey:@"like_count"];
                          _Videos.like_by_me        = [dict objectForKey:@"liked_by_me"];
                          _Videos.seen_count        = [dict objectForKey:@"seen_count"];
                          _Videos.video_angle       = [[dict objectForKey:@"video_angle"] intValue];
                          _Videos.video_link        = [dict objectForKey:@"video_link"];
                          _Videos.video_thumbnail_link = [dict objectForKey:@"video_thumbnail_link"];
                          _Videos.videoID           = [dict objectForKey:@"id"];
                          _Videos.Tags              = [dict objectForKey:@"tag_friends"];
                          _Videos.video_length      = [dict objectForKey:@"video_length"];
                          _Videos.is_anonymous      = [dict objectForKey:@"is_anonymous"];
                          _Videos.reply_count       = [dict objectForKey:@"reply_count"];
                          appDelegate.videObj = _Videos;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateMyCornerArray"
                           object:nil];
                          [self showAlert];
                      }
                  }];
    [uploadTask resume];
    
}
-(void) uploadComment:(NSData*)file{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowProgressComments"
     object:nil];
        NSString *anony = (isAnonymous) ? @"1" : @"0";
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    if([textToshare isEqualToString:@"Your thoughts..."]|| textToshare.length == 0)
        textToshare = @"";
    NSString *tag_string;

    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_POST,@"method",userSession,@"Session_token",commentAllowed,@"reply_count",textToshare,@"caption",anony,@"is_anonymous",@"0",@"mute",video_duration,@"video_length",postID,@"post_id",ParentCommentID,@"parent_comment_id",privacySelected,@"privacy",@"90",@"video_angle",@"COLOUR",@"filter",nil];
    if(finalArray == nil || [finalArray count] == 0){
        
    }
    else
    {
        tag_string = [finalArray componentsJoinedByString:@","];
        [postDict setObject:tag_string forKey:@"tag_friends"];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_URL parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:file name:@"video_link" fileName:[NSString stringWithFormat:@"%@.mp4",@"video"] mimeType:@"recording/video"];
        [formData appendPartWithFileData:profileData name:@"video_thumbnail_link" fileName:[NSString stringWithFormat:@"%@.png",@"thumbnail"] mimeType:@"image/png"];
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //[SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Loading"];
                          uploadingProgress = uploadProgress.fractionCompleted;
                          apDelegate.progressFloat = uploadingProgress;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateProgressComments"
                           object:nil];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                      } else {
                          //[SVProgressHUD dismiss];
                          
                          CommentsModel *_comment = [[CommentsModel alloc] init];
                          NSArray *post = [responseObject objectForKey:@"coment"];
                          
                          for(int i=0;i<post.count; i++) {
                              
                              NSDictionary *tempDixt = [post objectAtIndex:i];
                              
                              _comment.title = [tempDixt objectForKey:@"caption"];
                              _comment.comments_count = [tempDixt objectForKey:@"comment_count"];
                              _comment.comment_like_count = [tempDixt objectForKey:@"like_count"];
                              _comment.userName = [tempDixt objectForKey:@"full_name"];
                              _comment.topic_id = [tempDixt objectForKey:@"topic_id"];
                              _comment.user_id = [tempDixt objectForKey:@"user_id"];
                              _comment.profile_link = [tempDixt objectForKey:@"profile_link"];
                              _comment.liked_by_me = [tempDixt objectForKey:@"liked_by_me"];
                              _comment.mute = [tempDixt objectForKey:@"mute"];
                              _comment.video_link = [tempDixt objectForKey:@"video_link"];
                              _comment.video_thumbnail_link = [tempDixt objectForKey:@"video_thumbnail_link"];
                              _comment.image_link = [tempDixt objectForKey:@"image_link"];
                              _comment.VideoID = [tempDixt objectForKey:@"id"];
                              _comment.video_length = [tempDixt objectForKey:@"video_length"];
                              _comment.timestamp = [tempDixt objectForKey:@"timestamp"];
                              _comment.is_anonymous = [tempDixt objectForKey:@"is_anonymous"];
                              _comment.seen_count = [tempDixt objectForKey:@"seen_count"];
                              _comment.reply_count = [tempDixt objectForKey:@"reply_count"];
                              _comment.isMute   = [tempDixt objectForKey:@"mute"];
                              appDelegate.commentObj = _comment;
                              appDelegate.hasBeenUpdated = true;
                              appDelegate.timeToupdateHome = TRUE;
                              break;
                          }
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateCommentsArray"
                           object:nil];
                          [self showAlert];
                      }
                  }];
    [uploadTask resume];
}


-(void) uploadAudioComment:(NSData*)file{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowProgressComments"
     object:nil];
     NSString *anony = (isAnonymous) ? @"1" : @"0";
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    if([textToshare isEqualToString:@"Your thoughts..."]|| textToshare.length == 0)
        textToshare = @"";
    NSString *tag_string;
    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:METHOD_COMMENTS_POST,@"method",userSession,@"Session_token",commentAllowed,@"reply_count",textToshare,@"caption",anony,@"is_anonymous",@"0",@"mute",video_duration,@"video_length",postID,@"post_id",ParentCommentID,@"parent_comment_id",privacySelected,@"privacy",@"COLOUR",@"filter",nil];
    if(finalArray == nil || [finalArray count] == 0){
        
    }
    else
    {
        tag_string = [finalArray componentsJoinedByString:@","];
        [postDict setObject:tag_string forKey:@"tag_friends"];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_URL parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:file name:@"audio_link" fileName:[NSString stringWithFormat:@"%@.wav",@"sound"] mimeType:@"audio/wav"];
        
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          //[SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Loading"];
                          uploadingProgress = uploadProgress.fractionCompleted;
                          apDelegate.progressFloat = uploadingProgress;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateProgressComments"
                           object:nil];
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                      } else {
                          //[SVProgressHUD dismiss];
                          
                          CommentsModel *_comment = [[CommentsModel alloc] init];
                          NSArray *post = [responseObject objectForKey:@"coment"];
                          
                          for(int i=0;i<post.count; i++) {
                              
                              NSDictionary *tempDixt = [post objectAtIndex:i];
                              
                              _comment.title = [tempDixt objectForKey:@"caption"];
                              _comment.comments_count = [tempDixt objectForKey:@"comment_count"];
                              _comment.comment_like_count = [tempDixt objectForKey:@"like_count"];
                              _comment.userName = [tempDixt objectForKey:@"full_name"];
                              _comment.topic_id = [tempDixt objectForKey:@"topic_id"];
                              _comment.user_id = [tempDixt objectForKey:@"user_id"];
                              _comment.profile_link = [tempDixt objectForKey:@"profile_link"];
                              _comment.liked_by_me = [tempDixt objectForKey:@"liked_by_me"];
                              _comment.mute = [tempDixt objectForKey:@"mute"];
                              _comment.video_link = [tempDixt objectForKey:@"video_link"];
                              _comment.video_thumbnail_link = [tempDixt objectForKey:@"video_thumbnail_link"];
                              _comment.image_link = [tempDixt objectForKey:@"image_link"];
                              _comment.VideoID = [tempDixt objectForKey:@"id"];
                              _comment.video_length = [tempDixt objectForKey:@"video_length"];
                              _comment.timestamp = [tempDixt objectForKey:@"timestamp"];
                              _comment.is_anonymous = [tempDixt objectForKey:@"is_anonymous"];
                              _comment.seen_count = [tempDixt objectForKey:@"seen_count"];
                              _comment.reply_count = [tempDixt objectForKey:@"reply_count"];
                              _comment.isMute      = [tempDixt objectForKey:@"mute"];
                              appDelegate.commentObj = _comment;
                              appDelegate.hasBeenUpdated = true;
                              appDelegate.timeToupdateHome = TRUE;
                              break;
                          }
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateCommentsArray"
                           object:nil];
                          [self showAlert];
                      }
                  }];
    [uploadTask resume];
}
-(void) uploadAduio:(NSData*)file{
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ShowProgress"
     object:nil];
     NSString *anony = (isAnonymous) ? @"1" : @"0";
    NSString *userSession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_token"];
    if([textToshare isEqualToString:@"Your thoughts..."] || textToshare == nil)
        textToshare = @"";
    NSString *tag_string;

    NSMutableDictionary *postDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:METHOD_UPLOAD_STATUS,@"method",userSession,@"Session_token",commentAllowed,@"reply_count",textToshare,@"caption",anony,@"is_anonymous",@"0",@"mute",video_duration,@"video_length",postID,@"post_id",ParentCommentID,@"parent_comment_id",privacySelected,@"privacy",nil];
    if(finalArray == nil || [finalArray count] == 0){
        
    }
    else
    {
        tag_string = [finalArray componentsJoinedByString:@","];
        [postDict setObject:tag_string forKey:@"tag_friends"];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_URL parameters:postDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:file name:@"audio_link" fileName:[NSString stringWithFormat:@"%@.wav",@"sound"] mimeType:@"audio/wav"];
        
    } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      // This is not called back on the main queue.
                      // You are responsible for dispatching to the main queue for UI updates
                      dispatch_async(dispatch_get_main_queue(), ^{
                          //Update the progress view
                          // [SVProgressHUD showProgress:uploadProgress.fractionCompleted status:@"Loading"];
                          //uploadingProgress = [NSNumber numberWithFloat:uploadProgress.fractionCompleted];
                          uploadingProgress = uploadProgress.fractionCompleted;
                          // [self setUploadProgress:[NSNumber numberWithFloat:uploadProgress.fractionCompleted]];
                          apDelegate.progressFloat = uploadingProgress;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateProgress"
                           object:nil];
                          //                         [self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress]];
                          //
                          //[juggad uploadDidUpdate:uploadingProgress];
                          //[self.delegate uploadDidUpdate:uploadingProgress];
                          //[self performSelector:@selector(setUploadProgress:) withObject:[NSNumber numberWithFloat:uploadingProgress] afterDelay:0.1];
                          
                      });
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                      } else {
                          NSDictionary *dict = [responseObject objectForKey:@"post"];
                          VideoModel *_Videos = [[VideoModel alloc] init];
                          _Videos.title             = [dict objectForKey:@"caption"];
                          _Videos.comments_count    = [dict objectForKey:@"comment_count"];
                          _Videos.userName          = [dict objectForKey:@"full_name"];
                          _Videos.topic_id          = [dict objectForKey:@"topic_id"];
                          _Videos.user_id           = [dict objectForKey:@"user_id"];
                          _Videos.profile_image     = [dict objectForKey:@"profile_link"];
                          _Videos.like_count        = [dict objectForKey:@"like_count"];
                          _Videos.like_by_me        = [dict objectForKey:@"liked_by_me"];
                          _Videos.seen_count        = [dict objectForKey:@"seen_count"];
                          _Videos.video_angle       = [[dict objectForKey:@"video_angle"] intValue];
                          _Videos.video_link        = [dict objectForKey:@"video_link"];
                          _Videos.video_thumbnail_link = [dict objectForKey:@"video_thumbnail_link"];
                          _Videos.videoID           = [dict objectForKey:@"id"];
                          _Videos.Tags              = [dict objectForKey:@"tag_friends"];
                          _Videos.video_length      = [dict objectForKey:@"video_length"];
                          _Videos.is_anonymous      = [dict objectForKey:@"is_anonymous"];
                          _Videos.reply_count       = [dict objectForKey:@"reply_count"];
                          appDelegate.videObj = _Videos;
                          [[NSNotificationCenter defaultCenter]
                           postNotificationName:@"updateMyCornerArray"
                           object:nil];
                          [self showAlert];
                      }
                  }];
    [uploadTask resume];
}

-(void)uploadProgressBar:(float )progressTillNow{
    [self.delegate uploadDidUpdate:progressTillNow];
}
-(void) showAlert{
    alert = [[Alert alloc] initWithTitle:@"Post has been uploaded" duration:(float)2.0f completion:^{
        //
    }];
    [alert setDelegate:self];
    [alert setShowStatusBar:YES];
    [alert setAlertType:AlertTypeSuccess];
    [alert setIncomingTransition:AlertIncomingTransitionTypeSlideFromTop];
    [alert setOutgoingTransition:AlertOutgoingTransitionTypeSlideToTop];
    [alert setBounces:YES];
    [alert showAlert];
}
- (IBAction)uploadBeamBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)PrivacyEveryOne:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"blueradio.png"]];
    [cponlyme setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"greyradio.png"] ];
    everyOnelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor darkGrayColor];
    Friendslbl.textColor = [UIColor darkGrayColor];
    privacySelected = @"PUBLIC";
    
}

- (IBAction)PrivacyOnlyMe:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cponlyme setImage:[UIImage imageNamed:@"blueradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"greyradio.png"] ];
    onlyMelbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    everyOnelbl.textColor = [UIColor darkGrayColor];
    Friendslbl.textColor = [UIColor darkGrayColor];
    privacySelected = @"PRIVATE";
}

- (IBAction)PrivacyFriends:(id)sender {
    [cpeveryone setImage:[UIImage imageNamed:@"greyradio.png"] ];
    [cponlyme setImage:[UIImage imageNamed:@"greyradio.png"]];
    [cpfriends setImage:[UIImage imageNamed:@"blueradio.png"]];
    Friendslbl.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    onlyMelbl.textColor = [UIColor darkGrayColor];
    everyOnelbl.textColor = [UIColor darkGrayColor];
    privacySelected = @"FRIENDS";
}

- (IBAction)upto60Pressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"blueradio.png"]];
    [noreply setImage:[UIImage imageNamed:@"greyradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"greyradio.png"] ];
    upto60.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor darkGrayColor];
    noreplies.textColor = [UIColor darkGrayColor];
    commentAllowed = @"50";
    
}

- (IBAction)noRepliesPressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"greyradio.png"]];
    [noreply setImage:[UIImage imageNamed:@"blueradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"greyradio.png"] ];
    noreplies.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    Unlimited.textColor = [UIColor darkGrayColor];
    upto60.textColor = [UIColor darkGrayColor];
    commentAllowed = @"0";
}

- (IBAction)UnlimitedPressed:(id)sender {
    [up60 setImage:[UIImage imageNamed:@"greyradio.png"] ];
    [noreply setImage:[UIImage imageNamed:@"greyradio.png"]];
    [unlimited setImage:[UIImage imageNamed:@"blueradio.png"]];
    Unlimited.textColor = [UIColor colorWithRed:54.0/256.0 green:78.0/256.0 blue:141.0/256.0 alpha:1.0];
    upto60.textColor = [UIColor darkGrayColor];
    noreplies.textColor = [UIColor darkGrayColor];
    commentAllowed = @"-1";
}
#pragma mark ASI delegates
- (void)request:(ASIHTTPRequest *)request incrementUploadSizeBy:(long long)newLength {
    //    NSLog(@"data length: %lld", newLength);
    //
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    //[self.navigationController popViewControllerAnimated:NO];
}

//- (void)requestFailed:(ASIHTTPRequest *)theRequest {
//    [SVProgressHUD dismiss];
//    [blockerView removeFromSuperview];
//    NSString *response = [[NSString alloc] initWithData:[theRequest responseData] encoding:NSUTF8StringEncoding];
//    //    NSLog(@"This is respone ::: %@",response);
//    [self.navigationController popViewControllerAnimated:NO];
//}
#pragma mark Delegate Methods

- (void)alertWillAppear:(Alert *)alert {
    
}

- (void)alertDidAppear:(Alert *)alert {
    
}

- (void)alertWillDisappear:(Alert *)alert {
    
}

- (void)alertDidDisappear:(Alert *)alert {
    
}

@end
