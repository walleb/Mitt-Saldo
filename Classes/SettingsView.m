//
//  Created by Björn Sållarp on 2010-04-25.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "SettingsView.h"
#import "MittSaldoAppDelegate.h"
#import "DebugTableViewController.h"
#import "AvailableBanksTableViewController.h"
#import "BankSettingsViewController.h"
#import "ConfiguredBank.h"

@interface SettingsView ()
@property (nonatomic, readonly) NSArray *configuredBanks;
@end

@implementation SettingsView
@synthesize managedObjectContext = __managedObjectContext;
@synthesize settingsTable = __settingsTable;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Settings", nil);
	self.managedObjectContext = ((MittSaldoAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated
{
    [__configuredBanks release];
    __configuredBanks = nil;
    [self.settingsTable reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 3) {
		DebugTableViewController *debugView = [[DebugTableViewController alloc] initWithNibName:@"DebugTableView" 
																						 bundle:[NSBundle mainBundle]];
        
		debugView.managedObjectContext = self.managedObjectContext;
		[self.navigationController pushViewController:debugView animated:YES];
		[debugView release];
	}
    else if (indexPath.section == 1) {
        if (indexPath.row >= [self.configuredBanks count]) {
            [self.navigationController pushViewController:[AvailableBanksTableViewController availableBanksTableViewWithContext:self.managedObjectContext] animated:YES];
        }
        else {
            ConfiguredBank *bank = [self.configuredBanks objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:[BankSettingsViewController bankSettingsTableWithConfiguredBank:bank andManagedObjectContext:self.managedObjectContext] animated:YES];
        }
    }
}


#pragma mark - Table view data source
// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{	
	int rows = 0;
	
	if (section == 0) {
		rows = 3;
		if ([MittSaldoSettings isDebugEnabled]) {
			rows++;
        }
	}
    else {
        rows = [self.configuredBanks count] + 1;
    }
	
	return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	NSString *name = nil;

	if (section == 0) {
		name = NSLocalizedString(@"ApplicationSettings", nil);
	}
	else {
		name = @"Banker";
	}
	
	return name;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	UITableViewCell *cell = nil;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			UISwitchCell *switchCell = (UISwitchCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			switchCell.textLabel.text = NSLocalizedString(@"ApplicationLock", nil);
			[switchCell.switchControl addTarget:self action:@selector(appLockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			
			switchCell.switchControl.on = [MittSaldoSettings isKeyLockActive];
			appLockSwitch = switchCell.switchControl;
			cell = switchCell;
		}
		else if (indexPath.row == 1) {
			SliderCell *slidercell = (SliderCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SliderCell"];
			if (slidercell == nil) {
				slidercell = [[[SliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SliderCell"] autorelease];
				[slidercell.slider setMaximumValue: 60];
				[slidercell.slider setMinimumValue:1];
				slidercell.slider.value = [MittSaldoSettings multitaskingTimeout];
			}
			
			slidercell.settingsKey = @"multitaskingTimeout";
			slidercell.textLabel.text = NSLocalizedString(@"MultitaskingTimeout", nil);

			cell = slidercell;
		}
		else if (indexPath.row == 2) {
			UISwitchCell *switchCell = (UISwitchCell*)[settingsTable dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if (switchCell == nil) {
				switchCell = [[[UISwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SwitchCell"] autorelease];
			}
			
			[switchCell.switchControl addTarget:self action:@selector(debugModeChanged:) forControlEvents:UIControlEventValueChanged];
			switchCell.textLabel.text = NSLocalizedString(@"ActivateDebugMode", nil);
			switchCell.switchControl.on = [MittSaldoSettings isDebugEnabled];
			
			cell = switchCell;
		}
		else if (indexPath.row == 3) {
			cell = [settingsTable dequeueReusableCellWithIdentifier:@"normalcell"];
			if(cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalcell"] autorelease];
			}
			
			cell.textLabel.text = NSLocalizedString(@"DebugInformation", nil);
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
        
        // The cells are not selectable
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	// Cells for a bank specific settings
	else if (indexPath.section > 0) {
        
        cell = [settingsTable dequeueReusableCellWithIdentifier:@"normalcell"];
        if(cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"normalcell"] autorelease];
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row < [self.configuredBanks count]) {
            ConfiguredBank *bank = [self.configuredBanks objectAtIndex:indexPath.row];
            cell.textLabel.text = bank.name;
        }
        else {
            cell.textLabel.text = @"Lägg till ny bank..";
        }
	}


	return cell;
}

- (UIView *)tableView: (UITableView *)tableView viewForFooterInSection: (NSInteger)section{

	UIView *footerView = nil;
	
	if (section == 0) {
		footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
		footerView.autoresizesSubviews = YES;
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		footerView.userInteractionEnabled = YES;
		footerView.hidden = NO;
		footerView.multipleTouchEnabled = NO;
		footerView.opaque = NO;
		footerView.contentMode = UIViewContentModeScaleToFill;
		
		int xOffset = 10;
		if(self.view.frame.size.width > 320) {
			xOffset = 45;
		}

		UIButton *showHiddenAccount = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[showHiddenAccount setTitle:NSLocalizedString(@"ShowAllHiddenAccounts", nil) forState:UIControlStateNormal];
		showHiddenAccount.frame = CGRectMake(xOffset, 10, self.view.frame.size.width - (xOffset *2), 40.0);
		
		
		[showHiddenAccount addTarget:self 
							  action:@selector(showHiddenAccounts:)
					forControlEvents:UIControlEventTouchDown];

		
		UIButton *clearStoredData = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[clearStoredData setTitle:NSLocalizedString(@"ClearStoredBalanceInformation", nil) forState:UIControlStateNormal];
		clearStoredData.frame = CGRectMake(xOffset, 60, self.view.frame.size.width - (xOffset *2), 40.0);
		
		
		[clearStoredData addTarget:self 
							  action:@selector(clearStoredData:)
					forControlEvents:UIControlEventTouchDown];
		
		[footerView addSubview:showHiddenAccount];
		[footerView addSubview:clearStoredData];
	}
	
	return footerView;
}

// Need to call to pad the footer height otherwise the footer collapses
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 110.0;
		default:
			return 0.0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 1) {
		return 120; 
	}
	
	return 44;
}

#pragma mark - Key lock delegate methods
-(void)validateKeyCombination:(NSArray*)keyCombination sender:(id)sender
{
	int comboCount = [keyCombination count];
	
	if(comboCount > 3) {
		[MittSaldoSettings setKeyLockCombination:keyCombination];
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[appLockSwitch setOn:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		[MittSaldoSettings setKeyLockCombination:nil];
		[(BSKeyLock*)sender deemKeyCombinationInvalid];
		[appLockSwitch setOn:NO];
	}
}

#pragma mark - Switch delegate methods
-(IBAction)debugModeChanged:(id)sender
{
	int isOn = [(UISwitch *)sender isOn] ? 1 : 0;
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setValue:[NSNumber numberWithInt:isOn] forKey:@"debugModeEnabled"];
	[settings synchronize];
	
	[settingsTable reloadData];
}

- (IBAction)appLockSwitchChanged:(id)sender
{
	if ([(UISwitch*)sender isOn]) {
		KeyLockViewController *keyLock = [[KeyLockViewController alloc] initWithNibName:@"KeyLockViewController" bundle:[NSBundle mainBundle] headerText:@"Ange ditt mönster"];
		keyLock.appDelegate = self;
		[self.navigationController pushViewController:keyLock animated:YES];
		[keyLock release];
		
		// Set the switch back to NO, we want the user to set a key for it to be active
		[(UISwitch*)sender setOn:NO];
	}
	else {
		// Clear the key lock combo
		[MittSaldoSettings setKeyLockFailedAttempts:0];
		[MittSaldoSettings setKeyLockCombination:nil];
	}
}

#pragma mark - Button delegate method

-(void)showHiddenAccounts:(id)sender
{
	NSArray *accounts = [CoreDataHelper searchObjectsInContext:@"Account" 
													 predicate:[NSPredicate predicateWithFormat:@"displayAccount == 0"] 
													   sortKey:@"accountid" 
												 sortAscending:NO 
										  managedObjectContext:managedObjectContext];
	int accountsCount = [accounts count];
	
	for (int i = 0; i < accountsCount; i++) {
		BankAccount *a = [accounts objectAtIndex:i];
		a.displayAccount = [NSNumber numberWithInt:1];
	}
	
	
	NSError * error;
	// Store the objects
	if (![managedObjectContext save:&error]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
														message:[error localizedDescription]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
		
		// Log the error.
		NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
	}
}

- (void)clearStoredData:(id)sender
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
													message:NSLocalizedString(@"ConfirmBalancePurge", nil)
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"No", nil)
										  otherButtonTitles:NSLocalizedString(@"Yes", nil), nil];
	
	alert.tag = 1;
	[alert show];
	[alert release];
}

#pragma mark - UIAlertView delegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// tag 1 = clear balance information
	if(alertView.tag == 1 && buttonIndex == 1)
	{
		// Get all accounts
		NSMutableArray* mutableFetchResults = [CoreDataHelper getObjectsFromContext:@"Account" 
																			sortKey:@"accountid" 
																	  sortAscending:NO 
															   managedObjectContext:managedObjectContext];
		
		// Delete all accounts
		for (int i = 0; i < [mutableFetchResults count]; i++) {
			[managedObjectContext deleteObject:[mutableFetchResults objectAtIndex:i]];
		}
		
		
		// Update the data model effectivly removing the objects we removed above.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" 
															message:[error localizedDescription]
														   delegate:self 
												  cancelButtonTitle:NSLocalizedString(@"OK", nil)
												  otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			
			// Log the error.
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
		}
	}
}



#pragma mark - Accessors

- (NSArray *)configuredBanks
{
    if (__configuredBanks == nil) {
        __configuredBanks = [[MittSaldoSettings configuredBanks:self.managedObjectContext] retain];
    }
    
    return __configuredBanks;
}

#pragma mark - Memmory management
- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}

- (void)dealloc 
{
	[settingsTable release];
	[managedObjectContext release];
    [super dealloc];
}


@end
