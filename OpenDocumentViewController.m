//
//  OpenDocumentViewController.m
//  ShareSheetBlogExample
//
//  Created by mini mac on 8/18/17.
//

#import "OpenDocumentViewController.h"

@interface OpenDocumentViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *documentWebView;

@end

@implementation OpenDocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSURL *targetURL = [[NSBundle mainBundle] URLForResource:@"pdf-sample" withExtension:@"pdf"];
    
    
    NSArray *pdfPathArray = [[[NSString stringWithFormat:@"%@",self.presentFilePath] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:pdfPathArray.lastObject];
    
    NSURL *pdfUrl = [NSURL fileURLWithPath:filePath];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfUrl];
    [self.documentWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
