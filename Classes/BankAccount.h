//
//  BankAccount.h
//  MittSaldo
//
//  Created by Björn Sållarp on 10/2/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ConfiguredBank;

@interface BankAccount : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * bankIdentifier;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSNumber * displayAccount;
@property (nonatomic, retain) NSNumber * availableAmount;
@property (nonatomic, retain) NSNumber * accountid;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) ConfiguredBank *configuredbank;

- (void)setAmountWithString:(NSString *)stringValue;
- (void)setAvailableAmountWithString:(NSString *)stringValue;

@end
