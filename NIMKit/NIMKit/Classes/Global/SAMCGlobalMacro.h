//
//  SAMCGlobalMacro.h
//  NIMKit
//
//  Created by HJ on 11/23/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#ifndef SAMCGlobalMacro_h
#define SAMCGlobalMacro_h


#pragma mark - UIColor宏定义
#define SAMCUIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define SAMCUIColorFromRGB(rgbValue) SAMCUIColorFromRGBA(rgbValue, 1.0)

#define SAMC_COLOR_INGRABLUE                    SAMCUIColorFromRGB(0x1D4D73)
#define SAMC_COLOR_SKYBLUE                      SAMCUIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_GREEN                        SAMCUIColorFromRGB(0x67D45F)
#define SAMC_COLOR_LEMMON                       SAMCUIColorFromRGB(0xD1F43B)
#define SAMC_COLOR_LAKE                         SAMCUIColorFromRGB(0x2676B6)
#define SAMC_COLOR_DARKBLUE                     SAMCUIColorFromRGB(0x1B3257)
#define SAMC_COLOR_INK                          SAMCUIColorFromRGB(0x13243F)
#define SAMC_COLOR_LIME                         SAMCUIColorFromRGB(0x0CAC0C)
#define SAMC_COLOR_RED                          SAMCUIColorFromRGB(0xDC374B)
#define SAMC_COLOR_LIGHTGREY                    SAMCUIColorFromRGB(0xECEDF0)
#define SAMC_COLOR_LIMEGREY                     SAMCUIColorFromRGB(0xD8DCE2)
#define SAMC_COLOR_GREY                         SAMCUIColorFromRGB(0xA2AEBC)
#define SAMC_COLOR_CHARCOAL                     SAMCUIColorFromRGB(0x030303)
#define SAMC_COLOR_DARKBLUE_GRADIENT_DARK       SAMCUIColorFromRGB(0x1B3257)
#define SAMC_COLOR_DARKBLUE_GRADIENT_LIGHT      SAMCUIColorFromRGB(0x1D4D73)
#define SAMC_COLOR_LIGHTBLUE_GRADIENT_DARK      SAMCUIColorFromRGB(0x2676B6)
#define SAMC_COLOR_LIGHTBLUE_GRADIENT_LIGHT     SAMCUIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_GRASSFIELD_GRADIENT_DARK     SAMCUIColorFromRGB(0x20CB9D)
#define SAMC_COLOR_GRASSFIELD_GRADIENT_LIGHT    SAMCUIColorFromRGB(0x80E22F)
#define SAMC_COLOR_HORIZON_GRADIENT_DARK        SAMCUIColorFromRGB(0x2EBDEF)
#define SAMC_COLOR_HORIZON_GRADIENT_LIGHT       SAMCUIColorFromRGB(0xD1F43B)

#define SAMC_COLOR_WHITE_HINT                   SAMCUIColorFromRGBA(0xFFFFFF, 0.5)
#define SAMC_COLOR_INK_HINT                     SAMCUIColorFromRGBA(0x13243F, 0.5)

#endif /* SAMCGlobalMacro_h */
