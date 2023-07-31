//
//  LJZTool.m
//  zimotv
//
//  Created by 李金柱 on 2017/2/23.
//  Copyright © 2017年 zimo. All rights reserved.
//



#import "LJZTool.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <CommonCrypto/CommonDigest.h>
#import <SSZipArchive/SSZipArchive.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static NSMutableArray  *_downLoadArray;

@implementation LJZTool
//动态 计算行高
//根据字符串的实际内容的多少 在固定的宽度和字体的大小，动态的计算出实际的高度
+ (CGFloat)textHeightFromTextString:(NSString *)text width:(CGFloat)textWidth fontName:(NSString *)fontName fontSize:(CGFloat)size{
    
    //iOS7之后
    /*
     第一个参数: 预设空间 宽度固定  高度预设 一个最大值
     第二个参数: 行间距
     第三个参数: 属性字典 可以设置字体大小
     */
    NSDictionary *dict;
    if (fontName) {
        dict = @{NSFontAttributeName:[UIFont fontWithName:fontName size:size]};
    }else{
        dict = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake(textWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:dict context:nil];
    //返回计算出的行高
    return rect.size.height;
    
}
//计算行宽
+ (CGFloat)textWidthtFromTextString:(NSString *)text height:(CGFloat)textHeight fontName:(NSString *)fontName fontSize:(CGFloat)size{
    
    //iOS7之后
    NSDictionary *dict;
    if (fontName) {
        dict = @{NSFontAttributeName:[UIFont fontWithName:fontName size:size]};
    }else{
        dict = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    }
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, textHeight) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:dict context:nil];
    //返回计算出的行高
    return rect.size.width;
    
}
//设置是否是有效密码
+ (BOOL)isAvailablePassword:(NSString *)password{
    
    NSString *ps = @"^[0-9_a-zA-Z]{6,20}$";
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",ps];
    if ([regex evaluateWithObject:password] == YES){
        return YES;
    }else{
        return NO;
    }
    
}
+ (BOOL)isMobileNumber:(NSString *)numstring{
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189,181
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186,181
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[156])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189,181
     */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:numstring] == YES)
        || ([regextestcm  evaluateWithObject:numstring] == YES)
        || ([regextestct  evaluateWithObject:numstring] == YES)
        || ([regextestcu  evaluateWithObject:numstring] == YES)
        || ([regextestphs evaluateWithObject:numstring] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//手机号验证
+ (BOOL)isPhoneNumber:(NSString *)number
{
    NSString *phoneRegex1=@"1[34578]([0-9]){9}";
    NSPredicate *phoneTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex1];
    return  [phoneTest1 evaluateWithObject:number];
}
//身份证验证
+ (BOOL)isAvalidateIdentityCard:(NSString *)identityCard
{
    if (identityCard.length <= 0) {
        return NO;
    }
    NSString *identityRegex = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",identityRegex];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//邮箱
+ (BOOL)isAvalidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
+ (UILabel *)creatLabelWithFrame:(CGRect)frame text:(NSString *)text fontName:(NSString *)fontName size:(CGFloat)size isAttribute:(BOOL)isAttribute{
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    if (fontName) {
        label.font = [UIFont fontWithName:fontName size:size];
    }else{
        label.font = [UIFont systemFontOfSize:size];
    }
    
    if (isAttribute&&![LJZTool isBlankString:text]) {
        NSAttributedString *attributedString =[[NSAttributedString alloc] initWithString:text attributes:@{NSKernAttributeName : @(1.75f)}];
        [label setAttributedText:attributedString];
    }else{
        label.text = text;
    }
    
    return label;
}
+ (UIButton *)creatButtonWithFrame:(CGRect)frame target:(id)target sel:(SEL)sel title:(NSString *)title{
    
    UIButton *button = nil;
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    if (title) {
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}
+ (UIButton *)creatButtonWithFrame:(CGRect)frame target:(id)target sel:(SEL)sel tag:(NSInteger)tag image:(NSString *)name title:(NSString *)title{
    
    UIButton *button = nil;
    if (name) {
        //创建背景图片 按钮
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
        
        if (title) {//标题按钮
            
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            
        }
        
    }else if (title) {
        //创建标题按钮
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    button.frame = frame;
    button.tag = tag;
    [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}
//判断是否是空字符串
+ (BOOL) isBlankString:(NSString *)string {
    
    if (string == nil
        ||string == NULL
        ||[string isKindOfClass:[NSNull class]]
        ||[[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        
        return YES;
        
    }else{
        return NO;
    }
    
}
//获取iOS版本号
+ (double)getCurrentIOS {
    return [[[UIDevice currentDevice] systemVersion] doubleValue];
}

//把一个秒字符串 转化为真正的本地时间
+ (NSString *)dateStringFromNumberTimer:(NSString *)timerStr{
    //转化为Double
    double t = [timerStr doubleValue];
    //计算出距离1970的NSDate
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t];
    //转化为 时间格式化字符串
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    //转化为 时间字符串
    return [df stringFromDate:date];
}
//获取 一个文件 在沙盒Library/Caches/ 目录下的路径
+ (NSString *)getFullPathWithFile:(NSString *)urlName {
    
    //先获取 沙盒中的Library/Caches/路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *myCacheDirectory = [docPath stringByAppendingPathComponent:@"AppCaches"];
    //检测Caches 文件夹是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:myCacheDirectory]) {
        //不存在 那么创建
        [[NSFileManager defaultManager] createDirectoryAtPath:myCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //拼接路径
    return [myCacheDirectory stringByAppendingPathComponent:urlName];
    return myCacheDirectory;
}

//检测 缓存文件 是否超时
+ (BOOL)isTimeOutWithFile:(NSString *)filePath timeOut:(double)timeOut
{
    //获取文件的属性
    NSDictionary *fileDict = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    //获取文件的上次的修改时间
    NSDate *lastModfyDate = fileDict.fileModificationDate;
    //算出时间差 获取当前系统时间 和 lastModfyDate时间差
    NSTimeInterval sub = [[NSDate date] timeIntervalSinceDate:lastModfyDate];
    if (sub < 0) {
        sub = -sub;
    }
    //比较是否超时
    if (sub > timeOut) {
        //如果时间差 大于 设置的超时时间 那么就表示超时
        return YES;
    }
    return NO;

}


//json字符串转对象
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
   
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     }];
    
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (void)downLoadL2dModelWithUrl:(NSString *)url complete:(nullable void (^)(BOOL))complete{
    NSString *zipPath = [[NSFileManager pathForLive2dZip] stringByAppendingFormat:@"/%@.zip",[self md5String:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath] || ![url containsString:@"http"]){
        return;
    }
    if (!_downLoadArray) {
        _downLoadArray = [[NSMutableArray alloc]init];
    }
    if ([_downLoadArray containsObject:zipPath]) {
        return;
    }
    [_downLoadArray addObject:zipPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        WeakObj(self)
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLSessionDownloadTask *downTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            CGFloat progress = 1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
            NSLog(@"模型资源下载进度 %f",progress);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSLog(@"savePath==%@",zipPath);
            return [NSURL fileURLWithPath:zipPath];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                NSString *modelPath = [[NSFileManager pathForLive2dModel] stringByAppendingFormat:@"/%@", [selfWeak getl2dNameWithZipUrl:url]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:modelPath]){
                    [[NSFileManager defaultManager]removeItemAtPath:modelPath error:nil];
                }
                [selfWeak unZipL2dFileAtpath:zipPath complete:complete];
            }else{
                NSLog(@"模型资源下载失败：%@",error);
                !complete ? : complete(NO);
            }
        }];
        
        [downTask resume];
        
    }
}
+ (NSString *)getl2dNameWithZipUrl:(NSString *)zipUrl{
    NSArray *items = [zipUrl componentsSeparatedByString:@"/"];
    NSArray *lastItems = [items.lastObject componentsSeparatedByString:@"."];
    return lastItems.firstObject;
}
+ (NSString *)md5String:(NSString *)str
{
    const char *ptr = [str UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }
    
    return [output copy];
}
+ (void)unZipL2dFileAtpath:(NSString *)filePath complete:(nullable void (^)(BOOL))complete{
    [_downLoadArray removeObject:filePath];
    NSString *desPath =[NSFileManager pathForLive2dModel];

    BOOL sucess = [SSZipArchive unzipFileAtPath:filePath toDestination:desPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
       
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
      
    }];
    !complete ? : complete(sucess);
    NSLog(@"模型资源解压%@",sucess?@"成功":@"失败");
}
+ (NSString *)getLipTypeWithString:(NSString *)word{
    NSString *pinyin = [NSString pinyinFromChineseString:word];
    NSLog(@"word==1=%@=%@=%@",word,pinyin,word.pinYin);

    return [NSString stringWithFormat:@"%@_%@",[self getPrefixWithPinyin:pinyin],[self getSubffixWithPinyin:pinyin]];
}
+ (NSString *)getPrefixWithPinyin:(NSString*)pinyin{
    /**15个口型 对应的口型参数 sil,PP,FF,TH,DD,kk,CH,SS,nn,RR,aa,E,ih,oh,ou, 严格按照顺序取值 index为key value为参数字符串 mf_mY*/
    NSDictionary *dic = @{@"0":@"0_0",
             @"1":@"-0.9_0",
             @"2":@"-0.9_0.2",
             @"3":@"-0.9_0.5",
             @"4":@"-0.2_0.6",
             @"5":@"0.3_0.5",
             @"6":@"-0.7_0.6",
             @"7":@"0.3_0.2",
             @"8":@"-0.9_0.5",
             @"9":@"-0.8_0.3",
             @"10":@"0.2_0.5",
             @"11":@"0.7_0.3",
             @"12":@"0.8_0.3",
             @"13":@"-0.8_0.8",
             @"14":@"-0.8_0.5",
    };
    //B口型 发音时双唇由闭合到打开，嘴型向外撅
    if ([pinyin hasPrefix:@"b"] ||
        [pinyin hasPrefix:@"m"] ||
        [pinyin hasPrefix:@"p"]) {
        return @"-0.9";//@"B";//-0.9
    }
    //F口型 发音时双唇由闭合到打开，咬唇
    if ([pinyin hasPrefix:@"f"]) {
        return @"-0.9";//@"F";//-0.9
    }
    //D口型 发音时嘴唇微微张开
    if ([pinyin hasPrefix:@"c"] ||
        [pinyin hasPrefix:@"d"] ||
        [pinyin hasPrefix:@"t"] ||
        [pinyin hasPrefix:@"n"] ||
        [pinyin hasPrefix:@"l"] ||
        [pinyin hasPrefix:@"g"] ||
        [pinyin hasPrefix:@"k"] ||
        [pinyin hasPrefix:@"h"] ||
        [pinyin hasPrefix:@"j"] ||
        [pinyin hasPrefix:@"q"] ||
        [pinyin hasPrefix:@"x"] ||
        [pinyin hasPrefix:@"zh"] ||
        [pinyin hasPrefix:@"chi"] ||
        [pinyin hasPrefix:@"sh"] ||
        [pinyin hasPrefix:@"r"] ||
        [pinyin hasPrefix:@"z"] ||
        [pinyin hasPrefix:@"s"]) {
        return @"0.7";//@"D";//0.7
    }
    //U口型 发音时嘴唇张开幅度较小，嘴型非圆形向前撅
    if ([pinyin hasPrefix:@"w"]) {
        return @"0.3";//@"U";//0.3
    }
    //E口型 发音时嘴唇张开幅度较小，嘴型非圆形并向两侧伸展
    if ([pinyin hasPrefix:@"y"]) {
        return @"0.2";//@"E";//0.2
    }
    return @"0";
}
+ (NSString *)getSubffixWithPinyin:(NSString*)pinyin{
    //A口型 发音时嘴唇张开幅度较大，嘴型呈非圆形
    if ([pinyin containsString:@"a"] ||
        [pinyin containsString:@"ai"] ||
        [pinyin containsString:@"an"] ||
        [pinyin containsString:@"ang"] ||
        [pinyin containsString:@"ao"] ||
        [pinyin containsString:@"ia"] ||
        [pinyin containsString:@"ian"] ||
        [pinyin containsString:@"iao"] ||
        [pinyin containsString:@"ua"] ||
        [pinyin containsString:@"uai"] ||
        [pinyin containsString:@"uan"] ||
        [pinyin containsString:@"uang"]) {
        return @"0.5";//@"A";//0.5
    }
    //O口型 发音时嘴唇张开幅度较大，嘴型呈圆形
    if ([pinyin containsString:@"o"] ||
        [pinyin containsString:@"ou"] ||
        [pinyin containsString:@"ong"] ||
        [pinyin containsString:@"uo"] ||
        [pinyin containsString:@"iong"]) {
        return @"0.8";//@"O";//0.8
    }
    
    //E口型 发音时嘴唇张开幅度较小，嘴型非圆形并向两侧伸展
    if ([pinyin containsString:@"e"] ||
        [pinyin containsString:@"i"] ||
        [pinyin containsString:@"ie"] ||
        [pinyin containsString:@"er"] ||
        [pinyin containsString:@"ei"] ||
        [pinyin containsString:@"uei"] ||
        [pinyin containsString:@"en"] ||
        [pinyin containsString:@"in"] ||
        [pinyin containsString:@"uen"] ||
        [pinyin containsString:@"eng"] ||
        [pinyin containsString:@"ing"] ||
        [pinyin containsString:@"ueng"] ||
        [pinyin containsString:@"y"]) {
        return @"0.2";//@"E";//0.2
    }
    
    //U口型 发音时嘴唇张开幅度较小，嘴型非圆形向前撅
    if ([pinyin containsString:@"u"] ||
        [pinyin containsString:@"ve"] ||
        [pinyin containsString:@"iou"] ||
        [pinyin containsString:@"un"] ||
        [pinyin containsString:@"ui"] ) {
        return @"0.2";//@"U";//0.2
    }
    return @"0";
}
@end
