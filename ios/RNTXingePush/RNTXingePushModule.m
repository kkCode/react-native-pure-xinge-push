
#import "RNTXingePushModule.h"
#import <React/RCTUtils.h>

static NSString *XingePushEvent_Start = @"start";
static NSString *XingePushEvent_Stop = @"stop";
static NSString *XingePushEvent_Resgiter = @"register";

static NSString *XingePushEvent_BindAccount = @"bindAccount";
static NSString *XingePushEvent_BindTag = @"bindTag";
static NSString *XingePushEvent_UnbindAccount = @"unbindAccount";
static NSString *XingePushEvent_UnbindTag = @"unbindTag";

static NSString *XingePushEvent_LaunchNotification = @"launchNotification";
static NSString *XingePushEvent_Notification = @"notification";

@implementation RNTXingePushModule

// 在主工程 AppDelegate.m 里调下面几个 did 开头的方法

// didFinishLaunchingWithOptions return YES 之前调用
+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 为了更好的了解每一条推送消息的运营效果，需要将用户对消息的行为上报
    [[XGPush defaultManager] reportXGNotificationInfo:launchOptions];
    // 点击推送启动 App
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
    }
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

// 信鸽服务启动的回调
- (void)xgPushDidFinishStart:(BOOL)isSuccess error:(NSError *)error {
    [self sendEventWithName:XingePushEvent_Start body:@{
                                                              @"error": isSuccess ? @"" : error ?: @""
                                                              }];
}

// 信鸽服务停止的回调
- (void)xgPushDidFinishStop:(BOOL)isSuccess error:(NSError *)error {
    [self sendEventWithName:XingePushEvent_Stop body:@{
                                                              @"error": isSuccess ? @"" : error ?: @""
                                                              }];
}

// 启动信鸽服务成功后，会触发此回调
- (void)xgPushDidRegisteredDeviceToken:(NSString *)deviceToken error:(NSError *)error {
    [self sendEventWithName:XingePushEvent_Resgiter body:@{
                                                           @"deviceToken": deviceToken ?: @"",
                                                           @"error": error ?: @""
                                                           }];
}

// 绑定帐号或标签的回调
- (void)xgPushDidBindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSString *name = type == XGPushTokenBindTypeAccount ? XingePushEvent_BindAccount : XingePushEvent_BindTag;
    [self sendEventWithName:name body:@{
                                        @"error": error ?: @""
                                        }];
}

// 解除绑定帐号或标签的回调
- (void)xgPushDidUnbindWithIdentifier:(NSString *)identifier type:(XGPushTokenBindType)type error:(NSError *)error {
    NSString *name = type == XGPushTokenBindTypeAccount ? XingePushEvent_UnbindAccount : XingePushEvent_UnbindTag;
    [self sendEventWithName:name body:@{
                                        @"error": error ?: @""
                                        }];
}

// iOS 10 新增 API
// iOS 10 会走新 API, iOS 10 以前会走到老 API
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// App 用户点击通知
// App 用户选择通知中的行为
// App 用户在通知中心清除消息
// 无论本地推送还是远程推送都会走这个回调
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center
      didReceiveNotificationResponse:(UNNotificationResponse *)response
               withCompletionHandler:(void (^)(void))completionHandler __IOS_AVAILABLE(10.0) {
    
    UNNotification *notification = response.notification;
    
    // userInfo 包含了推送信息
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    UIApplicationState state = [RCTSharedApplication() applicationState];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    dict[@"clicked"] = @YES;
    dict[@"background"] = state != UIApplicationStateActive ? @YES : @NO;
    
    [self sendEventWithName:XingePushEvent_Notification body:dict];
    
    [[XGPush defaultManager] reportXGNotificationResponse:response];
    completionHandler();
}

// App 在前台弹通知需要调用这个接口
- (void)xgPushUserNotificationCenter:(UNUserNotificationCenter *)center
             willPresentNotification:(UNNotification *)notification
               withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler __IOS_AVAILABLE(10.0) {
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[XGPush defaultManager] reportXGNotificationInfo:userInfo];
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

#endif


RCT_EXPORT_MODULE(RNTXingePush);

- (NSArray<NSString *> *)supportedEvents
{
    return @[
        XingePushEvent_Start,
        XingePushEvent_Stop,
        XingePushEvent_Resgiter,
        XingePushEvent_BindAccount,
        XingePushEvent_BindTag,
        XingePushEvent_UnbindAccount,
        XingePushEvent_UnbindTag,
        XingePushEvent_LaunchNotification,
        XingePushEvent_Notification
        ];
}

RCT_EXPORT_METHOD(start:(NSInteger)appID appKey:(NSString *)appKey) {
    [[XGPush defaultManager]startXGWithAppID:(uint32_t)appID appKey:appKey delegate:self];
    [XGPushTokenManager defaultTokenManager].delegate = self;
}

RCT_EXPORT_METHOD(stop) {
    [[XGPush defaultManager] stopXGNotification];
}

RCT_EXPORT_METHOD(bindAccount:(NSString *)account) {
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:account type:XGPushTokenBindTypeAccount];
}

RCT_EXPORT_METHOD(unbindAccount:(NSString *)account) {
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:account type:XGPushTokenBindTypeAccount];
}

RCT_EXPORT_METHOD(bindTag:(NSString *)tag) {
    [[XGPushTokenManager defaultTokenManager] bindWithIdentifier:tag type:XGPushTokenBindTypeTag];
}

RCT_EXPORT_METHOD(unbindTag:(NSString *)tag) {
    [[XGPushTokenManager defaultTokenManager] unbindWithIdentifer:tag type:XGPushTokenBindTypeTag];
}

RCT_EXPORT_METHOD(reportLocation:(double)latitude longitude:(double)longitude) {
    [[XGPush defaultManager] reportLocationWithLatitude:latitude longitude:longitude];
}

RCT_EXPORT_METHOD(setBadge:(NSInteger)badge) {
    // 这里本地角标
    [[XGPush defaultManager] setXgApplicationBadgeNumber:badge];
    // 上报服务器，方便实现 +1 操作
    [[XGPush defaultManager] setBadge:badge];
}

RCT_EXPORT_METHOD(getBadge:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    NSInteger badge = [[XGPush defaultManager] xgApplicationBadgeNumber];
    resolve(@{
              @"badge": @(badge)
              });
}

RCT_EXPORT_METHOD(setDebug:(BOOL)enable) {
    [[XGPush defaultManager] setEnableDebug:enable];
}

@end
