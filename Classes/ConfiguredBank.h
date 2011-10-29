//
//  ConfiguredBank.h
//  MittSaldo
//
//  Created by Björn Sållarp on 10/2/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BankAccount;

@interface ConfiguredBank : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * bankIdentifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * ssn;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) id bookmarkURL;
@property (nonatomic, retain) NSSet *accounts;
@end

@interface ConfiguredBank (CoreDataGeneratedAccessors)

- (void)addAccountsObject:(BankAccount *)value;
- (void)removeAccountsObject:(BankAccount *)value;
- (void)addAccounts:(NSSet *)values;
- (void)removeAccounts:(NSSet *)values;
@end
