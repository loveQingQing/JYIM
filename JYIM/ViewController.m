//
//  ViewController.m
//  JYIM
//
//  Created by jy on 2019/1/7.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "ViewController.h"
#import "MessageInfoModel.h"
#import "ChatListViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton * btn;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.btn = [UIButton buttonWithType:normal];
    [self.view addSubview:self.btn];
    self.btn.frame = CGRectMake(120, 120, 40, 40);
    [self.btn setTitle:@"进入" forState:UIControlStateNormal];
    [self.btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.btn setBackgroundColor:[UIColor grayColor]];
    self.btn.userInteractionEnabled = NO;
    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:3];
}


-(void)delayMethod{
    [[IMClientManager sharedInstance] sendTextMessageWithStr:@"文本消息" toUserId:@"1111"];
    self.btn.backgroundColor = [UIColor redColor];
    self.btn.userInteractionEnabled = YES;
}


-(void)clickBtn{
    ChatListViewController * vc = [[ChatListViewController alloc] init];
    UINavigationController * nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nc animated:YES completion:nil];
}
@end

