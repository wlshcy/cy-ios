//
//  OrderEnsureViewController.m
//  YW
//
//  Created by nmg on 16/1/20.
//  Copyright (c) 2016 nmg. All rights reserved.
//

#import "PayController.h"
#import "OrderEnsureViewController.h"
#import "AddressCell.h"
#import <AlipaySDK/AlipaySDK.h>
#import "EnsureCell.h"
#import "PriceCell.h"

#import "WXApi.h"
#import "WXApiObject.h"

#import "AddressListViewController.h"
#import "ZoneListViewController.h"



#define HEADER_HEIGHT 476/2.0

#define BOTTOM_HEIGHT 60

@interface OrderEnsureViewController ()<UITableViewDataSource,UITableViewDelegate,UIPageViewControllerDelegate>
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *submitBtn;
@end

@implementation OrderEnsureViewController


- (instancetype)init
{
    if (self = [super init]) {
        [self layoutNavigationBar];
        _items = [NSMutableArray arrayWithCapacity:10];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseAddress:) name:@"CHOOSEADDRESS" object:nil];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayResult:) name:@"WXPAYRESULT" object:nil];
    }
    return self;
}

- (void)layoutNavigationBar
{
    self.title = @"订单填写";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBarButton:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.listView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.priceLabel];
    [self.bottomView addSubview:self.submitBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_items removeAllObjects];
    [_items addObjectsFromArray:[[DBManager instance] getAllItems]];
    
    self.listView.hidden = NO;
    self.bottomView.hidden = NO;
    
    [self computeTotalPrice];
    [_listView reloadData];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidLayoutSubviews
{
    if ([_listView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([_listView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
    
}



- (void)setup
{
    [self.view addSubview:self.listView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)chooseAddress:(NSNotification *)noti
{
    NSDictionary *address = [noti userInfo];
    
    self.address = address;
    
    [self.listView reloadData];
    
}

#pragma mark - TableViewDelegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }else if(section == 2){
        return _items.count;
    }else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }
    else if (indexPath.section == 1){
        
            return 50;
    }
    else{
            return 60;
        }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
        return 33;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"收货地址";
    }
    else if (section == 1){
        return @"运费";
    }
    else{
        return @"商品列表";
    }
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, 320, 33);
    myLabel.font = [UIFont boldSystemFontOfSize:16];
    myLabel.textColor = [UIColor grayColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"addressCell";
        AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        }
        cell = [[AddressCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        
        if (_address) {
            UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH, 20)];
            info.text = [NSString stringWithFormat:@"%@  %@",_address[@"name"],_address[@"mobile"]];
            info.font = FONT(16);
            
            UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(15, info.bottom+15, SCREEN_WIDTH, 20)];
            address.text = [NSString stringWithFormat:@"%@%@",_address[@"region"],_address[@"address"]];
            address.font = FONT(14);
            
            [cell addSubview:info];
            [cell addSubview:address];
        }
        else {
            cell.textLabel.text = @"请选择收货地址";

        }
            
        cell.textLabel.font = FONT(16);
        cell.detailTextLabel.font = FONT(14);
        cell.textLabel.textColor = BLACK_COLOR;
        cell.detailTextLabel.textColor = GRAY_COLOR;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
        
        
    }else if (indexPath.section == 2){
        static NSString *cellIndentifier = @"itemCell";
//        EnsureCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (!cell) {
            cell = [[EnsureCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
//        [cell populateCell:_items[indexPath.row]];
        cell.textLabel.text = _items[indexPath.row][@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@份",_items[indexPath.row][@"count"]];
        cell.detailTextLabel.textColor = BLACK_COLOR;
        cell.textLabel.font = FONT(16);
        cell.detailTextLabel.font = FONT(16);
        
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        [tableView setSeparatorColor:[UIColor colorWithRed:242.0/255.0f green:242.0/255.0f blue:242.0/255.0f alpha:1.0]];
        

        return cell;
    }else {
        static NSString *CellIdentifier = @"BEIZHUCELL";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.text = @"运费";
        cell.textLabel.font = FONT(16);
        
        NSString *text = [NSString stringWithFormat:@"%.0f元", _freight];
        cell.detailTextLabel.text = text;
        cell.detailTextLabel.font = FONT(16);
        cell.detailTextLabel.textColor = RGB_COLOR(0,0,0);

        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
            AddressListViewController *controller = [[AddressListViewController alloc] initWithFlag:1];
        
            [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - User Action
- (void)clickLeftBarButton:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Getter
- (UITableView *)listView
{
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,  SCREEN_HEIGHT-BOTTOM_HEIGHT-65) style:UITableViewStylePlain];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.tableFooterView = [UIView new];
        _listView.bounces = YES;
        _listView.showsHorizontalScrollIndicator = NO;
        _listView.showsVerticalScrollIndicator = NO;
        _listView.backgroundColor = RGB_COLOR(242, 242, 242);
    }
    return _listView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _listView.bottom, SCREEN_WIDTH, BOTTOM_HEIGHT)];
    }
    return _bottomView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.bottomView.height-30)/2.0, 150, 30)];
        _priceLabel.textColor = RED_COLOR;
        _priceLabel.font = FONT(16);
    }
    return _priceLabel;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitBtn.backgroundColor = RGB_COLOR(243, 96, 67);
        _submitBtn.frame = CGRectMake(SCREEN_WIDTH-110, 10 , 100,40);
        [_submitBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [_submitBtn setTitle:@"提交订单" forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = FONT(16);
        _submitBtn.layer.cornerRadius = 3;
        [_submitBtn addTarget:self action:@selector(commitOrder:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

- (void)computeTotalPrice
{
    
    
    if (_totalPrice >= 5) {
        
        _priceLabel.text = [NSString stringWithFormat:@"共计:%0.2f元",_totalPrice];
        
    }else{
        _priceLabel.text = [NSString stringWithFormat:@"共计:%0.2f元",_totalPrice+5];
    }
    
}

- (void)commitOrder:(UIButton *)sender

{
    if (self.address) {
        PayController *controller = [[PayController alloc] init];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else{
        [self showErrorStatusWithTitle:@"请选择收货地址"];
    }
   
}
@end
