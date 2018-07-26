//
//  UserInfoManager.h
//  UserInfo
//
//  Created by 李方建 on 2018/7/23.
//  Copyright © 2018年 李方建. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoManager : NSObject
@property(nonatomic,copy)NSString *userID,*nickName,*headPic,*userName,*phone,*exclusiveCode,*birthday,*email;


+ (instancetype)sharedManager;
+ (void)configInfo:(NSDictionary *)infoDic;

@end
