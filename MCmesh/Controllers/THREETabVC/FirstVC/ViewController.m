//
//  ViewController.m
//  MCmesh
//
//  Created by zhoulanjun on 16/5/12.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import "ViewController.h"
#import "HttpTools.h"
#import "IpcSingleCell.h"
#import "IpcModel.h"
#import "HeartBeat.h"
#import "PrepareStartVc.h"
#import "MeshNodeInfoVC.h"

#warning 测试 要删掉
#import "AddPerperalNodesVC.h"


@interface ViewController ()
@property (nonatomic,retain) NSArray *items;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self logIn];
    [self initUI];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getAllIPCCameras];

}

-(void)logIn
{
    [HttpTools logIn:^(BOOL successOrNot) {
        if (successOrNot)
        {
            [[HeartBeat  sharedHeartBeat] regularlySend];
            [self getAllIPCCameras];
        }
    } errorIn:^(NSError *error) {
        
    }];
}

-(void)getAllIPCCameras
{
    [HttpTools getAllIPCCameras:^(BOOL successOrNot) {
        if (successOrNot)
        {
            [self.tableView reloadData];
        }
    } errorIn:^(NSError *error) {
        
    }];
}

-(void)initUI
{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getAllIPCCameras) name:@"SUCCESSUNLINKDEVICE" object:nil];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(prepareStart)];
    self.tableView.separatorStyle = NO;
    [self.tableView registerClass:[IpcSingleCell class] forCellReuseIdentifier:@"cellId"];
}

-(void)prepareStart
{
//    PrepareStartVc *pvc=[[PrepareStartVc alloc]init];
//    [User sharedUser].addDeviceOrSetWifi=@"ADDDEV";
//    [self.navigationController pushViewController:pvc animated:YES];
    
    
#warning 要删掉
    AddPerperalNodesVC *apv=[[AddPerperalNodesVC alloc]init];
    [self.navigationController pushViewController:apv animated:YES];
    
    
}

#pragma mark - TableView Methods
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[User sharedUser].deviceArr count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IpcSingleCell *cell =[tableView dequeueReusableCellWithIdentifier:@"cellId"];
    IpcModel *model=[User sharedUser].deviceArr[indexPath.row];
    cell.IPCNameLabel.text=model.deviceName;
    cell.IPCKindLabel.text=model.deviceKind;
    cell.IPCSN=model.SN;
    cell.locIndex =indexPath.row;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IpcModel *model=[User sharedUser].deviceArr[indexPath.row];
    MeshNodeInfoVC *mvc=[[MeshNodeInfoVC alloc]init];
    mvc.IPCSN=model.SN;
    mvc.locIndex=indexPath.row;
    [self.navigationController pushViewController:mvc animated:YES];
}

@end
