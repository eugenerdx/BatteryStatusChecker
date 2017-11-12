//
//  CustomHeaderFooterView.h
//  TestTaskForSwTec
//
//  Created by Eugeny on 11/5/17.
//  Copyright © 2017 Eugeny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomHeaderFooterView;

@protocol CustomHeaderFooterViewDelegate <NSObject>
- (IBAction)onServiceButtonClicked:(id)sender;
@optional
@end

@interface CustomHeaderFooterView : UIView
@property (nonatomic, weak) id<CustomHeaderFooterViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *headerFooterTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *cleanSettingsButton;

- (void)headerFooterViewWithTitle:(NSString *)title andServiceButtonEnabled:(BOOL)enabled;

@end
