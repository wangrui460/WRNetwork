## WRNetwork

WRNetwork 是基于 AFNetworking 封装的一套网络请求框架。


## 功能

- [x] 支持 文件上传和下载
- [x] 支持 GET / POST / DELETE / PUT / HEAD / PATCH 六种请求方式
- [x] 支持 block 和 代理 两种回调请求方式
- [x] 支持 网络请求结果缓存
- [x] 支持 分页请求数据缓存
- [x] 支持 添加缓存过期时间
- [x] 支持 批量请求数据


## 推荐
<img src="https://github.com/wangrui460/WRNetwork/raw/master/screenshots/WRApis.png" alt="">


## 使用

推荐使用方式请看文件 WRApis.h/m

发起网络请求
<pre><code>
self.reqWXList = req_wx_list(_curPage, self);
</code></pre>

请求 成功 / 失败 / 获取缓存 回调
<pre><code>
#pragma mark - WRNetWrapperRequestDelegate
- (void)netWrapperRequestDidSuccess:(WRNetWrapper *)netWrapper {
    if (netWrapper == _reqWXList) {
        NSDictionary *dict = netWrapper.data;
        [self handleResponse:dict];
        _reqWXList = nil;
    }
}

- (void)netWrapperRequestDidFailed:(WRNetWrapper *)netWrapper {
    if (netWrapper == _reqWXList) {
        [self.tableView.mj_footer endRefreshing];
        _reqWXList = nil;
    }
}

- (void)netWrapperGetCacheDidFinished:(WRNetWrapper *)netWrapper {
    NSDictionary *dict = netWrapper.cache;
    [self handleResponse:dict];
}
</code></pre>

批量网络请求使用方式
<pre><code>
// ⚠️ 需要注意，这里不会立即发起请求（实现方式请看WRApis.m）
_reqTestA = req_test_a(self);
_reqTestB = req_test_b(self);
_reqTestC = req_test_c(self);
_reqTestD = req_test_d(self);
_reqTestE = req_test_e(self);
_reqTestF = req_test_f(self);

// 生成多请求对象
_multiReq = [[WRMultiRequest alloc] initWithRequestArray:@[_reqTestA,_reqTestB,_reqTestC,_reqTestD,_reqTestE,_reqTestF]
                                                delegate:self];
// 立即发起请求
[_multiReq loadRequests];
</code></pre>

批量请求 成功 / 失败 回调
<pre><code>
#pragma mark - WRMultiRequestDelegate
- (void)multiRequestDidSuccess:(WRMultiRequest *)multiRequest {
    NSLog(@"批量请求全部完成~");
}

- (void)multiRequestDidFailed:(WRMultiRequest *)multiRequest {
    NSLog(@"批量请求出错~");
}
</code></pre>


当然你也可以使用 block 的方式
<pre><code>
- (WRNetWrapper *)requestWithURL:(NSString *)urlStr
                      parameters:(NSDictionary *)parameters
                      httpMethod:(WRNetWrapperHTTPMethod)httpMethod
                         isCache:(BOOL)isCache
                       cacheTime:(NSTimeInterval)cacheTime
                           cache:(WRNetWrapperGetCacheBlock)cache
                         success:(WRNetWrapperRequestDidSuccessBlock)success
                         failure:(WRNetWrapperRequestDidFailedBlock)failure;
</code></pre>

上传文件
<pre><code>
+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)urlStr
                                  parameters:(id)parameters
                                        name:(NSString *)name
                                    filePath:(NSString *)filePath
                                    progress:(WRNetWrapperProgress)progress
                                     success:(WRNetWrapperRequestDidSuccessBlock)success
                                     failure:(WRNetWrapperRequestDidFailedBlock)failure;
</code></pre>

下载文件
<pre><code>
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)urlStr
                                       fileDir:(NSString *)fileDir
                                      progress:(WRNetWrapperProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(WRNetWrapperRequestDidFailedBlock)failure;
</code></pre>


## 安装

将 WRNetwork 文件夹拽入项目中，导入头文件：#import "WRNetwork.h"


## 协议

WRNetwork 被许可在 MIT 协议下使用



