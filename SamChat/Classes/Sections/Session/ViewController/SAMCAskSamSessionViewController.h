//
//  SAMCAskSamSessionViewController.h
//  SamChat
//
//  Created by HJ on 11/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import "NIMSessionViewController.h"

@interface SAMCAskSamSessionViewController : NIMSessionViewController

@property (nonatomic,assign) BOOL disableCommandTyping;  //需要在导航条上显示“正在输入”
@end
