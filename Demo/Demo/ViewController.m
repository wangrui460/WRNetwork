//
//  ViewController.m
//  WRNetWrapper
//
//  Created by itwangrui on 2018/1/29.
//  Copyright © 2018年 itwangrui. All rights reserved.
//

#import "ViewController.h"
#import "WRNetwork.h"

@interface ViewController () <WRNetWrapperRequestDelegate, WRMultiRequestDelegate>

@property (nonatomic, strong) WRNetWrapper *reqTestA;
@property (nonatomic, strong) WRNetWrapper *reqTestB;
@property (nonatomic, strong) WRNetWrapper *reqTestC;
@property (nonatomic, strong) WRNetWrapper *reqTestD;
@property (nonatomic, strong) WRNetWrapper *reqTestE;
@property (nonatomic, strong) WRNetWrapper *reqTestF;

@property (nonatomic, strong) WRMultiRequest *multiReq;

@property (nonatomic, strong) NSMutableArray *testList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _testList = [NSMutableArray new];
}

- (IBAction)onClickButton:(UIButton *)sender {
    
    // ⚠️ 需要注意，这里不会立即发起请求
    _reqTestA = req_test_a(self);
    _reqTestB = req_test_b(self);
    _reqTestC = req_test_c(self);
    _reqTestD = req_test_d(self);
    _reqTestE = req_test_e(self);
    _reqTestF = req_test_f(self);
    
    // 生成多请求对象
    _multiReq = [[WRMultiRequest alloc] initWithRequestArray:@[_reqTestA,
                                                               _reqTestB,
                                                               _reqTestC,
                                                               _reqTestD,
                                                               _reqTestE,
                                                               _reqTestF]
                                                    delegate:self];
    // 立即发起请求
    [_multiReq loadRequests];
}


#pragma mark - WRNetWrapperRequestDelegate
- (void)netWrapperRequestDidSuccess:(WRNetWrapper *)netWrapper {
    // 如果想知道具体是哪个请求，可以将请求对象作为 viewDidLoad 的一个属性，然后在这里和 netWrapper 进行比较
    // 这里只是作为demo，我就不做保护了
    NSDictionary *dict = netWrapper.data;
    NSDictionary *result = dict[@"result"];
    NSArray *list = result[@"list"];
    [_testList addObjectsFromArray:list];
}
- (void)netWrapperRequestDidFailed:(WRNetWrapper *)netWrapper {
    NSLog(@"网络请求出错了~~~");
}
- (void)netWrapperGetCacheDidFinished:(WRNetWrapper *)netWrapper {
    NSDictionary *dict = netWrapper.data;
    NSDictionary *result = dict[@"result"];
    NSArray *list = result[@"list"];
    [_testList addObjectsFromArray:list];
}

#pragma mark - WRMultiRequestDelegate
- (void)multiRequestDidSuccess:(WRMultiRequest *)multiRequest {
    NSLog(@"批量请求全部完成~");
}
- (void)multiRequestDidFailed:(WRMultiRequest *)multiRequest {
    NSLog(@"批量请求出错~");
}


- (IBAction)clear:(UIBarButtonItem *)sender {
    [WRCache removeAllCache];
}
















-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    
}

@end
