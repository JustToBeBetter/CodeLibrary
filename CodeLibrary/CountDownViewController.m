//
//  LJZCountDownViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/8/14.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "CountDownViewController.h"

@interface CountDownViewController ()

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *dayLabel;
@property (nonatomic,strong) UILabel *hourLabel;
@property (nonatomic,strong) UILabel *minLabel;
@property (nonatomic,strong) UILabel *seclabel;

@end

@implementation CountDownViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Do any additional setup after loading the view.
    [self initUI];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(aaa) userInfo:nil repeats:YES];

}

- (void)initUI{
    
    CGFloat timeLabelX = 50;
    CGFloat timeLabelY = 80;
    CGFloat timeLabelW = SCREEN_WIDTH - 2*timeLabelX;
    CGFloat timeLabelH = 60;
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(timeLabelX, timeLabelY, timeLabelW, timeLabelH)];
    self.timeLabel.numberOfLines = 0;
    [self.view addSubview:self.timeLabel];
    
    CGFloat dayLabelX = timeLabelX;
    CGFloat dayLabelY = CGRectGetMaxY(self.timeLabel.frame) + 20;
    CGFloat dayLabelW = timeLabelW;
    CGFloat dayLabelH = timeLabelH;
    
    self.dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(dayLabelX, dayLabelY, dayLabelW, dayLabelH)];
    self.dayLabel.numberOfLines = 0;
    [self.view addSubview:self.dayLabel];
    
    CGFloat hourLabelX = timeLabelX;
    CGFloat hourLabelY = CGRectGetMaxY(self.dayLabel.frame) + 20;
    CGFloat hourLabelW = timeLabelW;
    CGFloat hourLabelH = timeLabelH;
    
    self.hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(hourLabelX, hourLabelY, hourLabelW, hourLabelH)];
    self.hourLabel.numberOfLines = 0;
    [self.view addSubview:self.hourLabel];
    
    CGFloat minLabelX = timeLabelX;
    CGFloat minLabelY = CGRectGetMaxY(self.hourLabel.frame) + 20;
    CGFloat minLabelW = timeLabelW;
    CGFloat minLabelH = timeLabelH;
    
    self.minLabel = [[UILabel alloc]initWithFrame:CGRectMake(minLabelX, minLabelY, minLabelW, minLabelH)];
    self.minLabel.numberOfLines = 0;
    [self.view addSubview:self.minLabel];
    
    CGFloat seclabelX = timeLabelX;
    CGFloat seclabelY = CGRectGetMaxY(self.minLabel.frame) + 20;
    CGFloat seclabelW = timeLabelW;
    CGFloat seclabelH = timeLabelH;
    
    self.seclabel = [[UILabel alloc]initWithFrame:CGRectMake(seclabelX, seclabelY, seclabelW, seclabelH)];
    self.seclabel.numberOfLines = 0;
    [self.view addSubview:self.seclabel];
    
    
}
- (void)timerFireMethod:(NSTimer *)theTimer
{
    BOOL timeStart = YES;
    NSCalendar *cal = [NSCalendar currentCalendar];//定义一个NSCalendar对象
    NSDateComponents *endTime = [[NSDateComponents alloc] init];    //初始化目标时间...
    NSDate *today = [NSDate date];    //得到当前时间
    
    NSString *todate = @"2017-07-02 09:12:38";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateString = [dateFormatter dateFromString:todate];
    NSString *overdate = [dateFormatter stringFromDate:dateString];
    static int year;
    static int month;
    static int day;
    static int hour;
    static int minute;
    static int second;
    if(timeStart) {//从NSDate中取出年月日，时分秒，但是只能取一次
        year = [[overdate substringWithRange:NSMakeRange(0, 4)] intValue];
        month = [[overdate substringWithRange:NSMakeRange(5, 2)] intValue];
        day = [[overdate substringWithRange:NSMakeRange(8, 2)] intValue];
        hour = [[overdate substringWithRange:NSMakeRange(11, 2)] intValue];
        minute = [[overdate substringWithRange:NSMakeRange(14, 2)] intValue];
        second = [[overdate substringWithRange:NSMakeRange(17, 2)] intValue];
        timeStart= NO;
    }
    
    [endTime setYear:year];
    [endTime setMonth:month];
    [endTime setDay:day];
    [endTime setHour:hour];
    [endTime setMinute:minute];
    [endTime setSecond:second];
    NSDate *overTime = [cal dateFromComponents:endTime]; //把目标时间装载入date
    //用来得到具体的时差，是为了统一成北京时间
    unsigned int unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour| NSCalendarUnitMinute| NSCalendarUnitSecond;
    NSDateComponents *d = [cal components:unitFlags fromDate:today toDate:overTime options:0];
    NSString *t = [NSString stringWithFormat:@"%ld", (long)[d day]];
    NSString *h = [NSString stringWithFormat:@"%ld", (long)[d hour]];
    NSString *fen = [NSString stringWithFormat:@"%ld", (long)[d minute]];
    if([d minute] < 10) {
        fen = [NSString stringWithFormat:@"0%ld",(long)[d minute]];
    }
    NSString *miao = [NSString stringWithFormat:@"%ld", (long)[d second]];
    if([d second] < 10) {
        miao = [NSString stringWithFormat:@"0%ld",(long)[d second]];
    }
    //    NSLog(@"===%@天 %@:%@:%@",t,h,fen,miao);
    [self.timeLabel setText:[NSString stringWithFormat:@"%@天 %@:%@:%@",t,h,fen,miao]];
    if([d second] > 0) {
        //计时尚未结束，do_something
        //        [_longtime setText:[NSString stringWithFormat:@"%@:%@:%@",d,fen,miao]];
    } else if([d second] == 0) {
        //计时结束 do_something
        
    } else{
        //计时器失效
        [theTimer invalidate];
    }
    
}
//相对时间 N年N月N日后的日期     负 数可以表示n年前的日期
- (NSString *)relativeTime:(NSString *)dateStr years:(NSInteger)years month:(NSInteger)month day:(NSInteger)day{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//直接指定时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date1 = [dateFormatter dateFromString:dateStr];
    NSLog(@"date1==%@", date1);
    
    NSDate *today = [NSDate date];
    NSLog(@"latedata==%@", [today laterDate:date1]);
    NSLog(@"earlydata==%@", [today earlierDate:date1]);
    
    
    NSDateComponents * components = [[NSDateComponents alloc] init];
    components.year = years;
    components.month = month;
    components.day = day;
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSLog(@"today==%@", today);
    
    //NSDate * currentDate = [NSDate date];
    NSDate * nextData = [calendar dateByAddingComponents:components toDate:today options:NSCalendarMatchStrictly];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString * str = [formatter stringFromDate:nextData];
    NSLog(@"%@",str);
    return str;
}
- (void)time{
    NSDateFormatter * dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [dateFormatter1 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//可能需要设置时区，此处设为东8即北京时间
    NSDate * questionDate = [dateFormatter1 dateFromString:@"2017-04-12 14:48:46"];//时间为2016-04-12 14:48:46 +0000
    
    NSString * date2 = @"2017-05-12 14:48:46";
    NSDate * answerDate = [dateFormatter1 dateFromString:date2];//时间为2016-04-12 14:57:58 +0000
    
    //转换为时间戳
    NSString * timeSp1 = [NSString stringWithFormat:@"%ld", (long)[questionDate timeIntervalSince1970]];
    NSString * timeSp2 = [NSString stringWithFormat:@"%ld", (long)[answerDate timeIntervalSince1970]];
    NSInteger time1 = [timeSp1 integerValue];//1460472526
    NSInteger time2 = [timeSp2 integerValue];//1460473078
    NSInteger response = time2 - time1;//552
    //        NSString * theResponse = [NSString stringWithFormat:@"%@", @(response)];//1970-01-01 00:09:12 +0000
    NSTimeInterval theResponse = response;
    NSDate * responseTimeInterval = [NSDate dateWithTimeIntervalSinceNow:theResponse];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    NSString * responseTime = [dateFormatter stringFromDate:responseTimeInterval];//输出结果00:09:12
    NSLog(@"%@",responseTime);
}
- (NSString *)intervalSinceNow: (NSString *) theDate
{
    NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
    theDate=[timeArray objectAtIndex:0];
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late-now;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@分", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@小时", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"剩余%@天", timeString];
        
    }
    return timeString;
}
//两个时间之差
- (NSString *)intervalFromLastDate: (NSString *) dateString1  toTheDate:(NSString *) dateString2
{
    NSArray *timeArray1=[dateString1 componentsSeparatedByString:@"."];
    dateString1=[timeArray1 objectAtIndex:0];
    
    
    NSArray *timeArray2=[dateString2 componentsSeparatedByString:@"."];
    dateString2=[timeArray2 objectAtIndex:0];
    
    NSLog(@"%@.....%@",dateString1,dateString2);
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDate *d1=[date dateFromString:dateString1];
    
    NSTimeInterval late1=[d1 timeIntervalSince1970]*1;
    
    
    
    NSDate *d2=[date dateFromString:dateString2];
    
    NSTimeInterval late2=[d2 timeIntervalSince1970]*1;
    
    
    
    NSTimeInterval cha=late2-late1;
    NSString *timeString=@"";
    NSString *house=@"";
    NSString *min=@"";
    NSString *sen=@"";
    
    sen = [NSString stringWithFormat:@"%d", (int)cha%60];
    //        min = [min substringToIndex:min.length-7];
    //    秒
    sen=[NSString stringWithFormat:@"%@", sen];
    
    
    
    min = [NSString stringWithFormat:@"%d", (int)cha/60%60];
    //        min = [min substringToIndex:min.length-7];
    //    分
    min=[NSString stringWithFormat:@"%@", min];
    
    
    //    小时
    house = [NSString stringWithFormat:@"%d", (int)cha/3600];
    //        house = [house substringToIndex:house.length-7];
    house=[NSString stringWithFormat:@"%@", house];
    
    
    timeString=[NSString stringWithFormat:@"%@:%@:%@",house,min,sen];
    
    
    return timeString;
}
//计算某个时间与此刻的时间间隔（天）
- (NSString *)dayIntervalFromNowtoDate:(NSString *)dateString
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:dateString];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate *dat = [NSDate date];
    NSString *nowStr = [date stringFromDate:dat];
    NSDate *nowDate = [date dateFromString:nowStr];
    
    NSTimeInterval now=[nowDate timeIntervalSince1970]*1;
    
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    timeString = [NSString stringWithFormat:@"%f", cha/86400];
    timeString = [timeString substringToIndex:timeString.length-7];
    
    if ([timeString intValue] < 0) {
        
        timeString = [NSString stringWithFormat:@"%d",-[timeString intValue]];
    }
    
    return timeString;
    
}
//计算某个时间与此刻的时间间隔（小时）
- (NSString *)hourIntervalFromNowtoDate:(NSString *)dateString
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:dateString];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate *dat = [NSDate date];
    NSString *nowStr = [date stringFromDate:dat];
    NSDate *nowDate = [date dateFromString:nowStr];
    
    NSTimeInterval now=[nowDate timeIntervalSince1970]*1;
    
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    timeString = [NSString stringWithFormat:@"%f", cha/3600];
    timeString = [timeString substringToIndex:timeString.length-7];
    
    if ([timeString intValue] < 0) {
        
        timeString = [NSString stringWithFormat:@"%d",-[timeString intValue]];
    }
    
    return timeString;
    
}
//计算某个时间与此刻的时间间隔（秒）
- (NSString *)secondIntervalFromNowtoDate:(NSString *)dateString
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss.0"];
    NSDate *d=[date dateFromString:dateString];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate *dat = [NSDate date];
    NSString *nowStr = [date stringFromDate:dat];
    NSDate *nowDate = [date dateFromString:nowStr];
    
    NSTimeInterval now=[nowDate timeIntervalSince1970]*1;
    
    NSTimeInterval cha=now-late;
    
    return [NSString stringWithFormat:@"%.0f",cha];;
    
}
- (void)aaa{
    
    NSString *expireDateStr = @"2017-08-26 14:00:00";
    NSDateComponents *dateCom = [self intervalSinceNowWithDataStr:expireDateStr];
    NSString *day1= [self dayIntervalFromNowtoDate:expireDateStr];
    NSString *hour1= [self hourIntervalFromNowtoDate:expireDateStr];
    NSString *sec1= [self secondIntervalFromNowtoDate:expireDateStr];
    
    NSString *data  = @"2016-08-30 00:00:00";
    NSDateComponents *dateCom2 = [self intervalSinceNowWithDataStr:data];
    NSString *day2= [self dayIntervalFromNowtoDate:data];
    NSString *hour2= [self hourIntervalFromNowtoDate:data];
    NSString *sec2= [self secondIntervalFromNowtoDate:data];
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%ld年%ld月%ld天 %ld小时%ld分%ld秒\n%ld年%ld月%ld天 %ld小时%ld分%ld秒",-dateCom.year,-dateCom.month,-dateCom.day,-dateCom.hour,-dateCom.minute,-dateCom.second,-dateCom2.year,-dateCom2.month,-dateCom2.day,-dateCom2.hour,-dateCom2.minute,-dateCom2.second]];
    [self.dayLabel setText:[NSString stringWithFormat:@"%@天\n%@天",day1,day2]];
    [self.hourLabel setText:[NSString stringWithFormat:@"%@小时\n%@小时",hour1,hour2]];
    [self.seclabel setText:[NSString stringWithFormat:@"%@秒\n%@秒",sec1,sec2]];
    
    
}
- (NSDateComponents *)intervalSinceNowWithDataStr:(NSString *)data{
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    dateFomatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.0";
    //    // 截止时间字符串格式
    //    NSString *expireDateStr = @"2017-01-31 14:00:00";
    // 当前时间字符串格式
    NSString *nowDateStr = [dateFomatter stringFromDate:nowDate];
    // 截止时间data格式
    NSDate *expireDate = [dateFomatter dateFromString:data];
    // 当前时间data格式
    nowDate = [dateFomatter dateFromString:nowDateStr];
    // 当前日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 需要对比的时间数据
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth
    | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 对比时间差
    NSDateComponents *dateCom = [calendar components:unit fromDate:nowDate toDate:expireDate options:0];
    //年差额 = dateCom.year, 月差额 = dateCom.month, 日差额 = dateCom.day, 小时差额 = dateCom.hour, 分钟差额 = dateCom.minute, 秒差额 = dateCom.second
    //NSLog(@"年差额 =%ld, 月差额 =%ld, 日差额 = %ld, 小时差额 = %ld, 分钟差额 = %ld, 秒差额 = %ld",dateCom.year,dateCom.month,dateCom.day,dateCom.hour,dateCom.minute,dateCom.second);
    return dateCom;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
