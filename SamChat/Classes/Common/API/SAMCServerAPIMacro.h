//
//  SAMCServerAPIMacro.h
//  SamChat
//
//  Created by HJ on 8/14/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#ifndef SAMCServerAPIMacro_h
#define SAMCServerAPIMacro_h

#define SAMC_API_PREFIX                 @"http://service-test.samchat.com/"

#define SAMC_URL_REGISTER_CODE_REQUEST      SAMC_API_PREFIX@"api_1.0_user_registerCodeRequest.do"
#define SAMC_URL_SIGNUP_CODE_VERIFY         SAMC_API_PREFIX@"api_1.0_user_signupCodeVerify.do"
#define SAMC_URL_USER_REGISTER              SAMC_API_PREFIX@"api_1.0_user_register.do"
#define SAMC_URL_USER_LOGIN                 SAMC_API_PREFIX@"api_1.0_user_login.do"
#define SAMC_URL_USER_LOGOUT                SAMC_API_PREFIX@"api_1.0_user_logout.do"
#define SAMC_URL_USER_CREATE_SAM_PROS       SAMC_API_PREFIX@"api_1.0_user_createSamPros.do"
#define SAMC_URL_USER_FIND_PWD_CODE_REQUEST SAMC_API_PREFIX@"api_1.0_user_findpwdCodeRequest.do"
#define SAMC_URL_USER_FIND_PWD_CODE_VERIFY  SAMC_API_PREFIX@"api_1.0_user_findpwdCodeVerify.do"
#define SAMC_URL_USER_FIND_PWD_UPDATE       SAMC_API_PREFIX@"api_1.0_user_findpwdUpdate.do"
#define SAMC_URL_USER_PWD_UPDATE            SAMC_API_PREFIX@"api_1.0_user_pwdUpdate.do"
#define SAMC_URL_USER_QUERYFUZZY            SAMC_API_PREFIX@"api_1.0_user_queryFuzzy.do"
#define SAMC_URL_USER_QUERYACCURATE         SAMC_API_PREFIX@"api_1.0_user_queryAccurate.do"
#define SAMC_URL_USER_QUERYGROUP            SAMC_API_PREFIX@"api_1.0_user_queryGroup.do"
#define SAMC_URL_USER_QUERYWITHOUTTOKEN     SAMC_API_PREFIX@"api_1.0_user_queryWithoutToken.do"
#define SAMC_URL_QUESTION_QUESTION          SAMC_API_PREFIX@"api_1.0_question_question.do"
#define SAMC_URL_QUESTION_QUERYPOPULARREQUEST       SAMC_API_PREFIX@"api_1.0_question_queryPopularRequest.do"
#define SAMC_URL_OFFICIALACCOUNT_FOLLOW             SAMC_API_PREFIX@"api_1.0_officialAccount_follow.do"
#define SAMC_URL_OFFICIALACCOUNT_FOLLOW_LIST_QUERY  SAMC_API_PREFIX@"api_1.0_officialAccount_followListQuery.do"
#define SAMC_URL_OFFICIALACCOUNT_PUBLIC_QUERY       SAMC_API_PREFIX@"api_1.0_officialAccount_publicQuery.do"
#define SAMC_URL_OFFICIALACCOUNT_BLOCK              SAMC_API_PREFIX@"api_1.0_officialAccount_block.do"
#define SAMC_URL_COMMON_SEND_INVITE_MSG             SAMC_API_PREFIX@"api_1.0_common_sendInviteMsg.do"
#define SAMC_URL_COMMON_RECALL                      SAMC_API_PREFIX@"api_1.0_common_recall.do"
#define SAMC_URL_ADVERTISEMENT_ADVERTISEMENT_WRITE  SAMC_API_PREFIX@"api_1.0_advertisement_advertisementWrite.do"
#define SAMC_URL_CONTACT_CONTACT_LIST_QUERY         SAMC_API_PREFIX@"api_1.0_contact_contactListQuery.do"
#define SAMC_URL_CONTACT_CONTACT                    SAMC_API_PREFIX@"api_1.0_contact_contact.do"
#define SAMC_URL_PROFILE_AVATAR_UPDATE              SAMC_API_PREFIX@"api_1.0_profile_avatarUpdate.do"
#define SAMC_URL_PROFILE_GET_PLACESINFO             SAMC_API_PREFIX@"api_1.0_profile_getPlacesInfoRequest.do"
#define SAMC_URL_PROFILE_QUERY_STATE_DATE           SAMC_API_PREFIX@"api_1.0_profile_queryStateDate.do"
#define SAMC_URL_PROFILE_PROFILE_UPDATE             SAMC_API_PREFIX@"api_1.0_profile_profileUpdate.do"
#define SAMC_URL_PROFILE_EDITCELLPHONE_CODER_EQUEST SAMC_API_PREFIX@"api_1.0_profile_editCellPhoneCodeRequest.do"
#define SAMC_URL_PROFILE_EDITCELLPHONE_UPDATE       SAMC_API_PREFIX@"api_1.0_profile_editCellPhoneUpdate.do"
#define SAMC_URL_PROFILE_UPDATE_QUESTION_NOTIFY     SAMC_API_PREFIX@"api_1.0_profile_updateQuestionNotify.do"
#define SAMC_URL_PROFILE_CREATE_SAMCHATID           SAMC_API_PREFIX@"api_1.0_profile_createSamchatId.do"

#define SAMC_AWSS3_URLPREFIX            @"http://storage-test.samchat.com/"
#define SAMC_AWSS3_BUCKETNAME           @"storage-test.samchat.com"
#define SAMC_AWSS3_ADV_ORG_PATH         @"advertisement/origin/"
#define SAMC_AWSS3_AVATAR_ORG_PATH      @"avatar/origin/"

#define SAMC_HEADER                     @"header"
#define SAMC_BODY                       @"body"

#define SAMC_RET                        @"ret"
#define SAMC_TOKEN                      @"token"
#define SAMC_USER                       @"user"
#define SAMC_COUNT                      @"count"
#define SAMC_SYS_PARAMS                 @"sys_params"
#define SAMC_PARAM_CODE                 @"param_code"
#define SAMC_PARAM_VALUE                @"param_value"

#define SAMC_ACTION                     @"action"

#define SAMC_REGISTER_CODE_REQUEST      @"register-code-request"
#define SAMC_SIGNUP_CODE_VERIFY         @"signup-code-verify"
#define SAMC_REGISTER                   @"register"
#define SAMC_LOGIN                      @"login"
#define SAMC_LOGOUT                     @"logout"
#define SAMC_APPKEY_GET                 @"appkey-get"
#define SAMC_CREATE_SAM_PROS            @"create-sam-pros"
#define SAMC_FINDPWD_CODE_REQUEST       @"findpwd-code-request"
#define SAMC_FINDPWD_CODE_VERIFY        @"findpwd-code-verify"
#define SAMC_FINDPWD_UPDATE             @"findpwd-update"
#define SAMC_PWD_UPDATE                 @"pwd-update"
#define SAMC_QUESTION                   @"question"
#define SAMC_FOLLOW                     @"follow"
#define SAMC_BLOCK                      @"block"
#define SAMC_QUERY                      @"query"
#define SAMC_QUERY_FUZZY                @"query-fuzzy"
#define SAMC_QUERY_ACCURATE             @"query-accurate"
#define SAMC_QUERY_GROUP                @"query-group"
#define SAMC_QUERY_WITHOUT_TOKEN        @"query-without-token"
#define SAMC_PUBLIC_QUERY               @"public-query"
#define SAMC_FOLLOW_LIST_QUERY          @"follow-list-query"
#define SAMC_CONTACT_LIST_QUERY         @"contact-list-query"
#define SAMC_SEND_INVITE_MSG            @"send-invite-msg"
#define SAMC_ADVERTISEMENT_WRITE        @"advertisement-write"
#define SAMC_CONTACT                    @"contact"
#define SAMC_AVATAR_UPDATE              @"avatar-update"
#define SAMC_GET_PLACES_INFO_REQUEST    @"get-places-info-request"
#define SAMC_SEND_CLIENTID              @"send-clientId"
#define SAMC_QUERY_STATE_DATE           @"query-state-date"
#define SAMC_QUERY_POPULAR_REQUEST      @"query-popular-request"
#define SAMC_PROFILE_UPDATE             @"profile-update"
#define SAMC_EDITCELLPHONE_CODE_REQUEST @"editCellPhone-code-request"
#define SAMC_EDITCELLPHONE_UPDATE       @"editCellPhone-update"
#define SAMC_UPDATE_QUESTION_NOTIFY     @"update-question-notify"
#define SAMC_CREATE_SAMCHAT_ID          @"create-samchat-id"
#define SAMC_RECALL                     @"recall"

#define SAMC_COUNTRYCODE                @"countrycode"
#define SAMC_CELLPHONE                  @"cellphone"
#define SAMC_DEVICEID                   @"deviceid"
#define SAMC_DEVICE_TYPE                @"device_type"
#define SAMC_APP_VERSION                @"app_version"
#define SAMC_VERIFYCODE                 @"verifycode"
#define SAMC_USERNAME                   @"username"
#define SAMC_SAMCHAT_ID                 @"samchat_id"
#define SAMC_PWD                        @"pwd"
#define SAMC_ACCOUNT                    @"account"
#define SAMC_ID                         @"id"
#define SAMC_OPT                        @"opt"
#define SAMC_PARAM                      @"param"
#define SAMC_SEARCH_KEY                 @"search_key"
#define SAMC_KEY                        @"key"
#define SAMC_CLIENT_ID                  @"client_id"
#define SAMC_COUNT                      @"count"
#define SAMC_OLD_PWD                    @"old_pwd"
#define SAMC_NEW_PWD                    @"new_pwd"
#define SAMC_QUESTION_NOTIFY            @"question_notify"
#define SAMC_APP_ADVERTISEMENT_RECALL_MINUTE    @"app_advertisement_recall_minute"

#define SAMC_COMPANY_NAME               @"company_name"
#define SAMC_SERVICE_CATEGORY           @"service_category"
#define SAMC_SERVICE_DESCRIPTION        @"service_description"
#define SAMC_PHONE                      @"phone"
#define SAMC_EMAIL                      @"email"
#define SAMC_LOCATION                   @"location"
#define SAMC_LOCATION_INFO              @"location_info"
#define SAMC_LONGITUDE                  @"longitude"
#define SAMC_LATITUDE                   @"latitude"
#define SAMC_PLACE_ID                   @"place_id"
#define SAMC_ADDRESS                    @"address"
#define SAMC_TYPE                       @"type"
#define SAMC_LASTUPDATE                 @"lastupdate"
#define SAMC_QUESTION_ID                @"question_id"
#define SAMC_DATETIME                   @"datetime"
#define SAMC_USERS                      @"users"
#define SAMC_BLOCK_TAG                  @"block_tag"
#define SAMC_FAVOURITE_TAG              @"favourite_tag"
#define SAMC_SAM_PROS_INFO              @"sam_pros_info"
#define SAMC_PHONES                     @"phones"
#define SAMC_CONTENT                    @"content"
#define SAMC_CONTENT_THUMB              @"content_thumb"
#define SAMC_ADV_ID                     @"adv_id"
#define SAMC_PUBLISH_TIMESTAMP          @"publish_timestamp"
#define SAMC_UNIQUE_ID                  @"unique_id"
#define SAMC_AVATAR                     @"avatar"
#define SAMC_ORIGIN                     @"origin"
#define SAMC_THUMB                      @"thumb"
#define SAMC_DESCRIPTION                @"description"
#define SAMC_PLACE_ID                   @"place_id"
#define SAMC_PLACES_INFO                @"places_info"
#define SAMC_STATE_DATE_INFO            @"state_date_info"
#define SAMC_SERVICER_LIST              @"servicer_list"
#define SAMC_CUSTOMER_LIST              @"customer_list"
#define SAMC_FOLLOW_LIST                @"follow_list"
#define SAMC_MESSAGE_ID                 @"message_id"
#define SAMC_POPULAR_REQUEST            @"popular_request"
#define SAMC_BUSINESS_ID                @"business_id"
#define SAMC_STATE_DATE                 @"state_date"
#define SAMC_PREVIOUS                   @"previous"
#define SAMC_LAST                       @"last"

#define SAMC_AVATAR_ORIGIN              @"avatar.origin"
#define SAMC_AVATAR_THUMB               @"avatar.thumb"
#define SAMC_HEADER_CATEGORY            @"header.category"
#define SAMC_USER_ID                    @"user.id"
#define SAMC_USER_USERNAME              @"user.username"
#define SAMC_LOCATION_ADDRESS           @"location.address"
#define SAMC_BODY_DEST_ID               @"body.dest_id"
#define SAMC_USER_THUMB                 @"user.thumb"
#define SAMC_USER_LASTUPDATE            @"user.lastupdate"
#define SAMC_STATE_DATE_LAST            @"state_date.last"

#define SAMC_PUSHCATEGORY_NEWQUESTION       @"1"
#define SAMC_PUSHCATEGORY_NEWPUBLICMESSAGE  @"2"

#define SAMC_SAM_PROS_INFO_COMPANY_NAME         @"sam_pros_info.company_name"
#define SAMC_SAM_PROS_INFO_SERVICE_CATEGORY     @"sam_pros_info.service_category"
#define SAMC_SAM_PROS_INFO_SERVICE_DESCRIPTION  @"sam_pros_info.service_description"
#define SAMC_SAM_PROS_INFO_COUNTRYCODE          @"sam_pros_info.countrycode"
#define SAMC_SAM_PROS_INFO_PHONE                @"sam_pros_info.phone"
#define SAMC_SAM_PROS_INFO_EMAIL                @"sam_pros_info.email"
#define SAMC_SAM_PROS_INFO_ADDRESS              @"sam_pros_info.address"

#define SAMC_MY_SETTINGS_QUESTION_NOTIFY        @"my_settings.question_notify"

#endif /* SAMCServerAPIMacro_h */