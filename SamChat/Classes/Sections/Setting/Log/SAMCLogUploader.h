//
//  SAMCLogUploader.h
//  SamChat
//
//  Created by HJ on 11/30/16.
//  Copyright © 2016 SamChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMCLogUploader : NSObject

- (void)upload:(void (^)(NSString *urlString,NSError *error))completion;

@end
