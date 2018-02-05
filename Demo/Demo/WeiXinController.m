//
//  ImagesController.m
//  WRNetWrapper
//
//  Created by itwangrui on 2018/1/30.
//  Copyright © 2018年 itwangrui. All rights reserved.
//

#import "WeiXinController.h"
#import "WeiXinCell.h"
#import "WRNetwork.h"
#import <MJRefresh/MJRefresh.h>

@interface WeiXinController () <WRNetWrapperRequestDelegate>
@property (strong, nonatomic) IBOutlet UITableView *wxTableView;
@property (nonatomic, strong) WRNetWrapper *reqWXList;
@property (nonatomic, assign) int curPage;
@property (nonatomic, strong) NSMutableArray *wxList;
@end

@implementation WeiXinController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MJRefreshBackStateFooter *footer = [MJRefreshBackStateFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMore)];
    [footer setTitle:@"上拉查看更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"加载更多数据....." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"我是有底线的" forState:MJRefreshStateNoMoreData];
    self.tableView.mj_footer = footer;
    
    _wxList = [NSMutableArray new];
    self.tableView.rowHeight = 100;
    
    // ⚠️ 注意1，这里会立即发起请求！！！
    // ⚠️ 注意2，这里设置了缓存过期时间为 10 秒
    self.reqWXList = req_wx_list(_curPage, self);
}

- (void)loadMore {
    _curPage += 1;
    self.reqWXList = req_wx_list(_curPage, self);
}

- (IBAction)cancelRequest:(UIBarButtonItem *)sender {
    [WRNetWrapper cancelRequestWithURL:_reqWXList.requestURL];
}


#pragma mark - WRNetWrapperRequestDelegate
- (void)netWrapperRequestDidSuccess:(WRNetWrapper *)netWrapper
{
    if (netWrapper == _reqWXList) {
        NSDictionary *dict = netWrapper.data;
        [self handleResponse:dict];
        _reqWXList = nil;
    }
}
- (void)netWrapperRequestDidFailed:(WRNetWrapper *)netWrapper
{
    if (netWrapper == _reqWXList) {
        [self.tableView.mj_footer endRefreshing];
        _reqWXList = nil;
    }
}
- (void)netWrapperGetCacheDidFinished:(WRNetWrapper *)netWrapper
{
    NSDictionary *dict = netWrapper.cache;
    [self handleResponse:dict];
}

// 获取缓存 和 回调成功 都在这里处理
- (void)handleResponse:(NSDictionary *)dict {
    
    NSDictionary *result = dict[@"result"];
    NSArray *list = result[@"list"];
    if (list.count == 0) {
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.tableView.mj_footer endRefreshing];
    }
    if (list && list.count > 0) {
        [_wxList addObjectsFromArray:list];
    }
    [self.tableView reloadData];
}




#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wxList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeiXinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiXinCell"];
    NSDictionary *dict = self.wxList[indexPath.row];
    [cell setData:dict];
    return cell;
}

- (void)dealloc {
    NSLog(@"WeiXinController dealloc");
}

@end
