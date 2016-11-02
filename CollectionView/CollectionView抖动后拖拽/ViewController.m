//
//  ViewController.m
//  CollectionView抖动后拖拽
//
//  Created by songshu on 16/9/9.
//  Copyright © 2016年 SongShu. All rights reserved.
//

#import "ViewController.h"
#import "VibrateCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSMutableArray* collectionArr;

@property (nonatomic,strong) UICollectionView* vibrate;

/**是否抖动*/
@property (nonatomic,assign) BOOL isBegin;

/**是否已经抖动*/
@property (nonatomic,assign) BOOL isStarBegin;

/**抖动手势*/
@property (nonatomic,strong) UILongPressGestureRecognizer *recognize;

/**移动手势*/
@property (nonatomic,strong) UILongPressGestureRecognizer *longGesture;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self CreateUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.vibrate reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 手势相应事件

/**
 手势长按事件
 
 @param longGesture 长按手势
 */
- (void)longPress:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.vibrate indexPathForItemAtPoint:[longGesture locationInView:self.vibrate]];
            if (indexPath.row >= 0) {//第一个不可移动  个人限制
                self.isBegin = YES;
                [self.vibrate removeGestureRecognizer:self.recognize];
                [self addLongGesture];
                [self addSureButton];
                [self.vibrate reloadData];
                NSLog(@"1");
            }else{
                break;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            NSLog(@"2");
            break;
        }
        case UIGestureRecognizerStateEnded:
            NSLog(@"3");
            break;
        default:
            NSLog(@"4");
            break;
    }
}

#pragma mark - CollectionView Delegate 相关

//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionArr.count;
}

//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    VibrateCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"vibrate" forIndexPath:indexPath];
    
    //[cell sizeToFit];
    if(!cell){
        NSLog(@"-----------");
    }
    NSInteger num = indexPath.row;
    
    cell.nameLable.text = self.collectionArr[num];
    cell.headImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"00%@",self.collectionArr[num]]];
    if(self.isBegin == YES ){
        [self starLongPress:cell];
    }
    
    return cell;
}

//监听手势，并设置其允许移动cell和交换资源
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longGesture {
    //判断手势状态
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:{
            //判断手势落点位置是否在路径上
            NSIndexPath *indexPath = [self.vibrate indexPathForItemAtPoint:[longGesture locationInView:self.vibrate]];
            if (indexPath.row > 0) {//第一个不可移动  个人限制
                [self.vibrate beginInteractiveMovementForItemAtIndexPath:indexPath];
            }else{
                break;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            NSIndexPath* indexPath = [self.vibrate indexPathForItemAtPoint:[longGesture locationInView:self.vibrate]];
            if(indexPath.row < 1){
                break;//第一个不可移动  个人限制
            }
            //移动过程当中随时更新cell位置
            [self.vibrate updateInteractiveMovementTargetPosition:[longGesture locationInView:self.vibrate]];
            break;
        }
        case UIGestureRecognizerStateEnded:
            //移动结束后关闭cell移动
            [self.vibrate endInteractiveMovement];
            break;
        default:
            [self.vibrate endInteractiveMovement];
            
            //[self.vibrate cancelInteractiveMovement];
            break;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    
    //取出源item数据
    id objc = [self.collectionArr objectAtIndex:sourceIndexPath.item];
    //从资源数组中移除该数据
    [self.collectionArr removeObject:objc];
    //将数据插入到资源数组中的目标位置上
    [self.collectionArr insertObject:objc atIndex:destinationIndexPath.item];
    //    [self.vibrate reloadData];
}

//开始抖动
- (void)starLongPress:(VibrateCollectionViewCell*)cell{
    CABasicAnimation *animation = (CABasicAnimation *)[cell.layer animationForKey:@"rotation"];
    if (animation == nil) {
        [self shakeImage:cell];
    }else {
        [self resume:cell];
    }
}

//这个参数的理解比较复杂，我的理解是所在layer的时间与父layer的时间的相对速度，为1时两者速度一样，为2那么父layer过了一秒，而所在layer过了两秒（进行两秒动画）,为0则静止。
- (void)pause:(VibrateCollectionViewCell*)cell {
    cell.layer.speed = 0.0;
}

- (void)resume:(VibrateCollectionViewCell*)cell {
    cell.layer.speed = 1.0;
}

- (void)shakeImage:(VibrateCollectionViewCell*)cell {
    //创建动画对象,绕Z轴旋转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    //设置属性，周期时长
    [animation setDuration:0.08];
    
    //抖动角度
    animation.fromValue = @(-M_1_PI/2);
    animation.toValue = @(M_1_PI/2);
    //重复次数，无限大
    animation.repeatCount = HUGE_VAL;
    //恢复原样
    animation.autoreverses = YES;
    //锚点设置为图片中心，绕中心抖动
    cell.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [cell.layer addAnimation:animation forKey:@"rotation"];
}

#pragma mark - 私有方法

/**
 创建视图
 */
- (void)CreateUI{
    
    [self.view addSubview:self.vibrate];
    
    [self addRecognize];
}

- (void)addSureButton{
    
    UIButton* sure = [[UIButton alloc]init];
    sure.frame = CGRectMake(kWidth/2-30, kHeight-60, 60, 40);
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    sure.backgroundColor = [UIColor orangeColor];
    [sure addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sure];
}

- (void)addLongGesture{
    
    [self.vibrate addGestureRecognizer:self.longGesture];
}

- (void)addRecognize{
    
    [self.vibrate addGestureRecognizer:self.recognize];
}

- (void)sureBtnAction:(UIButton*)sender{
    
    [self.vibrate removeGestureRecognizer:self.longGesture];
    
    self.isBegin = NO;
    
    [self addRecognize];
    
    [sender removeFromSuperview];
    
    [self.vibrate reloadData];
}



#pragma mark - Getters And Setters

- (NSMutableArray *)collectionArr{
    if (!_collectionArr) {
        _collectionArr = [[NSMutableArray alloc]init];
        
        for(int i = 1;i<21;i++){
            [_collectionArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
    }
    return _collectionArr;
}

- (UILongPressGestureRecognizer *)recognize{
    if (!_recognize) {
        //添加长按抖动手势
        if(!_recognize){
            _recognize = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            //长按响应时间
            _recognize.minimumPressDuration = 1;
        }
    }
    return _recognize;
}

- (UILongPressGestureRecognizer *)longGesture{
    //此处给其增加长按手势，用此手势触发cell移动效果
    if(!_longGesture){
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        _longGesture.minimumPressDuration = 0;
    }
    return _longGesture;
}

- (UICollectionView *)vibrate{
    if (!_vibrate) {
        
        //创建一个layout布局类
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        //设置布局方向为垂直流布局
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //设置每个item的大小为127.5*127.5
        layout.itemSize = CGSizeMake(114*kWidth/750.00, 114*kWidth/750.00);
        //整体view据上左下右距离
        layout.sectionInset = UIEdgeInsetsMake(48*kWidth/750.00, 48*kWidth/750.00, 48*kWidth/750.00,48*kWidth/750.00);
        //每个item上下距离
        layout.minimumLineSpacing = 90*kWidth/750.00;
        //每个item左右距离
        layout.minimumInteritemSpacing = 66*kWidth/750.00;
        
        //创建collectionView 通过一个布局策略layout来创建
        _vibrate = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0*kWidth/750.00, kWidth, kHeight) collectionViewLayout:layout];
        _vibrate.delegate = self;
        _vibrate.dataSource = self;
        _vibrate.backgroundColor = [UIColor lightGrayColor];
        _vibrate.showsHorizontalScrollIndicator = NO;
        _vibrate.showsVerticalScrollIndicator = NO;
        _vibrate.userInteractionEnabled = YES;
        //注册item类型 这里使用系统的类型
        [_vibrate registerClass:[VibrateCollectionViewCell class] forCellWithReuseIdentifier:@"vibrate"];
        
    }
    return _vibrate;
}

@end
