//
//  ChatDetailViewController.m
//  JYIM
//
//  Created by jy on 2019/1/10.
//  Copyright © 2019年 jy. All rights reserved.
//

#import "ChatDetailViewController.h"
#import "ChatAlbumModel.h"
#import "ChatAudioPlayTool.h" //语音播放器
#import "ChatKeyboard.h"   //键盘
#import "MJRefreshNormalHeader.h"
#import "JChatTextCell.h"
#import "JChatAudioCell.h"
#import "JChatImageCell.h"
#import "JChatVideoCell.h"
#import "JChatLocationCell.h"

#import "JChatTextCellFrameModel.h"
#import "JChatAudioCellFrameModel.h"
#import "JChatImageCellFrameModel.h"
#import "JChatVideoCellFrameModel.h"
#import "JChatLocationCellFrameModel.h"

#import "TZImageManager.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "JChatLocationViewController.h"


@interface ChatDetailViewController ()<UITableViewDelegate,UITableViewDataSource,IMClientManagerDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) MJRefreshNormalHeader * refreshHeader;
@property (nonatomic, strong) NSMutableArray * datas;
@property (nonatomic, strong) NSMutableArray * cellFrameModelArr;
@property (nonatomic, assign) int limit;//每次加载信息数量
//键盘
@property (nonatomic, strong) ChatKeyboard * customKeyboard;
//语音播放器
@property (nonatomic, strong) ChatAudioPlayTool *audioPlayTool;
@property (nonatomic, assign) BOOL isFirstScrollToBottom;//第一次进入滚动到底部

@end

@implementation ChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstScrollToBottom = YES;
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    UIBarButtonItem * leftBI = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBI;
    
    _limit = 20;
    self.view.backgroundColor = [UIColor whiteColor];
    self.datas = [NSMutableArray array];
    self.cellFrameModelArr = [NSMutableArray array];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - defaultMsgBarHeight - SafeAreaBottomHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0.5f)];
    self.tableView.tableFooterView = footView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UICOLOR_RGB_Alpha(0xf0f0f0,1);
    
    self.refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDown)];
    self.tableView.mj_header = self.refreshHeader;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.customKeyboard];
    self.customKeyboard.frame = CGRectMake(0, self.view.height - defaultMsgBarHeight - SafeAreaBottomHeight, ScreenWidth, CTKEYBOARD_DEFAULTHEIGHT);
    WS(weakSelf)
    self.customKeyboard.keyboardViewFrameChange = ^(CGRect frame) {
        weakSelf.tableView.frame = CGRectMake(0, 0, weakSelf.view.width, frame.origin.y);
    };
    
    [IMClientManager sharedInstance].inChatRoomWithUid = _uid;
    self.title = _uid;
    [[IMClientManager sharedInstance] addDelegate:self];
    [self requestNewMessages];
}

-(void)requestNewMessages{
    NSMutableArray * messageArr = [[IMClientManager sharedInstance].imDB queryMessageInfoWithUserId:[IMClientManager sharedInstance].inChatRoomWithUid fromLastMessageId:@"-1" limitNum:_limit];
    if (messageArr.count == 0 || (messageArr.count != 0 && messageArr.count % _limit != 0)) {
        _tableView.mj_header = nil;
    }
    
    for (int i = 0; i < messageArr.count; i ++) {
        MessageInfoModel * model = messageArr[i];
        if (i == 0) {
            [model handleShowTimeWithLastMessageModel:nil];
        }else{
            MessageInfoModel * lastMessageModel = messageArr[i - 1];
            [model handleShowTimeWithLastMessageModel:lastMessageModel];
        }
        switch (model.messageType) {
            case 1://文本
            {
                [model handleMessageText];
                JChatTextCellFrameModel * cellFrameModel = [[JChatTextCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = model;
                [self.cellFrameModelArr addObject:cellFrameModel];
            }
                break;
            case 2://图片
            {
                JChatImageCellFrameModel * cellFrameModel = [[JChatImageCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = model;
                [self.cellFrameModelArr addObject:cellFrameModel];
            }
                break;
            case 3://视频
            {
                JChatVideoCellFrameModel * cellFrameModel = [[JChatVideoCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = model;
                [self.cellFrameModelArr addObject:cellFrameModel];
            }
                break;
            case 4://语音
            {
                JChatAudioCellFrameModel * cellFrameModel = [[JChatAudioCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = model;
                [self.cellFrameModelArr addObject:cellFrameModel];
            }
                break;
            case 5://位置
            {
                JChatLocationCellFrameModel * cellFrameModel = [[JChatLocationCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = model;
                [self.cellFrameModelArr addObject:cellFrameModel];
            }
                break;
            default:
                break;
        }
        
        
    }
    [self.datas addObjectsFromArray:messageArr];
    [self.tableView reloadData];
  
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_isFirstScrollToBottom == YES) {
        [self scrollToBottom];
        self.isFirstScrollToBottom = NO;
    }
   
}
-(void)pullDown{
    MessageInfoModel * firstModel = self.datas[0];
    NSMutableArray * messageArr = [[IMClientManager sharedInstance].imDB queryMessageInfoWithUserId:[IMClientManager sharedInstance].inChatRoomWithUid fromLastMessageId:firstModel.theId limitNum:_limit];
    
    NSMutableArray * moreCellFrameModelArr = [NSMutableArray array];
    for (int i = 0; i < messageArr.count; i ++) {
        MessageInfoModel * model = messageArr[i];
        [model handleMessageText];
        if (i == 0) {
            [model handleShowTimeWithLastMessageModel:nil];
        }else{
            MessageInfoModel * lastMessageModel = messageArr[i - 1];
            [model handleShowTimeWithLastMessageModel:lastMessageModel];
        }
        JChatTextCellFrameModel * cellFrameModel = [[JChatTextCellFrameModel alloc] init];
        cellFrameModel.messageInfoModel = model;
        [moreCellFrameModelArr addObject:cellFrameModel];
    }
    
    NSInteger scrollToIndex = [self.datas count];
    
    NSMutableIndexSet  *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, messageArr.count)];
    [self.cellFrameModelArr insertObjects:moreCellFrameModelArr atIndexes:indexes];
    [self.datas insertObjects:messageArr atIndexes:indexes];
    

    [self.tableView reloadData];
    [self.refreshHeader endRefreshing];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.datas count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    if (messageArr.count == 0 || (messageArr.count != 0 && messageArr.count % _limit != 0)) {
        _tableView.mj_header = nil;
    }
    
}

- (ChatKeyboard *)customKeyboard
{
    if (!_customKeyboard) {
        _customKeyboard = [[ChatKeyboard alloc]init];
        //传入当前控制器 ，方便打开相册（如放到控制器 ， 后期的逻辑过多，控制器会更加臃肿）
        __weak typeof(self) weakSelf = self;
        //普通文本消息
        [_customKeyboard textCallback:^(NSString *text) {
            
            //发送文本
         MessageInfoModel * model = [[IMClientManager sharedInstance] sendTextMessageWithStr:text toUserId:weakSelf.uid];
            [model handleMessageText];
            
            if (weakSelf.datas.count == 0) {
                [model handleShowTimeWithLastMessageModel:nil];
            }else{
                MessageInfoModel * lastMessageModel = [weakSelf.datas lastObject];
                [model handleShowTimeWithLastMessageModel:lastMessageModel];
            }
            JChatTextCellFrameModel * cellFrameModel = [[JChatTextCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [weakSelf.cellFrameModelArr addObject:cellFrameModel];
            
            [weakSelf.datas addObject:model];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [weakSelf closeKeyboard];
            [weakSelf scrollToBottom];
            
            
        } audioCallback:^(ChatAlbumModel *audio) {
            MessageInfoModel * model = [[IMClientManager sharedInstance] sendVoiceMessageWithAudioData:audio.audioData audioDuration:audio.duration toUserId:weakSelf.uid];
            
            if (weakSelf.datas.count == 0) {
                [model handleShowTimeWithLastMessageModel:nil];
            }else{
                MessageInfoModel * lastMessageModel = [self.datas lastObject];
                [model handleShowTimeWithLastMessageModel:lastMessageModel];
            }
            JChatAudioCellFrameModel * cellFrameModel = [[JChatAudioCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [weakSelf.cellFrameModelArr addObject:cellFrameModel];
            
            [weakSelf.datas addObject:model];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [weakSelf scrollToBottom];
            
            NSString * audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,model.toUser,model.audioName];
            
            [WWNetRequest uploadImageOrAudioWithFilePath:audioPath progress:^(NSProgress *progress) {
                
            } success:^(id response) {
                NSDictionary * paraDic = nil;
                if ([response[@"code"] intValue] == 200) {
                   paraDic = @{@"content":model.duration,@"time":model.sendTime,@"urlimg":@"",@"urlfile":response[@"data"],@"lon":@"",@"lat":@""};
                }else{
                    
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:model.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                    
                    model.sendStatus = @"0";
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView endUpdates];
                    return ;
                }
                
                NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                if (jsonStr == nil) {
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:model.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                    
                    model.sendStatus = @"0";
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView endUpdates];
                    return ;
                }
                int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:weakSelf.uid fp:model.messageInfoId WithType:4];
                
                if (returnCode == 0) {
                    model.sendStatus = @"1";
                    model.audioUrl = paraDic[@"urlfile"];
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:model.messageInfoId sendStatus:@"1" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                }else{
                    model.sendStatus = @"0";
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:model.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                }
                NSInteger index = [weakSelf.datas indexOfObject:model];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
                
            } failure:^(NSError *error) {
                model.sendStatus = @"0";
                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:model.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:1];
                NSInteger index = [weakSelf.datas indexOfObject:model];
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }];
            
            
           
        } picCallback:^(NSArray<ChatAlbumModel *> *images) {
            [weakSelf closeKeyboard];
            for (ChatAlbumModel * albumModel in images) {
                
                 MessageInfoModel * imageMessageModel = [[IMClientManager sharedInstance] sendImageMessageWithImageData:albumModel.normalPicData == nil?albumModel.orignalPicData:albumModel.normalPicData toUserId:weakSelf.uid picSize:albumModel.picSize];
                
                if (weakSelf.datas.count == 0) {
                    [imageMessageModel handleShowTimeWithLastMessageModel:nil];
                }else{
                    MessageInfoModel * lastMessageModel = [self.datas lastObject];
                    [imageMessageModel handleShowTimeWithLastMessageModel:lastMessageModel];
                }
                JChatImageCellFrameModel * cellFrameModel = [[JChatImageCellFrameModel alloc] init];
                cellFrameModel.messageInfoModel = imageMessageModel;
                [weakSelf.cellFrameModelArr addObject:cellFrameModel];
                
                [weakSelf.datas addObject:imageMessageModel];
                NSIndexPath * theImageIndexPath = [NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0];
                
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView insertRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
               
                
                NSString * picPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,imageMessageModel.toUser,imageMessageModel.picName];
                NSString * picSizeStr = NSStringFromCGSize(imageMessageModel.picSize);
                picSizeStr = [picSizeStr stringByReplacingOccurrencesOfString:@"{" withString:@""];
                picSizeStr = [picSizeStr stringByReplacingOccurrencesOfString:@"}" withString:@""];
                
                [WWNetRequest uploadImageOrAudioWithFilePath:picPath progress:^(NSProgress *progress) {
                    
                } success:^(id response) {
                    
                    if ([response[@"code"] intValue] == 200) {
                      NSDictionary * paraDic = @{@"content":picSizeStr,@"time":imageMessageModel.sendTime,@"urlimg":response[@"data"],@"urlfile":@"",@"lon":@"",@"lat":@""};
                        NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                        if (jsonStr == nil) {
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                            
                            imageMessageModel.sendStatus = @"0";
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            return ;
                        }
                        int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:weakSelf.uid fp:imageMessageModel.messageInfoId WithType:2];
                        
                        if (returnCode == 0) {
                            imageMessageModel.sendStatus = @"1";
                            imageMessageModel.picUrl = paraDic[@"urlimg"];
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"1" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        }else{
                            imageMessageModel.sendStatus = @"0";
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        }
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                    }else{
                        
                        [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        
                        imageMessageModel.sendStatus = @"0";
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                        return ;
                    }
                    
                } failure:^(NSError *error) {
                    
                    imageMessageModel.sendStatus = @"0";
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [weakSelf.tableView endUpdates];
                }];
            }
            [weakSelf scrollToBottom];
            
        } videoCallback:^(ChatAlbumModel *videoModel) {
            [weakSelf closeKeyboard];
            MessageInfoModel * videoMessageModel = [[IMClientManager sharedInstance] sendVideoMessageWithCoverImageData:UIImagePNGRepresentation(videoModel.videoCoverImg) videoName:videoModel.name toUserId:weakSelf.uid];
            
            if (weakSelf.datas.count == 0) {
                [videoMessageModel handleShowTimeWithLastMessageModel:nil];
            }else{
                MessageInfoModel * lastMessageModel = [self.datas lastObject];
                [videoMessageModel handleShowTimeWithLastMessageModel:lastMessageModel];
            }
            JChatVideoCellFrameModel * cellFrameModel = [[JChatVideoCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = videoMessageModel;
            [weakSelf.cellFrameModelArr addObject:cellFrameModel];
            
            [weakSelf.datas addObject:videoMessageModel];
            NSIndexPath * theVideoIndexPath = [NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0];
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            
            [[TZImageManager manager] getVideoOutputPathWithAsset:videoModel.videoAsset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
                NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
               
                //获取本地资源缓存路径
                NSString *videoCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",weakSelf.uid,videoModel.name]];
                NSFileManager * fn = [NSFileManager defaultManager];
                //拼接缓存目录
                NSString * savevideoDir = [videoCachePath stringByDeletingLastPathComponent];
                
                BOOL exist = [fn fileExistsAtPath:savevideoDir];
                if (!exist) {
                    [fn createDirectoryAtPath:savevideoDir withIntermediateDirectories:YES attributes:nil error:NULL];
                }
             
                
                if (![fn fileExistsAtPath:videoCachePath]) {
                    
                    BOOL isSuccess = [fn moveItemAtPath:outputPath toPath:videoCachePath error:nil];
                    
                    NSLog(@"%@---%@",isSuccess ? @"移动成功" : @"移动失败",videoCachePath);
                    if (isSuccess == NO) {
                        [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        videoMessageModel.sendStatus = @"0";
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                    }else{
                        
                        [WWNetRequest uploadVideoWithFilePath:videoCachePath progress:^(NSProgress *progress) {
                            
                        } success:^(id response) {
                            if ([response[@"code"] integerValue] == 200) {
                                
                                NSDictionary * paraDic = @{@"content":@"",@"time":videoMessageModel.sendTime,@"urlimg":response[@"data"][@"image"],@"urlfile":response[@"data"][@"void"],@"lon":@"",@"lat":@""};
                                NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                                
                               int code = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:weakSelf.uid fp:videoMessageModel.messageInfoId WithType:3];
                                if (code == 0) {
                                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"1" picUrl:response[@"data"][@"image"] audioUrl:@"" videoUrl:response[@"data"][@"void"] hasReadAudio:0];
                                    videoMessageModel.sendStatus = @"1";
                                    [weakSelf.tableView beginUpdates];
                                    [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    [weakSelf.tableView endUpdates];
                                }else{
                                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"0" picUrl:response[@"data"][@"image"] audioUrl:@"" videoUrl:response[@"data"][@"void"] hasReadAudio:0];
                                    videoMessageModel.sendStatus = @"0";
                                    [weakSelf.tableView beginUpdates];
                                    [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                    [weakSelf.tableView endUpdates];
                                }
                                
                            }else{
                                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                                videoMessageModel.sendStatus = @"0";
                                [weakSelf.tableView beginUpdates];
                                [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [weakSelf.tableView endUpdates];
                            }
                            
                        } failure:^(NSError *error) {
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                            videoMessageModel.sendStatus = @"0";
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                            
                        }];
                        
                    }
                }
                
            } failure:^(NSString *errorMessage, NSError *error) {
                NSLog(@"视频导出失败:%@,error:%@",errorMessage, error);
                 [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:videoMessageModel.messageInfoId sendStatus:@"0" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                videoMessageModel.sendStatus = @"0";
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
            }];
            [self scrollToBottom];
           
        }locationCallback:^(NSString *lat, NSString *lon, NSString *detailStr) {
            
         MessageInfoModel * locationMessageModel = [[IMClientManager sharedInstance] sendLocationMessageWithLat:lat lon:lon detailLocationStr:detailStr toUserId:weakSelf.uid];
            if (weakSelf.datas.count == 0) {
                [locationMessageModel handleShowTimeWithLastMessageModel:nil];
            }else{
                MessageInfoModel * lastMessageModel = [self.datas lastObject];
                [locationMessageModel handleShowTimeWithLastMessageModel:lastMessageModel];
            }
            JChatLocationCellFrameModel * cellFrameModel = [[JChatLocationCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = locationMessageModel;
            [weakSelf.cellFrameModelArr addObject:cellFrameModel];
            
            [weakSelf.datas addObject:locationMessageModel];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            [weakSelf closeKeyboard];
            [weakSelf scrollToBottom];
            
            
        } target:self];
    }
    return _customKeyboard;
}


#pragma tableview

#pragma mark - 滚动,点击等相关处理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self closeKeyboard];
}
-(void)closeKeyboard{
    [self.view endEditing:YES];
    [self.customKeyboard closeKeyboardContainer];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id cellFrameModel = self.cellFrameModelArr[indexPath.row];
    if ([cellFrameModel isKindOfClass:[JChatTextCellFrameModel class]]) {
        
        JChatTextCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"JChatTextCell"];
        if (!cell) {
            cell = [[JChatTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JChatTextCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textCellFrameModel = self.cellFrameModelArr[indexPath.row];
        [cell sendAgainCallback:^(MessageInfoModel * _Nonnull textMessageModel) {
            NSIndexPath * theIndexPath = indexPath;
             MessageInfoModel * tMessageModel = textMessageModel;
            NSDictionary * paraDic = @{@"content":tMessageModel.messageText,@"time":tMessageModel.sendTime,@"urlimg":@"",@"urlfile":@"",@"lon":@"",@"lat":@""};
            //发送文本
            int code = [[IMClientManager sharedInstance] sendMessageWithJsonStr:[AppUtil convertToJsonStr:paraDic] toUid:self.uid fp:tMessageModel.messageInfoId WithType:1];
            if (code == 0) {
                tMessageModel.sendStatus = @"1";
                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:tMessageModel.messageInfoId sendStatus:@"1" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
            }else{
                tMessageModel.sendStatus = @"0";
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } longpressCallback:^(LongpressSelectHandleType type, MessageInfoModel * _Nonnull textMessageModel) {
            
        } userInfoCallback:^(NSString * _Nonnull userID) {
            
        } deleteCallBack:^(MessageInfoModel * _Nonnull textMessageModel) {
             NSIndexPath * theIndexPath = indexPath;
          BOOL success = [[IMClientManager sharedInstance].imDB deleteMessageWithMeaasgeId:textMessageModel.messageInfoId];
            if (success) {
                [self.tableView beginUpdates];
                [self.datas removeObjectAtIndex:theIndexPath.row];
                [self.cellFrameModelArr removeObjectAtIndex:theIndexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
        return cell;
        
    }else if ([cellFrameModel isKindOfClass:[JChatAudioCellFrameModel class]]){
        JChatAudioCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"JChatAudioCell"];
        if (!cell) {
            cell = [[JChatAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JChatAudioCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.audioCellFrameModel = self.cellFrameModelArr[indexPath.row];
        
        [cell sendAgain:^(MessageInfoModel * _Nonnull audioModel) {
             MessageInfoModel * audioMessageModel = audioModel;
            audioMessageModel.sendStatus = @"2";
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            NSString * audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,audioMessageModel.toUser,audioMessageModel.audioName];
            if (audioMessageModel.audioUrl != nil && ![audioMessageModel.audioUrl isEqualToString:@""]) {
               NSDictionary * paraDic = @{@"content":audioMessageModel.duration,@"time":audioMessageModel.sendTime,@"urlimg":@"",@"urlfile":audioMessageModel.audioUrl,@"lon":@"",@"lat":@""};
                NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                
                int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:audioMessageModel.messageInfoId WithType:4];
                
                if (returnCode == 0) {
                    audioMessageModel.sendStatus = @"1";
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:audioModel.messageInfoId sendStatus:@"1" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                }else{
                    audioMessageModel.sendStatus = @"0";
                }
                
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
                
            }else{
                [WWNetRequest uploadImageOrAudioWithFilePath:audioPath progress:^(NSProgress *progress) {
                    
                } success:^(id response) {
                    NSDictionary * paraDic = nil;
                    if ([response[@"code"] intValue] == 200) {
                        paraDic = @{@"content":audioMessageModel.duration,@"time":audioMessageModel.sendTime,@"urlimg":@"",@"urlfile":response[@"data"],@"lon":@"",@"lat":@""};
                    }else{
                        audioMessageModel.sendStatus = @"0";
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                        return ;
                    }
                    
                    NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                    
                    int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:audioMessageModel.messageInfoId WithType:4];
                    
                    if (returnCode == 0) {
                        audioMessageModel.sendStatus = @"1";
                        audioMessageModel.audioUrl = paraDic[@"urlfile"];
                        [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:audioModel.messageInfoId sendStatus:@"1" picUrl:@"" audioUrl:paraDic[@"urlfile"] videoUrl:@"" hasReadAudio:1];
                    }else{
                        audioMessageModel.sendStatus = @"0";
                    }
                    
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    
                } failure:^(NSError *error) {
                    audioMessageModel.sendStatus = @"0";
                    
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }];
            }
            
            
            
            
        } playAudio:^(MessageInfoModel * audioModel) {
            
            [[ChatAudioPlayTool sharedInstance] audioPlayerWillPlayCallback:^(MessageInfoModel *theAudioModel, NSIndexPath * theIndexPath) {
                
                JChatAudioCell * theCell = [tableView cellForRowAtIndexPath:theIndexPath];
                [theCell playGIF];
                if (theAudioModel.hasReadAudio == NO) {
                    [[IMClientManager sharedInstance].imDB updateAudioMessageInfoReadStatusWithMessageId:theAudioModel.messageInfoId];
                    theAudioModel.hasReadAudio = YES;
                    [theCell hideRedPoint];
                }
                
            } audioPlayerPauseCallback:^(MessageInfoModel *theAudioModel, NSIndexPath *theIndexPath) {
                
                JChatAudioCell * theCell = [tableView cellForRowAtIndexPath:theIndexPath];
                [theCell stopGif];
                
            } audioPlayerFinishCallback:^(MessageInfoModel *theAudioModel, NSIndexPath *theIndexPath) {
                
                JChatAudioCell * theCell = [tableView cellForRowAtIndexPath:theIndexPath];
                [theCell stopGif];
                
            } audioPlayerdownloadingCallback:^(MessageInfoModel *theAudioModel, NSIndexPath *theIndexPath, CGFloat progress) {
                JChatAudioCell * theCell = [tableView cellForRowAtIndexPath:theIndexPath];
                [theCell showDownLoadProgress:progress];
                
            } audioPlayerdownloadFailedCallback:^(MessageInfoModel *theAudioModel, NSIndexPath *theIndexPath) {
                
            }];
             [[ChatAudioPlayTool sharedInstance] playWithMessageInfo:audioModel withIndexPath:indexPath];
            
        } longpress:^(LongpressSelectHandleType type, MessageInfoModel * _Nonnull audioModel) {
            
        } toUserInfo:^(NSString * _Nonnull userID) {
            
        } deleteCallBack:^(MessageInfoModel * _Nonnull audioModel) {
            NSIndexPath * theIndexPath = indexPath;
            if (![audioModel.sendStatus isEqualToString:@"2"]) {
                [[ChatAudioPlayTool sharedInstance] stopPlayWithAudioMessage:audioModel];
                BOOL success = [[IMClientManager sharedInstance].imDB deleteMessageWithMeaasgeId:audioModel.messageInfoId];
                if (success) {
                    [self.tableView beginUpdates];
                    [self.datas removeObjectAtIndex:theIndexPath.row];
                    [self.cellFrameModelArr removeObjectAtIndex:theIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    //删除本地音频资源
                    NSFileManager * fn = [NSFileManager defaultManager];
                    if(audioModel.byMySelf == YES){
                       NSString * audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,audioModel.toUser,audioModel.audioName];
                        if ([fn fileExistsAtPath:audioPath]) {
                            NSError * audioRemoveError;
                            [fn removeItemAtPath:audioPath error:&audioRemoveError];
                            if (audioRemoveError) {
                                NSLog(@"移除声音文件错误%@",audioRemoveError);
                            }
                        }
                    }else{
                        NSString * audioPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,audioModel.fromUser,audioModel.audioName];
                        if ([fn fileExistsAtPath:audioPath]) {
                            NSError * audioRemoveError;
                            [fn removeItemAtPath:audioPath error:&audioRemoveError];
                            if (audioRemoveError) {
                                NSLog(@"移除声音文件错误%@",audioRemoveError);
                            }
                        }
                    }
                }
            }else{
                NSLog(@"此声音文件正在上传,稍后删除");
            }
        }];
        return cell;
    }else if ([cellFrameModel isKindOfClass:[JChatImageCellFrameModel class]]){
        JChatImageCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"JChatImageCell"];
        if (!cell) {
            cell = [[JChatImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JChatImageCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.imageCellFrameModel = self.cellFrameModelArr[indexPath.row];
        [cell sendAgain:^(MessageInfoModel *picMessageModel) {
             MessageInfoModel * imageMessageModel = picMessageModel;
            NSIndexPath * theImageIndexPath = indexPath;
            imageMessageModel.sendStatus = @"2";
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
            
            NSString * picPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,imageMessageModel.toUser,imageMessageModel.picName];
            NSString * picSizeStr = NSStringFromCGSize(imageMessageModel.picSize);
            picSizeStr = [picSizeStr stringByReplacingOccurrencesOfString:@"{" withString:@""];
            picSizeStr = [picSizeStr stringByReplacingOccurrencesOfString:@"}" withString:@""];
            
            if (imageMessageModel.picUrl != nil && ![imageMessageModel.picUrl isEqualToString:@""]) {
                NSDictionary * paraDic = @{@"content":picSizeStr,@"time":imageMessageModel.sendTime,@"urlimg":imageMessageModel.picUrl,@"urlfile":@"",@"lon":@"",@"lat":@""};
                NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                if (jsonStr == nil) {
                    
                    imageMessageModel.sendStatus = @"0";
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    return ;
                }
                int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:imageMessageModel.messageInfoId WithType:2];
                
                if (returnCode == 0) {
                    imageMessageModel.sendStatus = @"1";
                    imageMessageModel.picUrl = paraDic[@"urlimg"];
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"1" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                }else{
                    imageMessageModel.sendStatus = @"0";
                }
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }else{
                [WWNetRequest uploadImageOrAudioWithFilePath:picPath progress:^(NSProgress *progress) {
                    
                } success:^(id response) {
                    
                    NSDictionary * paraDic = nil;
                    if ([response[@"code"] intValue] == 200) {
                        paraDic = @{@"content":picSizeStr,@"time":imageMessageModel.sendTime,@"urlimg":response[@"data"],@"urlfile":@"",@"lon":@"",@"lat":@""};
                        NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                        if (jsonStr == nil) {
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                            
                            imageMessageModel.sendStatus = @"0";
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                            return ;
                        }
                        int returnCode = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:imageMessageModel.messageInfoId WithType:2];
                        
                        if (returnCode == 0) {
                            imageMessageModel.sendStatus = @"1";
                            imageMessageModel.picUrl = paraDic[@"urlimg"];
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"1" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        }else{
                            imageMessageModel.sendStatus = @"0";
                            [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:imageMessageModel.messageInfoId sendStatus:@"0" picUrl:paraDic[@"urlimg"] audioUrl:@"" videoUrl:@"" hasReadAudio:0];
                        }
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                    }else{
                        
                        imageMessageModel.sendStatus = @"0";
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                        return ;
                    }
                    
                } failure:^(NSError *error) {
                    
                    imageMessageModel.sendStatus = @"0";
                    [self.tableView reloadRowsAtIndexPaths:@[theImageIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
            
        } showBigPicCallback:^(MessageInfoModel *picMessageModel) {
            if (picMessageModel.byMySelf == YES) {
                NSString * picPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,picMessageModel.toUser,picMessageModel.picName];
                if ([[NSFileManager defaultManager] fileExistsAtPath:picPath]) {
                    [PhotoBrowser presentViewController:self photoSourse:@[[NSURL fileURLWithPath:picPath]] startIndex:0 animated:YES delegate:nil type:@"1" completion:NULL];
                }
            }else{
                if (picMessageModel.picUrl) {
                    
                    [PhotoBrowser presentViewController:self photoSourse:@[picMessageModel.picUrl] startIndex:0 animated:YES delegate:nil type:@"1" completion:NULL];
                }
            }
        } longpressCallback:^(LongpressSelectHandleType type, MessageInfoModel *picMessageModel) {
           
            
        } toUserInfo:^(NSString *userID) {
            
        } deleteCallback:^(MessageInfoModel *picMessageModel) {
            NSIndexPath * theIndexPath = indexPath;
            if ([picMessageModel.sendStatus isEqualToString:@"2"]) {
                NSLog(@"此图片文件正在上传,稍后删除");
            }else{
                BOOL success = [[IMClientManager sharedInstance].imDB deleteMessageWithMeaasgeId:picMessageModel.messageInfoId];
                if (success) {
                    [self.tableView beginUpdates];
                    [self.datas removeObjectAtIndex:theIndexPath.row];
                    [self.cellFrameModelArr removeObjectAtIndex:theIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    
                    NSFileManager * fn = [NSFileManager defaultManager];
                    if (picMessageModel.byMySelf == YES) {
                        NSString * picPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,picMessageModel.toUser,picMessageModel.picName];
                        if ([fn fileExistsAtPath:picPath]) {
                            NSError * removePicError;
                            [fn removeItemAtPath:picPath error:&removePicError];
                            if (removePicError) {
                                NSLog(@"图片移除失败%@",removePicError);
                            }
                        }
                    }else{
                        NSString * picPath = [NSString stringWithFormat:@"%@/%@/%@",ChatCache_Path,picMessageModel.fromUser,picMessageModel.picName];
                        if ([fn fileExistsAtPath:picPath]) {
                            NSError * removePicError;
                            [fn removeItemAtPath:picPath error:&removePicError];
                            if (removePicError) {
                                NSLog(@"图片移除失败%@",removePicError);
                            }
                        }
                    }
                }
            }
            
        }];
        return cell;
    }else if ([cellFrameModel isKindOfClass:[JChatVideoCellFrameModel class]]) {
        
        JChatVideoCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"JChatVideoCell"];
        if (!cell) {
            cell = [[JChatVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JChatVideoCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.videoCellFrameModel = self.cellFrameModelArr[indexPath.row];
        [cell sendAgainCallback:^(MessageInfoModel * _Nonnull videoMessageModel) {
             MessageInfoModel * viMessageModel = videoMessageModel;
            NSIndexPath * theVideoIndexPath = indexPath;
            viMessageModel.sendStatus = @"2";
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            if (viMessageModel.videoUrl != nil && ![viMessageModel.videoUrl isEqualToString:@""] && viMessageModel.picUrl != nil && ![viMessageModel.picUrl isEqualToString:@""]) {
                NSDictionary * paraDic = @{@"content":@"",@"time":viMessageModel.sendTime,@"urlimg":viMessageModel.picUrl,@"urlfile":viMessageModel.videoUrl,@"lon":@"",@"lat":@""};
                NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                
                int code = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:videoMessageModel.messageInfoId WithType:3];
                if (code == 0) {
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:viMessageModel.messageInfoId sendStatus:@"1" picUrl:viMessageModel.picUrl audioUrl:@"" videoUrl:viMessageModel.videoUrl hasReadAudio:0];
                    viMessageModel.sendStatus = @"1";
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }else{
                    [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:viMessageModel.messageInfoId sendStatus:@"0" picUrl:viMessageModel.picUrl audioUrl:@"" videoUrl:viMessageModel.videoUrl hasReadAudio:0];
                    viMessageModel.sendStatus = @"0";
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }
            }else{
                //获取本地资源缓存路径
                NSString *videoCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",self.uid,viMessageModel.videoName]];
                NSFileManager * fn = [NSFileManager defaultManager];
                
                BOOL exist = [fn fileExistsAtPath:videoCachePath];
                if (!exist) {
                    viMessageModel.sendStatus = @"0";
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                }else{
                    
                    [WWNetRequest uploadVideoWithFilePath:videoCachePath progress:^(NSProgress *progress) {
                        
                    } success:^(id response) {
                        if ([response[@"code"] integerValue] == 200) {
                            
                            NSDictionary * paraDic = @{@"content":@"",@"time":videoMessageModel.sendTime,@"urlimg":response[@"data"][@"image"],@"urlfile":response[@"data"][@"void"],@"lon":@"",@"lat":@""};
                            NSString * jsonStr = [AppUtil convertToJsonStr:paraDic];
                            
                            int code = [[IMClientManager sharedInstance] sendMessageWithJsonStr:jsonStr toUid:self.uid fp:videoMessageModel.messageInfoId WithType:3];
                            if (code == 0) {
                                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:viMessageModel.messageInfoId sendStatus:@"1" picUrl:response[@"data"][@"image"] audioUrl:@"" videoUrl:response[@"data"][@"void"] hasReadAudio:0];
                                viMessageModel.sendStatus = @"1";
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                            }else{
                                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:viMessageModel.messageInfoId sendStatus:@"0" picUrl:response[@"data"][@"image"] audioUrl:@"" videoUrl:response[@"data"][@"void"] hasReadAudio:0];
                                viMessageModel.sendStatus = @"0";
                                [self.tableView beginUpdates];
                                [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                                [self.tableView endUpdates];
                            }
                            
                        }else{
                            
                            viMessageModel.sendStatus = @"0";
                            [self.tableView beginUpdates];
                            [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                            [self.tableView endUpdates];
                        }
                        
                    } failure:^(NSError *error) {
                        
                        viMessageModel.sendStatus = @"0";
                        [self.tableView beginUpdates];
                        [self.tableView reloadRowsAtIndexPaths:@[theVideoIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView endUpdates];
                        
                    }];
                }
            }
            
        } playVideoCallback:^(MessageInfoModel * _Nonnull videoMessageModel) {
            if (videoMessageModel.byMySelf == YES) {
                NSString *videoCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",self.uid,videoMessageModel.videoName]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:videoCachePath]) {
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:videoCachePath]];
                    [self presentViewController:vc animated:YES completion:nil];
                    [vc.player play];
                }else{
                    NSLog(@"文件不存在,可能正在导出和移动中,稍后再试");
                }
            }else{
                if (videoMessageModel.videoUrl != nil && ![videoMessageModel.videoUrl isEqualToString:@""]) {
                    AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
                    vc.player = [AVPlayer playerWithURL:[NSURL URLWithString:videoMessageModel.videoUrl]];
                    [self presentViewController:vc animated:YES completion:nil];
                    [vc.player play];
                }
            }
            
           
        } longpressCallback:^(LongpressSelectHandleType type, MessageInfoModel * _Nonnull videoMessageModel) {
            
        } userInfoCallback:^(NSString * _Nonnull userID) {
            
        } deleteCallback:^(MessageInfoModel * _Nonnull videoMessageModel) {
            NSIndexPath * theIndexPath = indexPath;
            if ([videoMessageModel.sendStatus isEqualToString:@"2"]) {
                NSLog(@"视频文件正在上传，稍后再删");
            }else{
                
                BOOL success = [[IMClientManager sharedInstance].imDB deleteMessageWithMeaasgeId:videoMessageModel.messageInfoId];
                if (success) {
                    [self.tableView beginUpdates];
                    [self.datas removeObjectAtIndex:theIndexPath.row];
                    [self.cellFrameModelArr removeObjectAtIndex:theIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    
                    NSFileManager * fn = [NSFileManager defaultManager];
                    if (videoMessageModel.byMySelf == YES) {
                        //获取本地资源缓存路径
                        NSString *coverimgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@_cover.jpg",videoMessageModel.toUser,videoMessageModel.messageInfoId]];
                        if ([fn fileExistsAtPath:coverimgCachePath]) {
                            [fn removeItemAtPath:coverimgCachePath error:nil];
                        }
                         NSString *videoCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",self.uid,videoMessageModel.videoName]];
                        if ([fn fileExistsAtPath:videoCachePath]) {
                            [fn removeItemAtPath:videoCachePath error:nil];
                        }
                    }else{
                        //获取本地资源缓存路径
                        NSString *coverimgCachePath = [ChatCache_Path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@_cover.jpg",videoMessageModel.fromUser,videoMessageModel.messageInfoId]];
                        if ([fn fileExistsAtPath:coverimgCachePath]) {
                            [fn removeItemAtPath:coverimgCachePath error:nil];
                        }
                       
                    }
                }
            }
        }];
        return cell;
        
    }else if ([cellFrameModel isKindOfClass:[JChatLocationCellFrameModel class]]) {
        
        JChatLocationCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"JChatLocationCell"];
        if (!cell) {
            cell = [[JChatLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JChatLocationCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.locationCellFrameModel = self.cellFrameModelArr[indexPath.row];
        [cell sendAgainCallback:^(MessageInfoModel * _Nonnull locationMessageModel) {
            
            __block MessageInfoModel * locMessageModel = locationMessageModel;
            NSDictionary * paraDic = @{@"content":locMessageModel.messageText,@"time":locMessageModel.sendTime,@"urlimg":@"",@"urlfile":@"",@"lon":locMessageModel.lon,@"lat":locMessageModel.lat};
            //发送文本
            int code = [[IMClientManager sharedInstance] sendMessageWithJsonStr:[AppUtil convertToJsonStr:paraDic] toUid:self.uid fp:locMessageModel.messageInfoId WithType:5];
            if (code == 0) {
                locMessageModel.sendStatus = @"1";
                [[IMClientManager sharedInstance].imDB updateMessageInfoWithMessageInfoId:locMessageModel.messageInfoId sendStatus:@"1" picUrl:@"" audioUrl:@"" videoUrl:@"" hasReadAudio:0];
            }else{
                locMessageModel.sendStatus = @"0";
            }
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
        } showDetailLocationCallback:^(MessageInfoModel * _Nonnull locationMessageModel) {
            JChatLocationViewController * vc = [[JChatLocationViewController alloc] init];
            vc.locationType = LocationType_show;
            vc.lat = locationMessageModel.lat;
            vc.lon = locationMessageModel.lon;
            vc.locationDetailStr = locationMessageModel.messageText;
            [self.navigationController pushViewController:vc animated:YES];
        } longpressCallback:^(LongpressSelectHandleType type, MessageInfoModel * _Nonnull locationMessageModel) {
            
        } userInfoCallback:^(NSString * _Nonnull userID) {
            
        } deleteCallback:^(MessageInfoModel * _Nonnull locationMessageModel) {
            NSIndexPath * theIndexPath = indexPath;
            BOOL success = [[IMClientManager sharedInstance].imDB deleteMessageWithMeaasgeId:locationMessageModel.messageInfoId];
            if (success) {
                [self.tableView beginUpdates];
                [self.datas removeObjectAtIndex:theIndexPath.row];
                [self.cellFrameModelArr removeObjectAtIndex:theIndexPath.row];
                [self.tableView deleteRowsAtIndexPaths:@[theIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }];
        return cell;
    }
    
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id cellFrameModel = _cellFrameModelArr[indexPath.row];
    if ([cellFrameModel isKindOfClass:[JChatTextCellFrameModel class]]) {
      JChatTextCellFrameModel *  cellFrameModel = (JChatTextCellFrameModel*)_cellFrameModelArr[indexPath.row];
        return cellFrameModel.cellHeight;
    }else if([cellFrameModel isKindOfClass:[JChatAudioCellFrameModel class]]){
        JChatAudioCellFrameModel * cellFrameModel = (JChatAudioCellFrameModel*)_cellFrameModelArr[indexPath.row];
        return cellFrameModel.cellHeight;
    }else if([cellFrameModel isKindOfClass:[JChatImageCellFrameModel class]]){
        JChatImageCellFrameModel * cellFrameModel = (JChatImageCellFrameModel*)_cellFrameModelArr[indexPath.row];
        return cellFrameModel.cellHeight;
    }else if ([cellFrameModel isKindOfClass:[JChatVideoCellFrameModel class]]){
        JChatVideoCellFrameModel * cellFrameModel = (JChatVideoCellFrameModel*)_cellFrameModelArr[indexPath.row];
        return cellFrameModel.cellHeight;
    }else if ([cellFrameModel isKindOfClass:[JChatLocationCellFrameModel class]]){
        JChatLocationCellFrameModel * cellFrameModel = (JChatLocationCellFrameModel*)_cellFrameModelArr[indexPath.row];
        return cellFrameModel.cellHeight;
    }
    return 0;
}



#pragma mark -  IMClientManagerDelegate 接收消息代理

/*!
 * 收到普通消息的回调事件通知。
 */
- (void) onTransBuffer:(NSString *)fingerPrintOfProtocal withUserId:(NSString *)dwUserid andContent:(NSString *)dataContent andTypeu:(int)typeu{
    
    if (![dwUserid isEqualToString:_uid]) {
        return;
    }
    MessageInfoModel * model = [[IMClientManager sharedInstance].imDB queryMessageInfoModelWithMessageInfoId:fingerPrintOfProtocal];
    if (self.datas.count == 0) {
        [model handleShowTimeWithLastMessageModel:nil];
    }else{
        MessageInfoModel * lastMessageModel = [self.datas lastObject];
        [model handleShowTimeWithLastMessageModel:lastMessageModel];
    }
    
    
    switch (model.messageType) {
        case 1://文本
        {
             [model handleMessageText];
             JChatTextCellFrameModel * cellFrameModel = [[JChatTextCellFrameModel alloc] init];
             cellFrameModel.messageInfoModel = model;
             [self.cellFrameModelArr addObject:cellFrameModel];
        }
            break;
        case 2://图片
        {
            JChatImageCellFrameModel * cellFrameModel = [[JChatImageCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [self.cellFrameModelArr addObject:cellFrameModel];
            
        }
            break;
        case 3://视频
        {
            JChatVideoCellFrameModel * cellFrameModel = [[JChatVideoCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [self.cellFrameModelArr addObject:cellFrameModel];
        }
            break;
        case 4://语音
        {
            JChatAudioCellFrameModel * cellFrameModel = [[JChatAudioCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [self.cellFrameModelArr addObject:cellFrameModel];
        }
            break;
        case 5://位置
        {
            JChatLocationCellFrameModel * cellFrameModel = [[JChatLocationCellFrameModel alloc] init];
            cellFrameModel.messageInfoModel = model;
            [self.cellFrameModelArr addObject:cellFrameModel];
        }
            break;
            
        default:
            break;
    }
    
  
    BOOL lastDataInVisiable = [self judgeTheLastMessageIsInScreen];
   
    [self.datas addObject:model];
    [self.tableView beginUpdates];
    
    if (lastDataInVisiable) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
          [self.tableView endUpdates];
        [self scrollToBottom];
    }else{
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datas.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    
    
}

/*!
 * 消息已被对方收到的回调事件通知.
 */
- (void) messagesBeReceived:(NSString *)theFingerPrint
{
   
    
}

#pragma mark - 收发消息 滚动到底部
- (void)scrollToBottom
{
    if (self.datas.count > 0) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_datas.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }

}



-(void)backAction{
    
    if (self.datas.count == 0) {
        [[IMClientManager sharedInstance].imDB deleteMessageListModelWithUserId:_uid];
    }else{
        MessageInfoModel * lastMessageInfoModel = [self.datas lastObject];
        [[IMClientManager sharedInstance].imDB insertOrUpdateContactWithMessageId:lastMessageInfoModel.messageInfoId fromUser:lastMessageInfoModel.fromUser toUser:lastMessageInfoModel.toUser messageType:lastMessageInfoModel.messageType sendTime:lastMessageInfoModel.sendTime byMySelf:lastMessageInfoModel.byMySelf notReadCount:0 messageText:lastMessageInfoModel.messageText];
    }
    [[ChatAudioPlayTool sharedInstance] stopPlay];
    [[IMClientManager sharedInstance] removeDelegate:self];
    [IMClientManager sharedInstance].inChatRoomWithUid = nil;
    
    [[IMClientManager sharedInstance].imDB updateMessageListModelHasReadByMyselfWithUserId:_uid];
    if (_backBlock) {
        _backBlock();
    }
    
    if(self.navigationController.viewControllers.count <= 1)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//判断最新消息是否在视野内
-(BOOL)judgeTheLastMessageIsInScreen{
    BOOL contain = NO;
  NSArray * visiableIndexPathArr = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath * indexPath in visiableIndexPathArr) {
        if (indexPath.row == self.datas.count - 1) {
            contain = YES;
            break;
        }
    }
    return contain;
}


@end
