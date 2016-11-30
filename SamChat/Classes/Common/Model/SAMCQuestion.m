//
//  SAMCQuestion.m
//  SamChat
//
//  Created by HJ on 11/29/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "SAMCQuestion.h"
#import "SAMCServerAPIMacro.h"
#import "NSDictionary+SAMCJson.h"

@implementation SAMCQuestion

+ (instancetype)questionFromDict:(NSDictionary *)questionDict
{
    SAMCQuestion *question = [[SAMCQuestion alloc] init];
    question.datetime = [questionDict samc_JsonNumber:SAMC_DATETIME];
    question.questionId = [questionDict samc_JsonNumber:SAMC_QUESTION_ID];
    question.messageId = [questionDict samc_JsonString:SAMC_UUID];
    question.question = [questionDict samc_JsonString:SAMC_QUESTION];
    question.address = [questionDict samc_JsonString:SAMC_ADDRESS];
    NSDictionary *userDict = questionDict[SAMC_USER];
    question.fromUser = [userDict samc_JsonString:SAMC_ID];
    return question;
}

@end
