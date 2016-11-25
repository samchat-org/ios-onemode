//
//  SAMCRightButtonCell.h
//  NIMKit
//
//  Created by HJ on 11/25/16.
//  Copyright © 2016 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMCCellButton.h"
#import "NIMCommonTableViewCell.h"

@interface SAMCRightButtonCell : UITableViewCell<NIMCommonTableViewCell>

@property(nonatomic,strong,readonly) SAMCCellButton *rightButton;

@end
