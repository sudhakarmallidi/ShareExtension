//
//  ViewController.m
//  ShareSheetBlogExample
//
//  Created by mini mac on 8/18/17.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "OpenDocumentViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import "SharedItems.h"
#import <MobileCoreServices/MobileCoreServices.h>
static NSString *const AppGroupId = @"group.tag.AppGroupDemo";

@interface ViewController ()<UIDocumentMenuDelegate,UIDocumentPickerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *itemsTableView;
@property (strong, nonatomic) NSManagedObjectContext *defaultManagedObjectContext;
@property (strong, nonatomic) NSMutableArray *itemsArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSUserDefaults standardUserDefaults] setObject:@"file:///Users/enterpi/Library/Developer/CoreSimulator/Devices/596438A8-E2A0-4669-B2C0-D6C62A2DA96F/data/Containers/Data/Application/D91D40A1-3C49-443F-81F5-B428332A7C81/tmp/com.tag.ShareSheetBlogExample-Inbox/Habimoon%20Shaik.doc" forKey:@"URLKey"];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.defaultManagedObjectContext = [NSManagedObjectContext MR_defaultContext];
    sharedUserDefaults = [[NSUserDefaults alloc] initWithSuiteName:AppGroupId];
    [self prepareSharedDatabase];
}

-(void)prepareSharedDatabase{
    self.itemsArray = [[NSMutableArray alloc] initWithCapacity:0];
    arrSites = [NSMutableArray arrayWithArray:[sharedUserDefaults valueForKey:@"SharedExtension"]];
    
    self.itemsArray = [[SharedItems MR_findAllSortedBy:@"itemId" ascending:YES inContext:self.defaultManagedObjectContext] mutableCopy];
    
    [SharedItems insertSharedItemWithData:arrSites forContext:self.defaultManagedObjectContext withCompletionHandler:^(SharedItems * _Nonnull item) {
        if(item != nil){
            //            [self.itemsTableView.visibleCells enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //                if(idx == [item.itemId longValue]){
            //                    [self.itemsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //                }
            //            }];
            self.itemsArray = [[SharedItems MR_findAllSortedBy:@"itemId" ascending:YES inContext:self.defaultManagedObjectContext] mutableCopy];
            [self.itemsTableView reloadData];
            
        }
        else{
            self.itemsArray = [[SharedItems MR_findAllSortedBy:@"itemId" ascending:YES inContext:self.defaultManagedObjectContext] mutableCopy];
            [self.itemsTableView reloadData];
        }
    }];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WebCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.sharedItem = self.itemsArray[indexPath.row];
    [cell updateItemsAtIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OpenDocumentViewController *openDocumentViewController = (OpenDocumentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"OpenDocumentViewController"];
    SharedItems *presentItem = self.itemsArray[indexPath.row];
    openDocumentViewController.presentFilePath = presentItem.filename;
    
    [self.navigationController pushViewController:openDocumentViewController animated:true];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getFilesButtonTapped:(id)sender {
    [self ShowUIDocumentPickerViewController];
    
}

- (void) ShowUIDocumentPickerViewController
{
    UIDocumentMenuViewController *documentPicker = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeRTF,(NSString *)kUTTypeText,(NSString *)kUTTypePlainText,(NSString *)kUTTypePDF, @"com.microsoft.word.doc", @"org.openxmlformats.wordprocessingml.document" ] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - DocumentPicker Delegate Methods

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    
    if(controller.documentPickerMode == UIDocumentPickerModeImport)
    {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            //        NSLog(@“File size is : %.2f KB”,(float)data.length/1024.0f);
            
            
            
            
            
            
            arrSites = [[NSMutableArray alloc] init];
            if ([sharedUserDefaults valueForKey:@"SharedExtension"])
                arrSites = [[sharedUserDefaults valueForKey:@"SharedExtension"] mutableCopy];
            else
                arrSites = [[NSMutableArray alloc] init];
            
            NSArray *docPathArray = [[NSString stringWithFormat:@"%@",[[NSString stringWithFormat:@"%@",newURL] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] componentsSeparatedByString:@"/"];
            NSArray *docNameArray = [docPathArray.lastObject componentsSeparatedByString:@"."];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
            NSString *filePath = [documentsPath stringByAppendingPathComponent: docPathArray.lastObject]; //Add the file name
            [data writeToFile:filePath atomically:YES]; //Write the file

            
            NSDictionary *dictSite = [NSDictionary dictionaryWithObjectsAndKeys:docNameArray.firstObject, @"Text", [filePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"URL",nil];
            [arrSites addObject:dictSite];
            [sharedUserDefaults setObject:arrSites forKey:@"SharedExtension"];
            [sharedUserDefaults synchronize];
            
            
            [self prepareSharedDatabase];
            
            
            
            
        }];
    }
    
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    
}

#pragma mark - DocMenu Delegate Methods

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:^{}];
}

- (void)documentMenuWasDismissed:(UIDocumentMenuViewController *)documentMenu
{
    
}

@end
