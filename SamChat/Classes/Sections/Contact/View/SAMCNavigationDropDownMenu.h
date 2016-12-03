//
//  SAMCNavigationDropDownMenu.h
//  PFNavigationDropdownMenu
//
//  Created by HJ on 12/2/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCNavigationDropDownMenu : UIView

@property (nonatomic, copy) void(^didSelectItemAtIndexHandler)(NSInteger index);

- (instancetype)initWithFrame:(CGRect)frame
                        items:(NSArray *)items
                selectedIndex:(NSInteger)index
                   titleColor:(UIColor *)titleColor
               arrowImageName:(NSString *)imageName
                containerView:(UIView *)containerView;

- (void)hideMenu;

@end
