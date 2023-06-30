#import "YKBeautyPlusFilter.h"

#define MIN_GAIN            4
#define MAX_GAIN            15
#define MIN2(a, b)          ((a > b) ? b : a)
#define MAX2(a, b)          ((a > b) ? a : b)
#define CLIP3(x, min, max)  ((x > min) ? (x < max ? x : max) : min)

typedef NS_ENUM(NSInteger, curveColor) {
    CURVE_RED,
    CURVE_GREEN,
    CURVE_BLUE
};

NSString *const kZQBeautyPlusFilterFragmentShaderString = SHADER_STRING
                                                        (
    varying highp vec2 textureCoordinate;

    uniform sampler2D inputImageTexture;
    
    uniform highp int beauty;
    uniform highp float width;
    uniform highp float height;
    uniform highp float mvSmoothSize;
                                                         
    uniform lowp float curveR0[200];
    uniform lowp float curveR1[56];
    uniform highp float curveG0[200];
    uniform highp float curveG1[56];
    uniform highp float curveB0[200];
    uniform highp float curveB1[56];
                                                        
    highp float mv_green_mix(highp float g1, highp float g2) {
        highp float g = g2 + 1.0 - 2.0 * g1;
        g = clamp(g, 0.0, 1.0);
        return mix(g, g2, 0.5);
    }
                                                         
    highp float mv_high_mix(highp float hg, highp float flag) {
        highp float g = clamp(hg, 0.0001, 0.9999);
        return mix(g/(2.0*(1.0-g)), 1.0 - (1.0-g)/(2.0*g), flag);
    }
                                                     
    lowp int is_skin(highp vec4 color) {
         lowp float max_c = max(color.r, max(color.g, color.b));
         lowp float min_c = min(color.r, min(color.g, color.b));
         lowp float rg = abs(color.r - color.g);
         if (color.r > 95.0/255.0 && color.g > 40.0/255.0 && color.b > 20.0/255.0 && rg > 15.0/255.0 &&
            (max_c - min_c) > 15.0/255.0 && color.r > color.g && color.r > color.b) {
             return true;
         } else {
             return false;
         }
     }

    void main() {
        highp vec2 uv  = textureCoordinate.xy;
        highp vec4 init_color = texture2D(inputImageTexture, textureCoordinate);
        lowp int skin = is_skin(init_color);
        if (beauty == 1 && skin == 1) {
            highp float addnum = 8.0;
            highp vec4 blur_color = init_color * addnum;
            highp float threth = 30.0/255.0;
            highp float location_x = 1.0 / width;
            highp float location_y = 1.0 / height;
            highp vec4 compare_color = texture2D(inputImageTexture, textureCoordinate + mvSmoothSize*vec2( -4.0 * location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += compare_color;
                addnum += 1.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + mvSmoothSize*vec2( -3.0 * location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + mvSmoothSize*vec2( -2.0 * location_x,  0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + mvSmoothSize*vec2( -1.0 * location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 3.0 *compare_color;
                addnum += 3.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 4.0 * location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += compare_color;
                addnum += 1.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 3.0 * location_x,  0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 2.0 * location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0 *compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( location_x, 0.0));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 3.0*compare_color;
                addnum += 3.0;
            }
            
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0,  -4.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += compare_color;
                addnum += 1.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, -3.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, -2.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, -1.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 3.0*compare_color;
                addnum += 3.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0,  4.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += compare_color;
                addnum += 1.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, 3.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, 2.0 * location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 2.0*compare_color;
                addnum += 2.0;
            }
            compare_color = texture2D(inputImageTexture, textureCoordinate + 1.0 * mvSmoothSize*vec2( 0.0, location_y));
            if(abs(compare_color.r - init_color.r) < threth)
            {
                blur_color += 3.0*compare_color;
                addnum += 3.0;
            }
            blur_color /= addnum;
            
            //highpass
            highp float hg = mv_green_mix(blur_color.r, init_color.r);
            highp float flag = step(hg, 0.5);
            hg = mv_high_mix(hg, flag);
            hg = mv_high_mix(hg, flag);
            hg = mv_high_mix(hg, flag);
            
            hg = clamp(hg, 0.0, 1.0);
            if(hg > 0.2){
                hg = pow((hg - 0.2) * 1.25, 0.5)*0.8 + 0.2;
            }
            hg = 1.0 - hg;
            hg = hg + 0.6;
            hg = clamp(hg, 0.0, 1.0);
            hg = hg - 0.6;
            hg = clamp(hg, 0.0, 1.0);
            hg = (hg-0.2)*4.0;
            hg = (hg-0.7)*2.0;
            hg = clamp(hg, 0.0, 1.0);
            highp vec4 diff = init_color - blur_color;
            blur_color += vec4(diff.r*hg, diff.r*hg, diff.r*hg, 0.0);
            blur_color = clamp(blur_color, vec4(0.0, 0.0, 0.0, 0.0), vec4(1.0, 1.0, 1.0, 1.0));
            
            gl_FragColor = blur_color.rgba;
            
//            int index = 0;
//            index = int(blur_color.r*255.0);
//            if (index < 200) {
//                blur_color.r = curveR0[index];
//            } else {
//                blur_color.r = curveR1[index-200];
//            }
//            index = int(blur_color.g*255.0);
//            if (index < 200) {
//                blur_color.g = curveG0[index];
//            } else {
//                blur_color.g = curveG1[index-200];
//            }
//            index = int(blur_color.b*255.0);
//            if (index < 200) {
//                blur_color.b = curveB0[index];
//            } else {
//                blur_color.b = curveB1[index-200];
//            }
//
//            gl_FragColor = blur_color.rgba;
        } else {
            gl_FragColor = init_color.rgba;
        }
    }
);

@implementation YKBeautyPlusFilter

- (id)init {
    if (!(self = [super initWithFragmentShaderFromString:kZQBeautyPlusFilterFragmentShaderString])) {
        return nil;
    }

    _beautyLevel = 0.5;
    _brightLevel = 0.5;
    
    redAvg = 0.0f;
    greenAvg = 0.0f;
    blueAvg = 0.0f;
    memset(colorR0, 0, sizeof(colorR0));
    memset(colorR1, 0, sizeof(colorR1));
    memset(colorG0, 0, sizeof(colorG0));
    memset(colorG1, 0, sizeof(colorG1));
    memset(colorB0, 0, sizeof(colorB0));
    memset(colorB1, 0, sizeof(colorB1));
    
    [self setBeautyLevel:_beautyLevel];
    [self setBrightLevel:_brightLevel];
    [self setBeauty:NO];
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
    inputTextureSize = newSize;

    [self setFloat:inputTextureSize.width forUniformName:@"width"];
    [self setFloat:inputTextureSize.height forUniformName:@"height"];
}

- (void)setBeauty:(BOOL)beauty {
    _beauty = beauty;
    [self setInteger:_beauty forUniformName:@"beauty"];
}

- (void)setBeautyLevel:(CGFloat)beautyLevel {
    _beautyLevel = beautyLevel;
    [self setFloat: _beautyLevel * 6 forUniformName:@"mvSmoothSize"];
}

- (void)setBrightLevel:(CGFloat)brightLevel {
    _brightLevel = 0.5 - brightLevel;
    [self updateColorCurveRed:190 + brightLevel * 50 Green:145 Blue:125];
    [self setFloatArray:colorR0 length:200 forUniform:@"curveR0"];
    [self setFloatArray:colorR1 length:56 forUniform:@"curveR1"];
    [self setFloatArray:colorG0 length:200 forUniform:@"curveG0"];
    [self setFloatArray:colorG1 length:56 forUniform:@"curveG1"];
    [self setFloatArray:colorB0 length:200 forUniform:@"curveB0"];
    [self setFloatArray:colorB1 length:56 forUniform:@"curveB1"];
}

- (void)updateColorCurveRed:(int)red Green:(int)green Blue:(int)blue {
    if (red != redAvg) {
        redAvg = red;
        [self getCurveColor:CURVE_RED avgBrightness:redAvg];
    }
    if (green != greenAvg) {
        greenAvg = green;
        [self getCurveColor:CURVE_GREEN avgBrightness:greenAvg];
    }
    if (blue != blueAvg) {
        blueAvg = blue;
        [self getCurveColor:CURVE_BLUE avgBrightness:blueAvg];
    }
}

- (void)getCurveColor:(curveColor)_curveColor avgBrightness:(int)average_brightness {
    float m_gainAdjust = 1.0;
  
    int x1 = (int) (average_brightness * 0.3f);
    int x2 = (int) (average_brightness + (255 - average_brightness) * 0.5f);
    
    int gain1 = (int) (x1 * 2.5);
    gain1 = MAX2(gain1, MIN_GAIN);
    
    int gain2 = (int) (gain1 * (1.1f + (255 - average_brightness) / 255.0f));
    gain2 = MIN2(gain2, MAX_GAIN);
    
    float a, b, c, target_curve[256];
    
    a = 4.0f * gain1 / (x1 * x1);
    b = 1.0f - a * x1;
    
    for(int i=0; i<x1; i++) {
        target_curve[i] = CLIP3((int)(a * i * i + b * i), 0, 255);
        target_curve[i] = ((1.0f-m_gainAdjust)*(float)i + m_gainAdjust*target_curve[i])/255.0f;
    }
    
    float dis = (x2 - x1) * 0.5f;
    a = gain2 / (dis * dis - gain2 * gain2);
    b = 1.0f - a * (x1 +x2);
    c = a * x1 * x2;
    target_curve[x1] = x1/255.0f;
    
    for(int i=x1 + 1; i<x2; i++) {
        int result = (int) ((sqrtf(b * b - 4.0f * a * (c - i)) - b) / (2.0f * a) + 0.5f);
        target_curve[i] = (float)CLIP3(result, 0, 255);
        target_curve[i] = ((1.0f-m_gainAdjust)*(float)i + m_gainAdjust*target_curve[i])/255.0f;
    }
    
    for(int i = x2; i<256; i++) {
        target_curve[i] = (float)i/255.0f;
    }
    
    if (CURVE_RED == _curveColor) {
        memcpy(colorR0, &target_curve[0], sizeof(float)*200);
        memcpy(colorR1, &target_curve[200], sizeof(float)*56);
    } else if (CURVE_GREEN == _curveColor) {
        memcpy(colorG0, &target_curve[0], sizeof(float)*200);
        memcpy(colorG1, &target_curve[200], sizeof(float)*56);
    } else if (CURVE_BLUE == _curveColor) {
        memcpy(colorB0, &target_curve[0], sizeof(float)*200);
        memcpy(colorB1, &target_curve[200], sizeof(float)*56);
    }
    
    return;
}

@end

