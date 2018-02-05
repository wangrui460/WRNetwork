//
//  WRBatchRequest.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import "WRMultiRequest.h"
#import "WRNetWrapper.h"

@interface WRMultiRequest () <WRNetWrapperRequestDelegate>
@property (nonatomic, strong) NSMutableArray<WRNetWrapper *> *requestArray;
@end

@implementation WRMultiRequest

- (instancetype)initWithRequestArray:(NSArray<WRNetWrapper *> *)requestArray delegate:(id)delegate {
    self = [super init];
    if (self) {
        _requestArray = [requestArray mutableCopy];
        _delegate = delegate;
    }
    return self;
}

- (void)loadRequests {
    if (!_requestArray || _requestArray <= 0) return;
    
    for (WRNetWrapper *req in _requestArray) {
        req.mulitDelegate = self;
        [req loadRequest];
    }
}

#pragma mark - WRNetWrapperRequestDelegate
- (void)netWrapperRequestDidSuccess:(WRNetWrapper *)netWrapper {
    [_requestArray removeObject:netWrapper];
    if (_requestArray.count == 0) {
        if ([_delegate respondsToSelector:@selector(multiRequestDidSuccess:)]) {
            [_delegate multiRequestDidSuccess:self];
        }
    }
}
- (void)netWrapperRequestDidFailed:(WRNetWrapper *)netWrapper {
    [self cancelAllRequest];
    if ([_delegate respondsToSelector:@selector(multiRequestDidFailed:)]) {
        [_delegate multiRequestDidFailed:self];
    }
}

- (void)cancelAllRequest {
    for (WRNetWrapper *req in _requestArray) {
        [req.sessionTask cancel];
    }
    _requestArray = nil;
}

- (void)dealloc {
    [self cancelAllRequest];
}

@end
