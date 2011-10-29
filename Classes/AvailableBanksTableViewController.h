//
//  AvailableBanksListViewController.h
//  MittSaldo
//
//  Created by Björn Sållarp on 9/30/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BankSettingsViewController.h"

@class NSManagedObjectContext;

@interface AvailableBanksTableViewController : UITableViewController <BankSettingsViewDelegate>
+ (id)availableBanksTableViewWithContext:(NSManagedObjectContext *)context;
- (id)initWithContext:(NSManagedObjectContext *)context;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContex;
@end
