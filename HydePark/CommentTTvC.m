//
//  CommentTTvC.m
//  HydePark
//
//  Created by Apple Txlabz on 08/06/2016.
//  Copyright © 2016 TxLabz. All rights reserved.
//

#import "CommentTTvC.h"
#import "CommentViewCell.h"
@interface CommentTTvC ()

@end

@implementation CommentTTvC
#pragma mark - viewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tblView.dataSource = self;
    _tblView.delegate = self;
}
#pragma mark - IBButton Action

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //CommentsCell *cell;
    CommentViewCell *cell;
    if (IS_IPAD) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    else if(IS_IPHONE_5){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    else{
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
  
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    float tableHeight;
//    if(IS_IPHONE_5)
//        tableHeight = 150.0f;
//    else if (IS_IPAD)
//        tableHeight = 362.0f;
//    else
//        tableHeight = 180.0f;
    return 90;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return 4;

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
