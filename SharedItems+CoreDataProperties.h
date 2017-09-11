//
//  SharedItems+CoreDataProperties.h
//
//  Created by mini mac on 8/18/17.
//

#import "SharedItems.h"


NS_ASSUME_NONNULL_BEGIN

@interface SharedItems (CoreDataProperties)

+ (NSFetchRequest<SharedItems *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *itemId;
@property (nullable, nonatomic, copy) NSString *text;
@property (nullable, nonatomic, copy) NSString *filename;
@property (nullable, nonatomic, copy) NSString *thumbnailFileName;

@end

NS_ASSUME_NONNULL_END
