//
//  SharedItems+CoreDataProperties.m
//
//  Created by mini mac on 8/18/17.
//

#import "SharedItems+CoreDataProperties.h"

@implementation SharedItems (CoreDataProperties)

+ (NSFetchRequest<SharedItems *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"SharedItems"];
}

@dynamic itemId;
@dynamic text;
@dynamic filename;
@dynamic thumbnailFileName;

@end
