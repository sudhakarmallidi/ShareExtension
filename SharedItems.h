//
//  SharedItems+CoreDataClass.h
//
//  Created by mini mac on 8/18/17.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface SharedItems : NSManagedObject

+ (void)insertSharedItemWithData:(NSArray *)sharedData forContext:(NSManagedObjectContext *)defaultManagedObjectContext  withCompletionHandler:(void(^)(SharedItems *item))completion;

@end

NS_ASSUME_NONNULL_END

#import "SharedItems+CoreDataProperties.h"
