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

#define SAMC_COLOR_BODY_MID                     SAMCUIColorFromRGBA(0x13243F, 0.6)
#define SAMC_COLOR_NAV_LIGHT                    SAMCUIColorFromRGB(0xF8F9F9)
#define SAMC_COLOR_NAV_DARK                     SAMCUIColorFromRGB(0x13243F)

#define SAMC_COLOR_RGB_GREEN                    0x67D45F
#define SAMC_COLOR_RGB_INK                      0x13243F
#define SAMC_COLOR_RGB_LEMMON                   0xD1F43B
#define SAMC_COLOR_RGB_LAKE                     0x2676B6
#define SAMC_COLOR_RGB_INGRABLUE                0x1D4D73


#define MESSAGE_EXT_FROM_USER_MODE_KEY          @"msg_from"
#define MESSAGE_EXT_FROM_USER_MODE_VALUE_CUSTOM @(0)
#define MESSAGE_EXT_FROM_USER_MODE_VALUE_SP     @(1)

#define MESSAGE_EXT_UNREAD_FLAG_KEY         @"unread_flag"
#define MESSAGE_EXT_UNREAD_FLAG_YES         @(YES)
#define MESSAGE_EXT_UNREAD_FLAG_NO          @(NO)

#define MESSAGE_EXT_QUESTION_ID_KEY         @"quest_id"
#define MESSAGE_EXT_PUBLIC_ID_KEY           @"adv_id"

#define MESSAGE_EXT_SAVE_FLAG_KEY           @"save_flag"
#define MESSAGE_EXT_SAVE_FLAG_YES           @(YES)
#define MESSAGE_EXT_SAVE_FLAG_NO            @(NO)

#define MESSAGE_LOCAL_EXT_DELIVERYSTATE_KEY @"delivery_state"

#define CALL_MESSAGE_EXTERN_FROM_CUSTOM     @"customer"
#define CALL_MESSAGE_EXTERN_FROM_SP         @"sp"

#define SAMC_QR_ADDCONTACT_PREFIX           @"Samchat:"

#define SAMC_PUBLIC_ACCOUNT_PREFIX          @"public_"

#define SAMC_SAMCHAT_ACCOUNT_PREFIX         @"samchat_"
#define SAMC_SAMCHAT_ACCOUNT_ASKSAM         SAMC_SAMCHAT_ACCOUNT_PREFIX@"30000002146"

#endif /* SAMCGlobalMacro_h */
