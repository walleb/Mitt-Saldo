//
//  SwedbankLogin+Testable.m
//  MittSaldo
//
//  Created by  on 12/7/11.
//  Copyright (c) 2011 Björn Sållarp. All rights reserved.
//

#import "SwedbankTestableLogin.h"
#import "SwedbankLoginParser.h"
#import "Swizzle.h"

@implementation SwedbankTestableLogin
@synthesize delegate = _delegate;

+ (void)setupForTests
{
    [self swizzleMethod:@selector(loginStepTwo) withMethod:@selector(newLoginStepTwo)];
    [self swizzleMethod:@selector(loginStepThree) withMethod:@selector(newLoginStepThree)];    
}

- (void)newLoginStepTwo
{
    [self.delegate performSelector:@selector(validateStepOne:) withObject:self];
    [self newLoginStepTwo];
}

- (void)newLoginStepThree
{
    [self.delegate performSelector:@selector(validateStepTwo:) withObject:self];
    [self newLoginStepThree];
}

@end
