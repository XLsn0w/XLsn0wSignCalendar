
#import "SignCalendarViewController.h"

typedef NS_ENUM(NSInteger, XLMonth) {
    XLMonthPrevious = 0,
    XLMonthCurrent = 1,
    XLMonthNext = 2
};

@interface SignCalendarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSMutableArray *signDaysArray;
@property (nonatomic, strong) NSMutableArray *lastArray;
@property (nonatomic, strong) NSMutableArray *nextArray;

@property (nonatomic, assign) NSInteger totalInt;

@property (strong, nonatomic) UILabel *titleDateLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIButton *signButton;

@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) NSNumber *score;

@end

@implementation SignCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"打卡签到";
    _score = @(0);
    _user = [[[XLDatabase sharedInstance] selectUserArrayFromXLDatabase] firstObject];
    _date = [NSDate date];
    [self drawCalendarUI];
}

- (void)parseSignDaysData {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSNumber *Year = [XL xl_getNSNumberWithString:[dateFormatter stringFromDate:_date]];
    [dateFormatter setDateFormat:@"MM"];
    NSNumber *Month = [XL xl_getNSNumberWithString:[dateFormatter stringFromDate:_date]];
    [XLNetworkManager GET:[NSString stringWithFormat:@"%@SignIn/GetSignInList", @"HTTPHeader"]
                    token:_user.token
                   params:@{@"AccountID":_user.accountId, @"Year":Year, @"Month":Month}
                  success:^(NSURLSessionDataTask *task, NSDictionary *JSONDictionary, NSString *JSONString) {
                      NSLog(@"{JSON}=========> %@", JSONString);
                      
                      _signDaysArray = [NSMutableArray array];
                      _lastArray = [NSMutableArray array];
                      _nextArray = [NSMutableArray array];
                     
                      NSArray *rootArray = [[JSONDictionary objectForKey:@"Data"] objectForKey:@"CurMonthSignInInfos"];
                      for (NSDictionary *singleDic in rootArray) {
                          SignInTimeModel *model = [[SignInTimeModel alloc] init];
                          [model setValuesForKeysWithDictionary:singleDic];
                          [_signDaysArray addObject:model];
                      }

                      NSArray *lastRootArray = [[JSONDictionary objectForKey:@"Data"] objectForKey:@"LastMonthSignInInfos"];
                      for (NSDictionary *singleDic in lastRootArray) {
                          lastModel *model = [[lastModel alloc] init];
                          [model setValuesForKeysWithDictionary:singleDic];
                          [_lastArray addObject:model];
                      }
                      
                      NSArray *nextRootArray = [[JSONDictionary objectForKey:@"Data"] objectForKey:@"NextMonthSignInInfos"];
                      for (NSDictionary *singleDic in nextRootArray) {
                          nextModel *model = [[nextModel alloc] init];
                          [model setValuesForKeysWithDictionary:singleDic];
                          [_nextArray addObject:model];
                      }
                      
                      NSInteger lastInt = _lastArray.count;
                      NSInteger nextInt = _nextArray.count;
                      NSInteger currentInt = _signDaysArray.count;
                      //总数计算出来的
                      _totalInt = lastInt + nextInt + currentInt;
                      
                      [_collectionView.mj_header endRefreshing];
                      [_collectionView reloadData];
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error, NSInteger statusCode, NSString *requestFailedReason) {
                  }];
}

- (void)previousMonthDateAction {
    [self setCurrentDate:[self getPreviousMonthDate]];
}

- (void)nextMonthDateAction {
    [self setCurrentDate:[self getNextMonthDate]];
}

- (void)setCurrentDate:(NSDate *)date {
    self.date = date;
    [self parseSignDaysData];
    _titleDateLabel.text = [_dateFormatter stringFromDate:self.date];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    [self parseSignDaysData];
    [self.collectionView reloadData];
}

#pragma mark - Public

// 获取date的下个月日期
- (NSDate *)getNextMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate *)getPreviousMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    return previousMonthDate;
}

- (void)drawCalendarUI {
    UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
    flowLayot.sectionInset = UIEdgeInsetsZero;
    flowLayot.itemSize = CGSizeMake((kScreenWidth - 10*kFitWidth) / 7, (kScreenWidth - 10*kFitWidth) / 7);
    flowLayot.minimumLineSpacing = 0;
    flowLayot.minimumInteritemSpacing = 0;
    
    CGRect collectionViewFrame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayot];
    [self.view addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[CalendarCell class] forCellWithReuseIdentifier:@"CalendarCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer"];
//    _collectionView.mj_header = [XLRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(parseSignDaysData)];
//    [_collectionView.mj_header beginRefreshing];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
        header.backgroundColor = [UIColor whiteColor];
        
        UIView *titleBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        titleBarView.backgroundColor = [UIColor redColor];
        [header addSubview:titleBarView];
        
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 32, 32)];
        [leftButton setImage:[UIImage imageNamed:@"icon_prev"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(previousMonthDateAction) forControlEvents:UIControlEventTouchUpInside];
        [titleBarView addSubview:leftButton];
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(titleBarView.frame.size.width - 37, 5, 32, 32)];
        [rightButton setImage:[UIImage imageNamed:@"icon_next"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(nextMonthDateAction) forControlEvents:UIControlEventTouchUpInside];
        [titleBarView addSubview:rightButton];
        
        _titleDateLabel = [[UILabel alloc] init];
        [titleBarView addSubview:_titleDateLabel];
        [_titleDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(titleBarView);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(200);
            make.top.mas_equalTo(1);
        }];
        _titleDateLabel.textAlignment = NSTextAlignmentCenter;
        _titleDateLabel.textColor = [UIColor whiteColor];
        _titleDateLabel.font = [UIFont boldSystemFontOfSize:20];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy年MM月"];
        _titleDateLabel.text = [_dateFormatter stringFromDate:_date];
        
        NSArray *weekdayArray = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
        NSInteger count = [weekdayArray count];
        CGFloat offsetX = 5*kFitWidth;
        for (int i = 0; i < count; i++) {
            UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 44, (kScreenWidth - 10*kFitWidth) / count, 20*kFitWidth)];
            weekdayLabel.textAlignment = NSTextAlignmentCenter;
            weekdayLabel.text = weekdayArray[i];
            if (iPhone5) {
                weekdayLabel.font = [UIFont boldSystemFontOfSize:12];
            } else if (iPhone6) {
                weekdayLabel.font = [UIFont systemFontOfSize:13];
            } else {
                weekdayLabel.font = [UIFont systemFontOfSize:14];
            }
            
            if (i == 0 || i == count - 1) {
                weekdayLabel.textColor = [UIColor blueColor];
            } else {
                weekdayLabel.textColor = [UIColor blackColor];
            }
            
            [header addSubview:weekdayLabel];
            offsetX += weekdayLabel.frame.size.width;
        }
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        footer.backgroundColor = [UIColor whiteColor];
        
//        _scoreLabel = [[UILabel alloc] init];
//        [footer addSubview:_scoreLabel];
//        [_scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(footer);
//            make.height.mas_equalTo(30);
//            make.width.mas_equalTo(200);
//            make.top.mas_equalTo(30);
//        }];
//        _scoreLabel.textAlignment = NSTextAlignmentCenter;
//        _scoreLabel.font = [UIFont boldSystemFontOfSize:18];
//        
//        _score = @(15);
//        
//        NSString *scoreStr = [XL xl_getNSStringWithNumber:_score];
//        NSString *contentStr = [NSString stringWithFormat:@"您本月积分是: %@分", scoreStr];
//        _scoreLabel.text = contentStr;
//        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
//        [AttributedStr addAttribute:NSFontAttributeName
//                              value:[UIFont boldSystemFontOfSize:20]
//                              range:NSMakeRange(8, scoreStr.length)];
//        [AttributedStr addAttribute:NSForegroundColorAttributeName
//                              value:[UIColor redColor]
//                              range:NSMakeRange(8, scoreStr.length)];
//        _scoreLabel.attributedText = AttributedStr;
     
        //signButton
        _signButton = [UIButton new];
        [footer addSubview:_signButton];
        [_signButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(110*kFitHeight);
            make.centerX.mas_equalTo(footer);
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
            make.height.mas_equalTo(50);
        }];
        [_signButton addTarget:self action:@selector(signButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_signButton setTitle:@"立刻签到" forState:(UIControlStateNormal)];
        [_signButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        _signButton.layer.borderColor = [[UIColor blueColor] CGColor];
        _signButton.backgroundColor = [UIColor blueColor];
        _signButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _signButton.layer.borderWidth = 1;
        [_signButton xlsn0w_addCornerRadius:10];
        
        return footer;
    }
    return nil;
}

- (UIColor *)setNavBarBackgroundColor {
    return [UIColor xlsn0w_hexString:@"#81D8D0"];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, 64);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(kScreenWidth, 330*kFitHeight);
}

// 获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    [components setDay:1];
    NSDate *firstDate = [calendar dateFromComponents:components];
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday fromDate:firstDate];
    return firstComponents.weekday - 1;
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate *)date {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

// 获取某月day的日期
- (NSDate *)dateOfMonth:(XLMonth)calendarMonth WithDay:(NSInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date;
    
    switch (calendarMonth) {
        case XLMonthPrevious:
            date = [self getPreviousMonthDate];
            break;
            
        case XLMonthCurrent:
            date = self.date;
            break;
            
        case XLMonthNext  :
            date = [self getNextMonthDate];
            break;
        default:
            break;
    }
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    [components setDay:day];
    NSDate *dateOfDay = [calendar dateFromComponents:components];
    return dateOfDay;
}

#pragma mark - UICollectionDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return _totalInt;// 开启这行代码
    return 40;//具体要和后台协商 计算出来总数  这边先写定一个值
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CalendarCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.dayLabel.textColor = [UIColor blackColor];
    
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];
    
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:_date];
    NSInteger totalDaysOfLastMonth = [self totalDaysInMonthOfDate:[self getPreviousMonthDate]];
    
    if (indexPath.row < firstWeekday) {//小于这个月的第一天
        NSInteger day = totalDaysOfLastMonth - firstWeekday + indexPath.row + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor grayColor];
        //上一个月显示出来的有签到就变色
        NSInteger lastDay = ((firstWeekday-1)-(totalDaysOfLastMonth-day));
        lastModel *model = [_lastArray xl_objectAtIndex:lastDay];
        if ([model.SignInStatus integerValue] == 1) {
            cell.backgroundColor = [UIColor blueColor];
            cell.dayLabel.textColor = [UIColor whiteColor];
        }

    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday) {//大于这个月的最后一天
        NSInteger day = indexPath.row - totalDaysOfMonth - firstWeekday + 1;
        cell.dayLabel.text = [NSString stringWithFormat:@"%ld", (long)day];
        cell.dayLabel.textColor = [UIColor grayColor];
        //下一月有签到就变色
        NSInteger nextDay = day - 1;
        nextModel *model = [_nextArray xl_objectAtIndex:nextDay];
        if ([model.SignInStatus integerValue] == 1) {
            cell.backgroundColor = [UIColor blueColor];
            cell.dayLabel.textColor = [UIColor whiteColor];
        }
     
    } else {//当前这个月
        NSInteger day = indexPath.row - firstWeekday + 1;
        cell.dayLabel.text= [NSString stringWithFormat:@"%ld", (long)day];
        //当前月有几天签到就变色
        NSInteger currentDay = day - 1;
        SignInTimeModel *model = [_signDaysArray xl_objectAtIndex:currentDay];
        if ([model.SignInStatus integerValue] == 1) {
            cell.backgroundColor = [UIColor blueColor];
            cell.dayLabel.textColor = [UIColor whiteColor];
        }
        
    }
    return cell;
}

#pragma mark - drawSignButtonUI

- (void)signButtonAction:(UIButton *)button {
    [XLNetworkManager POST:[NSString stringWithFormat:@"%@SignIn/SignIn", @"HTTPHeader"]
                     token:_user.token
                    params:@{@"AccountID":_user.accountId,
                             @"PropertyID":_user.propertyId,
                             @"EstateID":_user.estateId}
                   success:^(NSURLSessionDataTask *task, NSDictionary *JSONDictionary, NSString *JSONString) {
                       NSLog(@"%@", JSONString);
                       if ([[JSONDictionary objectForKey:@"StatusCode"] integerValue] == 0) {
                           [XL xl_showTipText:[JSONDictionary objectForKey:@"ErrorMsg"]];
                           [self parseSignDaysData];
                           [self.collectionView reloadData];
                       } else {
                           [XL xl_showTipText:[JSONDictionary objectForKey:@"ErrorMsg"]];
                       }
                   }
                   failure:^(NSURLSessionDataTask *task, NSError *error, NSInteger statusCode, NSString *requestFailedReason) {
                   }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation CalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        if (iPhone5) {
            _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*kFitTop, 56*kFitWidth, 56*kFitWidth)];
        } else if (iPhone6Plus) {
            _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*kFitTop, 56*kFitWidth, 56*kFitWidth)];
        } else {
           _dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*kFitTop, 56*kFitWidth, 56*kFitWidth)];
        }
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.font = [UIFont boldSystemFontOfSize:16];
        _dayLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        _dayLabel.layer.borderWidth = 0.5;
        _dayLabel.layer.borderColor = [[UIColor blackColor] CGColor];
        [self addSubview:_dayLabel];
    }
    return self;
}

@end

@implementation SignInTimeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

@implementation lastModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

@implementation nextModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end

