//
//  SharedItems+CoreDataClass.m
//
//  Created by mini mac on 8/18/17.
//

#import "SharedItems.h"
#import <MagicalRecord/MagicalRecord.h>
#import <AFNetworking/AFNetworking.h>

@implementation SharedItems

+ (void)insertSharedItemWithData:(NSArray *)sharedData forContext:(NSManagedObjectContext *)defaultManagedObjectContext  withCompletionHandler:(void(^)(SharedItems *item))completion{
    __block int counter = 0;
    __block NSUInteger savedObjectsCount = [SharedItems MR_countOfEntities];
    
    
    [sharedData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        counter ++;
        
       // int presentItemId = (int) [[sharedData objectAtIndex:idx] valueForKey:@"itemId"];
        __block SharedItems *item = [SharedItems MR_findFirstByAttribute:@"itemId" withValue:[NSNumber numberWithInteger:idx] inContext:defaultManagedObjectContext];
        
        if (!item || item.filename == nil) {
            if(!item)
              item = [SharedItems MR_createEntityInContext:defaultManagedObjectContext];
            item.itemId = [NSNumber numberWithInt:idx];
            item.text = [[sharedData objectAtIndex:idx] valueForKey:@"Text"];
            [item saveDocumentWithString:[[sharedData objectAtIndex:idx] valueForKey:@"URL"] withCompletionHandler:^(NSURL *filePath, NSError *error) {
                if(filePath){
                    item.filename = [NSString stringWithFormat:@"%@",filePath];
                    [item saveThumbnailForDocumentWithUrl:filePath withCompletionHandler:^(NSString *filePath) {
                        if(filePath){
                            item.thumbnailFileName = filePath;
                            completion(item);
                        }
                        else{
                            item.thumbnailFileName = @"";
                        }
                    }];
                    
                    completion(item);
                }
                else{
                    item.filename = @"";
                }
            }];
            
            [defaultManagedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError *error) {
                if (!error) {
                    savedObjectsCount++;
                    if([SharedItems MR_countOfEntities] == savedObjectsCount)
                    {
                        completion(nil);
                    }
                }
                
            }];
        }
        else{
            if(counter == sharedData.count)
            {
                completion(nil);
            }
            
        }
    }];
    
    
    
    for(int i = 0; i< sharedData.count; i++){
        
    }
}

- (void)saveDocumentWithString:(NSString *)urlString withCompletionHandler:(void(^)(NSURL *filePath, NSError *error))completion{
    
    if([[NSFileManager defaultManager]fileExistsAtPath:urlString]){
        completion([[NSURL alloc] initFileURLWithPath:urlString], nil);
    }
    else{
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURL *URL = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                NSLog(@"File downloaded to: %@", filePath);
                completion(filePath,error);
       }];
       [downloadTask resume];
    }
}

- (void)saveThumbnailForDocumentWithUrl:(NSURL *)url withCompletionHandler:(void(^)(NSString *filePath))completion{
    
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, 70, 100); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, aRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, aRect);
    
    
    // Grab the first PDF page
    page = CGPDFDocumentGetPage(pdf,  1);
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
    // And apply the transform.
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    
    // Create the new UIImage from the context
    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
    
    CGContextRestoreGState(context);
    
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    NSArray *imagePathArray = [[NSString stringWithFormat:@"%@",url] componentsSeparatedByString:@"/"];
    NSArray *imageNameArray = [imagePathArray.lastObject componentsSeparatedByString:@"."];
    
    NSData *pngData = UIImagePNGRepresentation(thumbnailImage);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *fileName = [NSString stringWithFormat:@"thumbnail_%@.png",imageNameArray.firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent: fileName]; //Add the file name
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    completion(fileName);
}


@end
