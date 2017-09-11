//
//  WebCell.h
//  ShareSheetApp
//
//  Created by mini mac on 8/18/17.
//

#import <UIKit/UIKit.h>
#import "SharedItems.h"


@interface WebCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemDescription;
@property (weak, nonatomic) IBOutlet UIWebView *itemWebView;

@property (strong, nonatomic) SharedItems *sharedItem;

- (void)updateItemsAtIndexPath:(NSIndexPath *)indexPath;

@end
