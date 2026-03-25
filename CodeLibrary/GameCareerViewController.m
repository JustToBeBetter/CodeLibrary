//
//  GameCareerViewController.m
//  CodeLibrary
//
//  Rect 实现图片布局 — 游戏生涯页面
//

#import "GameCareerViewController.h"

// ─── Design constants ────────────────────────────────────────────────────────
static CGFloat const kBannerHeight      = 250.f;
static CGFloat const kAvatarSize        = 40.f;
static CGFloat const kPillHeight        = 52.f;
static CGFloat const kSectionBarW       = 4.f;
static CGFloat const kSectionBarH       = 18.f;
static CGFloat const kCardHeight        = 120.f;
static CGFloat const kBadgeSize         = 80.f;
static CGFloat const kCardHPad          = 12.f;
static CGFloat const kEdgePad           = 16.f;

// ─── Helpers ─────────────────────────────────────────────────────────────────

/// A solid-color image used as a placeholder where a real asset is absent.
static UIImage *PlaceholderImage(UIColor *color, CGSize size) {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/// Return the hex color #0F2A4A (deep-sea navy).
static UIColor *NavyColor(void) {
    return [UIColor colorWithRed:0x0F/255.f green:0x2A/255.f blue:0x4A/255.f alpha:1.f];
}

/// Return the hex color #1A3A5C (card background).
static UIColor *CardColor(void) {
    return [UIColor colorWithRed:0x1A/255.f green:0x3A/255.f blue:0x5C/255.f alpha:1.f];
}

// ─── View controller ─────────────────────────────────────────────────────────

@interface GameCareerViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation GameCareerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"游戏生涯";
    self.view.backgroundColor = NavyColor();

    [self setupScrollView];
    [self setupBanner];
    [self setupSectionWithTitle:@"巅峰赛战绩"
                    totalGames:@"0"
                       winRate:@"0"
                          topY:kBannerHeight + 20.f
                     badgeColor:[UIColor colorWithRed:0.6f green:0.5f blue:0.1f alpha:1.f]];
    [self setupSectionWithTitle:@"竞技赛"
                    totalGames:@"9999"
                       winRate:@"66%"
                          topY:kBannerHeight + 20.f + kSectionBarH + 16.f + kCardHeight + 28.f
                     badgeColor:[UIColor colorWithRed:0.7f green:0.55f blue:0.1f alpha:1.f]];

    CGFloat totalH = kBannerHeight + 20.f
                   + (kSectionBarH + 16.f + kCardHeight + 28.f) * 2;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, totalH + 40.f);
}

// ─── Setup helpers ────────────────────────────────────────────────────────────

- (void)setupScrollView {
    CGRect frame = self.view.bounds;
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.backgroundColor = NavyColor();
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
}

/// Builds the full-width banner and the user-info pill overlay.
- (void)setupBanner {
    CGFloat W = self.view.bounds.size.width;

    // Banner image
    UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, W, kBannerHeight)];
    banner.contentMode = UIViewContentModeScaleAspectFill;
    banner.clipsToBounds = YES;
    // Use a sky-blue gradient placeholder; swap with a real image asset as needed.
    banner.image = PlaceholderImage([UIColor colorWithRed:0.53f green:0.81f blue:0.98f alpha:1.f],
                                    CGSizeMake(W, kBannerHeight));
    [self.scrollView addSubview:banner];

    // User-info pill  (avatar ＋ nickname, dark semi-transparent background)
    CGFloat pillW  = 170.f;
    CGFloat pillX  = kEdgePad;
    CGFloat pillY  = kBannerHeight - kPillHeight - 12.f;
    UIView *pill   = [[UIView alloc] initWithFrame:CGRectMake(pillX, pillY, pillW, kPillHeight)];
    pill.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.65f];
    pill.layer.cornerRadius = kPillHeight / 2.f;
    pill.clipsToBounds = YES;
    [self.scrollView addSubview:pill];

    // Avatar circle
    UIImageView *avatar = [[UIImageView alloc]
        initWithFrame:CGRectMake(6, (kPillHeight - kAvatarSize) / 2.f, kAvatarSize, kAvatarSize)];
    avatar.contentMode  = UIViewContentModeScaleAspectFill;
    avatar.clipsToBounds = YES;
    avatar.layer.cornerRadius = kAvatarSize / 2.f;
    avatar.image = PlaceholderImage([UIColor systemGrayColor], CGSizeMake(kAvatarSize, kAvatarSize));
    [pill addSubview:avatar];

    // Nickname label
    CGFloat lblX   = avatar.frame.origin.x + kAvatarSize + 8.f;
    CGFloat lblW   = pillW - lblX - 8.f;
    UILabel *name  = [[UILabel alloc]
        initWithFrame:CGRectMake(lblX, 0, lblW, kPillHeight)];
    name.text      = @"我是用户昵称";
    name.textColor = [UIColor whiteColor];
    name.font      = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    [pill addSubview:name];
}

/**
 * Builds one "section" composed of:
 *   • a section-title row  (colored bar ＋ label)
 *   • a card view with badge image on the left and two stat columns on the right
 *
 * @param title      Section heading text.
 * @param totalGames Value shown under 总场次.
 * @param winRate    Value shown under 胜率.
 * @param topY       Y origin inside the scroll view.
 * @param badgeColor Tint color for the rank-badge placeholder.
 */
- (void)setupSectionWithTitle:(NSString *)title
                   totalGames:(NSString *)totalGames
                      winRate:(NSString *)winRate
                         topY:(CGFloat)topY
                    badgeColor:(UIColor *)badgeColor {

    CGFloat W   = self.view.bounds.size.width;
    CGFloat curY = topY;

    // ── Section title row ────────────────────────────────────────────────────
    UIView *bar = [[UIView alloc]
        initWithFrame:CGRectMake(kEdgePad, curY, kSectionBarW, kSectionBarH)];
    bar.backgroundColor = [UIColor colorWithRed:0.98f green:0.78f blue:0.12f alpha:1.f];
    bar.layer.cornerRadius = kSectionBarW / 2.f;
    [self.scrollView addSubview:bar];

    UILabel *sectionLbl = [[UILabel alloc]
        initWithFrame:CGRectMake(kEdgePad + kSectionBarW + 6.f, curY,
                                 200.f, kSectionBarH)];
    sectionLbl.text      = title;
    sectionLbl.textColor = [UIColor whiteColor];
    sectionLbl.font      = [UIFont systemFontOfSize:16.f weight:UIFontWeightSemibold];
    [self.scrollView addSubview:sectionLbl];
    curY += kSectionBarH + 10.f;

    // ── Card ─────────────────────────────────────────────────────────────────
    CGFloat cardX = kEdgePad;
    CGFloat cardW = W - kEdgePad * 2.f;
    UIView *card  = [[UIView alloc]
        initWithFrame:CGRectMake(cardX, curY, cardW, kCardHeight)];
    card.backgroundColor    = CardColor();
    card.layer.cornerRadius = 12.f;
    card.clipsToBounds       = YES;
    [self.scrollView addSubview:card];

    // Badge image (left column)
    CGFloat badgeX = kCardHPad;
    CGFloat badgeY = (kCardHeight - kBadgeSize) / 2.f - 6.f;
    UIImageView *badge = [[UIImageView alloc]
        initWithFrame:CGRectMake(badgeX, badgeY, kBadgeSize, kBadgeSize)];
    badge.contentMode = UIViewContentModeScaleAspectFit;
    badge.image = PlaceholderImage(badgeColor, CGSizeMake(kBadgeSize, kBadgeSize));
    badge.layer.cornerRadius = 8.f;
    badge.clipsToBounds = YES;
    [card addSubview:badge];

    // Badge rank name label (below badge)
    UILabel *badgeName = [[UILabel alloc]
        initWithFrame:CGRectMake(badgeX, badgeY + kBadgeSize + 2.f, kBadgeSize, 16.f)];
    badgeName.text          = @"xxxx";
    badgeName.textColor     = [UIColor colorWithRed:0.98f green:0.78f blue:0.12f alpha:1.f];
    badgeName.font          = [UIFont systemFontOfSize:12.f weight:UIFontWeightMedium];
    badgeName.textAlignment = NSTextAlignmentCenter;
    [card addSubview:badgeName];

    // Separator vertical line
    CGFloat sepX   = badgeX + kBadgeSize + kCardHPad;
    CGFloat sepH   = kCardHeight - 24.f;
    UIView *sep    = [[UIView alloc]
        initWithFrame:CGRectMake(sepX, 12.f, 0.5f, sepH)];
    sep.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.15f];
    [card addSubview:sep];

    // Right content area (two columns: 总场次 | 胜率)
    CGFloat rightX  = sepX + 1.f + kCardHPad;
    CGFloat rightW  = cardW - rightX - kCardHPad;
    CGFloat colW    = rightW / 2.f;
    CGFloat valFontSize  = 28.f;
    CGFloat subFontSize  = 12.f;
    CGFloat valH    = 36.f;
    CGFloat subH    = 18.f;
    CGFloat valY    = (kCardHeight - valH - 4.f - subH) / 2.f;
    CGFloat subY    = valY + valH + 4.f;

    NSArray<NSString *> *values  = @[totalGames, winRate];
    NSArray<NSString *> *subtitles = @[@"总场次", @"胜率"];

    for (NSInteger i = 0; i < 2; i++) {
        CGFloat colX = rightX + colW * i;

        UILabel *valLbl = [[UILabel alloc]
            initWithFrame:CGRectMake(colX, valY, colW, valH)];
        valLbl.text          = values[i];
        valLbl.textColor     = [UIColor whiteColor];
        valLbl.font          = [UIFont systemFontOfSize:valFontSize weight:UIFontWeightSemibold];
        valLbl.textAlignment = NSTextAlignmentCenter;
        [card addSubview:valLbl];

        UILabel *subLbl = [[UILabel alloc]
            initWithFrame:CGRectMake(colX, subY, colW, subH)];
        subLbl.text          = subtitles[i];
        subLbl.textColor     = [UIColor colorWithWhite:0.7f alpha:1.f];
        subLbl.font          = [UIFont systemFontOfSize:subFontSize];
        subLbl.textAlignment = NSTextAlignmentCenter;
        [card addSubview:subLbl];
    }
}

@end
