//
//  ViewController.m
//  UserInfo
//
//  Created by 李方建 on 2018/7/23.
//  Copyright © 2018年 李方建. All rights reserved.
//

#import "ViewController.h"
#import "UserManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *login = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 100, 40)];
    [login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [login setTitle:@"login" forState:UIControlStateNormal];
    login.backgroundColor = [UIColor redColor];
    [self.view addSubview:login];
    
    UIButton *logout = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, 100, 40)];
    [logout setTitle:@"logout" forState:UIControlStateNormal];
    [logout addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    logout.backgroundColor = [UIColor redColor];
    [self.view addSubview:logout];
    
    
}

- (void)login{
    [UserManager sharedManager].userID = @"345678";
    [[UserManager sharedManager] login];
}
- (void)logout{
    [[UserManager sharedManager] logOut];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
