//
//  SAMCConfirmPhoneNumViewController.h
//  SamChat
//
//  Created by HJ on 7/28/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCConfirmPhoneNumViewController : UIViewController

@property (nonatomic, getter=isSignupOperation) BOOL signupOperation;
@property (nonatomic, copy) NSString *countryCode;

@end
