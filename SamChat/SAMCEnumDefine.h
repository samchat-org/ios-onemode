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


#define SAMC_CONTACT_TAG_ALL                @"All"
#define SAMC_CONTACT_TAG_CUSTOMERS          @"Customers"
#define SAMC_CONTACT_TAG_FRIENDS            @"Friends"
#define SAMC_CONTACT_TAG_SERVICE_PROVIDERS  @"Service Providers"
#define SAMC_CONTACT_TAG_ASSOCIATE_SPS      @"Associate SPs"

#endif /* SAMCEnumDefine_h */
