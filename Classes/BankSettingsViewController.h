//
//  BankSettingsTableViewController.h
//  MittSaldo
//
//  Created by Björn Sållarp on 10/1/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class BSKeyboardAwareTableView;
@class ConfiguredBank;
@protocol BankSettingsViewDelegate;

@interface BankSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL isNewBank;
}

@property (nonatomic, assign) id<BankSettingsViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet BSKeyboardAwareTableView *tableView;
@property (nonatomic, retain) ConfiguredBank *configuredBank;
@property (nonatomic, retain) NSString *bankIdentfier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (id)initWithConfiguredBank:(ConfiguredBank *)configuredBank andManagedObjectContext:(NSManagedObjectContext *)context;
- (id)initWithBankIdentifier:(NSString *)identifier andManagedObjectContext:(NSManagedObjectContext *)context;

+ (id)bankSettingsTableWithConfiguredBank:(ConfiguredBank *)configuredBank andManagedObjectContext:(NSManagedObjectContext *)context;
+ (id)bankSettingsTableWithBankIdentifier:(NSString *)identifier andManagedObjectContext:(NSManagedObjectContext *)context;
@end


@protocol BankSettingsViewDelegate<NSObject>
@required
- (void)bankSettingsViewController:(BankSettingsViewController *)controller didAddBank:(ConfiguredBank *)bank;
@end