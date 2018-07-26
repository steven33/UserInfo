//
//  UserManager.m
//  UserInfo
//
//  Created by 李方建 on 2018/7/23.
//  Copyright © 2018年 李方建. All rights reserved.
//

#import "UserManager.h"
#import <objc/runtime.h>
static UserManager *userInfo;
@interface UserManager  ()
- (BOOL)save;
+ (NSString *)fileName;
@end


@implementation UserManager
+ (instancetype)sharedManager{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        userInfo = [NSKeyedUnarchiver unarchiveObjectWithFile:UserManager.fileName];
        if (!userInfo) {
            userInfo = [[UserManager alloc]init];
        }
    });
    return userInfo;
}
//用户登录的时候调用
- (BOOL)login{
    return [self save];
}
//用户更新信息的时候调用
- (void)updateInfo{
    [self save];
}
//用户退出登录的时候调用
- (void)logOut{
    unsigned int ivarCount;
    Ivar *ivarList = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i ++) {
        const char *ivarName = ivar_getName(ivarList[i]);
        const char *ivarTypeEncoding = ivar_getTypeEncoding(ivarList[i]);
        NSString *nameStr = [NSString stringWithUTF8String:ivarName];
        NSString *typeStr = [NSString stringWithUTF8String:ivarTypeEncoding];
        if ([typeStr containsString:@"NSString"]) {
            [self setValue:@"" forKey:nameStr];
        }
    }
    [self save];
}

#pragma privite-method
- (BOOL)save{
    return [NSKeyedArchiver archiveRootObject:self toFile:UserManager.fileName];
}
#pragma-- mark 归档
- (void)encodeWithCoder:(NSCoder *)aCoder;{
    
    NSArray *properties = [UserManager getAllProperties];
    for (NSString *key in properties) {
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [self init]){
        NSArray *properties = [UserManager getAllProperties];
        for (NSString *key in properties) {
            id value = [aDecoder decodeObjectForKey:key];
            [self setValue:value forKey:key];
        }
    }
    return self;
}
//存储地址
+ (NSString *)fileName{
    
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filename = [Path stringByAppendingPathComponent:NSStringFromClass(self)];
    return filename;
}
//获取用户信息类的所有属性
+ (NSArray *)getAllProperties{
    
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++){
        
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}
@end
