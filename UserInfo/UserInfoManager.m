//
//  UserInfoManager.m
//  UserInfo
//
//  Created by 李方建 on 2018/7/23.
//  Copyright © 2018年 李方建. All rights reserved.
//

#import "UserInfoManager.h"
#import <objc/runtime.h>
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)


static UserInfoManager *userInfo;

@implementation UserInfoManager
+ (void)load{
    NSArray *properties = [UserInfoManager getAllProperties];
    NSLog(@"%@",properties);
    for (NSString *name in properties) {
        NSString *upName = [name stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[name substringToIndex:1] uppercaseString]];
        //原来的set、get方法
        Method originalSetMethod = class_getInstanceMethod([self class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",upName]));
        Method originalGetMethod = class_getInstanceMethod([self class], NSSelectorFromString(name));
        //新的set、get方法
        IMP newSetIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(setMyAttribute:)));
        IMP newGetIMP = method_getImplementation(class_getInstanceMethod([self class], @selector(getAttribute)));
        
        method_setImplementation(originalSetMethod, newSetIMP);
        method_setImplementation(originalGetMethod, newGetIMP);
        
        
    }
    
}
+ (instancetype)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        userInfo = [[UserInfoManager alloc]init];
    });
    
    return userInfo;
}
- (void)setMyAttribute:(id)attribute{
    NSString *selectorStr = NSStringFromSelector(_cmd);
    //对set方法进行属性字段的解析,并存储到用户偏好设置表
    NSString *attr = [selectorStr substringFromIndex:3];
    attr = [attr substringToIndex:[attr length]-1];
    //对首字符进行小写
    NSString *firstChar = [attr substringToIndex:1];
    firstChar = [firstChar lowercaseString];
    NSString *lastAttri = [NSString stringWithFormat:@"%@%@",firstChar,[attr substringFromIndex:1]];
    [[NSUserDefaults standardUserDefaults]setObject:attribute forKey:lastAttri];
}
- (id)getAttribute{
    //获取方法名
    NSString *selectorString = NSStringFromSelector(_cmd);
    
    NSString *result = [[NSUserDefaults standardUserDefaults] objectForKey:selectorString];
    if ([result isEqual:[NSNull null]]) {
        result = nil;
    }
    return result;}
+ (void)configInfo:(NSDictionary *)infoDic{
    NSArray *allKeys = [infoDic allKeys];
    for (NSString *key in allKeys) {
        
        //首字母大写
        NSString *upKey = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[key substringToIndex:1] uppercaseString]];
        
        //构造setter方法
        NSString *selectorStr = [NSString stringWithFormat:@"set%@:",upKey];
        SEL setSeletor = NSSelectorFromString(selectorStr);
        //调用setter方法
        NSString *value = [infoDic objectForKey:key];
        
        UserInfoManager *manager = [UserInfoManager sharedManager];
        if ([manager respondsToSelector:setSeletor]) {
            SuppressPerformSelectorLeakWarning(
                [manager performSelector:setSeletor withObject:value];
            );
        }
        
    }

}
//获取用户信息类的所有属性
+ (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

@end
