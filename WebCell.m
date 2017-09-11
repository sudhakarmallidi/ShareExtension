//
//  WebCell.m
//  ShareSheetApp
//
//  Created by mini mac on 8/18/17.
//

#import "WebCell.h"

@implementation WebCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.itemWebView.scalesPageToFit = YES;
    self.itemWebView.userInteractionEnabled = NO;
    
    self.itemWebView.layer.borderWidth = 1;
    self.itemWebView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.itemWebView.layer.cornerRadius = 5;
    self.itemWebView.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateItemsAtIndexPath:(NSIndexPath *)indexPath{
    self.itemDescription.text = self.sharedItem.text;
    
    NSArray *pdfPathArray = [[[NSString stringWithFormat:@"%@",self.sharedItem.filename] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:pdfPathArray.lastObject];
    NSURL *pdfUrl = [NSURL fileURLWithPath:filePath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfUrl];
    
    [self.itemWebView loadRequest:request];
}

@end
