#if __has_include(<GPUImage/GPUImageFilter.h>)
#import <GPUImage/GPUImageFilter.h>
#else
#import "GPUImageFilter.h"
#endif

@interface YKBeautyPlusFilter : GPUImageFilter {
    GLfloat redAvg;
    GLfloat greenAvg;
    GLfloat blueAvg;
    GLfloat colorR0[200];
    GLfloat colorR1[56];
    GLfloat colorG0[200];
    GLfloat colorG1[56];
    GLfloat colorB0[200];
    GLfloat colorB1[56];
}

/** 美颜, 默认是NO */
@property (nonatomic, assign) BOOL beauty;
/** 磨皮程度 0 ~ 1.0, 默认值 0.5 */
@property (nonatomic, assign) CGFloat beautyLevel;
/** 美白程度 0 ~ 1.0, 默认值 0.5 */
@property (nonatomic, assign) CGFloat brightLevel;

@end
