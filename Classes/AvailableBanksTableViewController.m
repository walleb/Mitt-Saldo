//
//  AvailableBanksListViewController.m
//  MittSaldo
//
//  Created by Björn Sållarp on 9/30/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "AvailableBanksTableViewController.h"
#import "MittSaldoSettings.h"


@implementation AvailableBanksTableViewController
@synthesize managedObjectContex = __managedObjectContex;

+ (id)availableBanksTableViewWithContext:(NSManagedObjectContext *)context;
{
    return [[[AvailableBanksTableViewController alloc] initWithContext:context] autorelease];
}

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.managedObjectContex = context;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.managedObjectContex = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"AddNewBank", nil);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[MittSaldoSettings supportedBanks] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[MittSaldoSettings supportedBanks] objectAtIndex:indexPath.row];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [[MittSaldoSettings supportedBanks] objectAtIndex:indexPath.row];
    BankSettingsViewController *controller = [BankSettingsViewController bankSettingsTableWithBankIdentifier:identifier andManagedObjectContext:self.managedObjectContex];
    controller.delegate = self;
    [self presentModalViewController:controller animated:YES];
    [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#pragma mark - Bank settings delegate method

- (void)bankSettingsViewController:(BankSettingsViewController *)controller didAddBank:(ConfiguredBank *)bank
{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Accessors

- (NSString *)nibName
{
    return @"AvailableBanksTable";
}

- (NSBundle *)nibBundle
{
    return [NSBundle mainBundle];
}

@end
