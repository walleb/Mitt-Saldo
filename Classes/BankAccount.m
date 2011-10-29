//
//  BankAccount.m
//  MittSaldo
//
//  Created by Björn Sållarp on 10/2/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "BankAccount.h"
#import "ConfiguredBank.h"


@implementation BankAccount
@dynamic amount;
@dynamic bankIdentifier;
@dynamic displayName;
@dynamic updatedDate;
@dynamic displayAccount;
@dynamic availableAmount;
@dynamic accountid;
@dynamic accountName;
@dynamic configuredbank;

- (void)setAccountName:(NSString *)accountName
{
    accountName = [accountName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
    accountName = [accountName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    // If the account name changed we update and also change the user set account name.
    if (![accountName isEqualToString:self.accountName]) {
        NSString *key = @"accountName";
        [self willChangeValueForKey:key];
        [self setPrimitiveValue:accountName forKey:key];
        [self didChangeValueForKey:key];
        
        self.displayName = accountName;
    }
}

- (NSNumber *)stringToNumber:(NSString *)stringValue
{
    NSMutableString *strippedAmountString = [NSMutableString string];
    for (int i = 0; i < [stringValue length]; i++) {
        if (isdigit([stringValue characterAtIndex:i]) || [stringValue characterAtIndex:i] == ',' || [stringValue characterAtIndex:i] == '-') {
            [strippedAmountString appendFormat:@"%c", [stringValue characterAtIndex:i]];
        }
    }
    
    NSNumberFormatter *f = [[[NSNumberFormatter alloc] init] autorelease];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [f setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
    
    return [f numberFromString:strippedAmountString];    
}

- (void)setAmountWithString:(NSString *)stringValue
{
    self.amount = [self stringToNumber:stringValue];
}

- (void)setAvailableAmountWithString:(NSString *)stringValue
{
    self.availableAmount = [self stringToNumber:stringValue];
}

@end
