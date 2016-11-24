//
//  SAMCDefaultLoginViewController.h
//  SamChat
//
//  Created by HJ on 11/24/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCDefaultLoginViewController : UIViewController

- (instancetype)initWithCountryCode:(NSString *)countryCode
                          cellPhone:(NSString *)cellPhone
                          avatarUrl:(NSString *)avatarUrl;

@end
