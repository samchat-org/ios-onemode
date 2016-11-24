//
//  SAMCEnumDefine.h
//  SamChat
//
//  Created by HJ on 11/23/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCEnumDefine_h
#define SAMCEnumDefine_h

typedef NS_ENUM(NSInteger,SAMCUserModeType) {
    SAMCUserModeTypeCustom,
    SAMCUserModeTypeSP
};

typedef NS_ENUM(NSInteger,SAMCContactListType) {
    SAMCContactListTypeServicer,
    SAMCContactListTypeCustomer
};

typedef NS_ENUM(NSInteger,SAMCQuestionSessionType) {
    SAMCQuestionSessionTypeSend,
    SAMCQuestionSessionTypeReceived
};

typedef NS_ENUM(NSInteger,SAMCReceivedQuestionStatus) {
    SAMCReceivedQuestionStatusNew,
    SAMCReceivedQuestionStatusInserted,
    SAMCReceivedQuestionStatusResponsed
};

typedef NS_ENUM(NSInteger,SAMCUserType) {
    SAMCUserTypeCustom,
    SAMCuserTypeSamPros
};

#endif /* SAMCEnumDefine_h */
