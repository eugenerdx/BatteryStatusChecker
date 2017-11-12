//
//  SelectablePhonesCell.h
//  Utils
//
//  Created by Eugeny Ulyankin on 08/08/15.
//  Copyright © 2015 eugenerdx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeleteAlertTableViewCell : UITableViewCell

/**
 Title text setter
 @param titleText for each cell in AlertViewController with table view
 */
- (void)setTitleText:(NSString *)titleText;

/**
 Enabling of the cell
 @param enabled user interactions
 */
- (void)setEnabled:(BOOL)enabled;
@end

