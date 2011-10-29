//
//  NSString+helpers.m
//  MittSaldo
//
//  Created by Björn Sållarp on 10/2/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (NSString_Helpers)

+ (BOOL)stringIsNullEmpty:(NSString *)string
{
    if (string && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

@end
