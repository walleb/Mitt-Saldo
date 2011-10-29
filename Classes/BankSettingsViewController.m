//
//  BankSettingsTableViewController.m
//  MittSaldo
//
//  Created by Björn Sållarp on 10/1/11.
//  Copyright 2011 Björn Sållarp. All rights reserved.
//

#import "BankSettingsViewController.h"
#import "UITextInputCell.h"
#import "MittSaldoSettings.h"
#import "BSKeyboardAwareTableView.h"
#import "ConfiguredBank.h"
#import "NSString+Helpers.h"

@interface BankSettingsViewController ()
- (BOOL)isBankConfigured;
- (NSString *)settingsValueForKey:(NSString *)key;
- (void)addNavigationBar;
@property (nonatomic, retain) UIBarButtonItem *saveButton;
@end

@implementation BankSettingsViewController
@synthesize configuredBank = __configuredBank;
@synthesize bankIdentfier = __bankIdentifier;
@synthesize tableView = __tableView;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize saveButton = __saveButton;
@synthesize delegate;

+ (id)bankSettingsTableWithBankIdentifier:(NSString *)identifier andManagedObjectContext:(NSManagedObjectContext *)context
{
     return [[[BankSettingsViewController alloc] initWithBankIdentifier:identifier andManagedObjectContext:context] autorelease];
}

+ (id)bankSettingsTableWithConfiguredBank:(ConfiguredBank *)configuredBank andManagedObjectContext:(NSManagedObjectContext *)context
{
    return [[[BankSettingsViewController alloc] initWithConfiguredBank:configuredBank andManagedObjectContext:context] autorelease];
}

- (id)initWithBankIdentifier:(NSString *)identifier andManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.bankIdentfier = identifier;
        self.managedObjectContext = context;
    }
    
    return self;
}

- (id)initWithConfiguredBank:(ConfiguredBank *)configuredBank andManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        self.configuredBank = configuredBank;
        self.managedObjectContext = context;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.saveButton = nil;
    self.bankIdentfier = nil;
    self.configuredBank = nil;
    self.tableView = nil;
    self.managedObjectContext = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.keyboardDelegate = self;
    
    if (!self.configuredBank && self.bankIdentfier) {
        isNewBank = YES;
        [self addNavigationBar];        
    }
    else {
        self.title = self.configuredBank.name;
        self.saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveBank:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
        
        UIView *bgView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
        
        UIImage *image = [UIImage imageNamed:@"button_red.png"];
        float w = image.size.width / 2, h = image.size.height / 2;
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setTitle:NSLocalizedString(@"Erase", nil) forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateNormal];
        
        int xOffset = 10;
        if(IDIOM == IPAD) {
            xOffset = 45;
        }
        
        deleteButton.frame = CGRectMake(xOffset, 0, bgView.frame.size.width - (2*xOffset), bgView.frame.size.height);
        
        deleteButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [bgView addSubview:deleteButton];
        self.tableView.tableFooterView = bgView;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.saveButton.enabled = [self isBankConfigured];
}

 -(void)viewWillDisappear:(BOOL)animated
{
    if (self.configuredBank) {
        NSError * error;
        // Store the objects
        if (![self.managedObjectContext save:&error]) {
            // Log the error.
            NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions 

- (IBAction)dismissView:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addNewBank:(id)sender
{
    if ([self isBankConfigured]) {
        ConfiguredBank *bank = [NSEntityDescription insertNewObjectForEntityForName:@"ConfiguredBank" inManagedObjectContext:self.managedObjectContext];
        bank.bankIdentifier = self.bankIdentfier;
        bank.name = [self settingsValueForKey:@"name"];
        bank.ssn = [self settingsValueForKey:@"ssn"];
        bank.password = [self settingsValueForKey:@"pwd"];
        
        if (self.delegate) {
            [self.delegate bankSettingsViewController:self didAddBank:bank];
        }
        else {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (IBAction)saveBank:(id)sender
{
    if ([self isBankConfigured]) {
        self.configuredBank.name = [self settingsValueForKey:@"name"];
        self.configuredBank.ssn = [self settingsValueForKey:@"ssn"];
        self.configuredBank.password = [self settingsValueForKey:@"pwd"];
        
        [self dismissModalViewControllerAnimated:YES];
    }
}
            
#pragma mark - Private methods

- (NSString *)settingsValueForKey:(NSString *)key
{
    NSIndexPath *path = nil;
    if ([key isEqualToString:@"name"]) {
        path = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else if ([key isEqualToString:@"ssn"]) {
        path = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    else if ([key isEqualToString:@"pwd"]) {
        path = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    if (path) {
        return ((UITextInputCell *)[self.tableView cellForRowAtIndexPath:path]).textField.text;
    }
    
    return nil;
}

- (BOOL)isBankConfigured
{
    if (![NSString stringIsNullEmpty:[self settingsValueForKey:@"name"]] && 
        ![NSString stringIsNullEmpty:[self settingsValueForKey:@"ssn"]] && 
        ![NSString stringIsNullEmpty:[self settingsValueForKey:@"pwd"]]) {
        return YES;
    }
    
    return NO;
}

- (void)addNavigationBar
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:bar];
    [bar release];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(dismissView:)] autorelease];
    self.navigationItem.title = self.bankIdentfier;
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addNewBank:)];
    self.navigationItem.rightBarButtonItem = self.saveButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [bar pushNavigationItem:self.navigationItem animated:NO];
    CGRect tableRect = self.tableView.frame;
    tableRect.origin.y = 44;
    tableRect.size.height -= 44;
    self.tableView.frame = tableRect;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.configuredBank && self.configuredBank.bookmarkURL) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    UITableViewCell *cell = nil;

    if (indexPath.row < 3) {
        static NSString *cellIdentifier = @"inputcell";
        UITextInputCell *inputCell = (UITextInputCell*)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (inputCell == nil) {
            inputCell = [[[UITextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        
        if (indexPath.row == 0) {
            inputCell.textLabel.text = NSLocalizedString(@"Name", nil);
            inputCell.textField.secureTextEntry = NO;
            inputCell.textField.keyboardType = UIKeyboardTypeDefault;
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.name;
            }
        }
        else if (indexPath.row == 1) {
            inputCell.textLabel.text = NSLocalizedString(@"SSN", nil);
            inputCell.textField.secureTextEntry = NO;
            inputCell.textField.keyboardType = UIKeyboardTypeNumberPad;
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.ssn;
            }
        }
        else if (indexPath.row == 2) {
            inputCell.textLabel.text = NSLocalizedString(@"Password", nil);
            inputCell.textField.secureTextEntry = YES;
            inputCell.textField.keyboardType = UIKeyboardTypeDefault;
            
            if (self.configuredBank) {
                inputCell.textField.text = self.configuredBank.password;
            }
        }
        
        inputCell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputCell.textField.delegate = self;
        cell = inputCell;
    }
    else if (indexPath.row == 3) {
        UITableViewCell *buttonCell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"BookmarkCell"];
        if (buttonCell == nil) {
            buttonCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BookmarkCell"] autorelease];
        }
        
        buttonCell.textLabel.text = NSLocalizedString(@"Bookmark", nil);
        
        UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Load our image normally.
        UIImage *image = [UIImage imageNamed:@"button_red.png"];
        float w = image.size.width / 2, h = image.size.height / 2;
        
        [removeBtn setBackgroundImage:[image stretchableImageWithLeftCapWidth:w topCapHeight:h] forState:UIControlStateNormal];
        [removeBtn setTitle:NSLocalizedString(@"Erase", nil) forState:UIControlStateNormal];
        removeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        removeBtn.frame = CGRectMake(0, 0, 63, 33);
        [removeBtn addTarget:self action:@selector(removeBookmark:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonCell setAccessoryView:removeBtn];
        cell = buttonCell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Actions

- (IBAction)removeBookmark:(id)sender
{
    self.configuredBank.bookmarkURL = nil;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
}

- (IBAction)removeBank:(id)sender
{
    if (self.configuredBank) {
        [self.managedObjectContext deleteObject:self.configuredBank];
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Text Field delegate methods

// Hide the keyboard on return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

// When the user focus on the textfield we move it up so that it
// is not hidden by the keyboard.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.tableView.textField = textField;
}

// When the user is done editing we save the setting
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	// Cast the textbox to our custom class and save the input
	BSSettingsTextField *settingsField = (BSSettingsTextField*)textField;
    
    self.tableView.textField = nil;
	
	// A swedish SSN is 10 digits. Show an alert if the entered value length isn't 10 or 12
	int length = [settingsField.text length];
	if (!settingsField.secureTextEntry && 
        settingsField.keyboardType == UIKeyboardTypeNumberPad && 
        length > 0 && length != 10 && length != 12) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"InputErrorQuestion", nil) 
														message:[NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"SSNInputError", nil), [settingsField.text length]]  
													   delegate:nil 
											  cancelButtonTitle:NSLocalizedString(@"OK", nil)   
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
    self.saveButton.enabled = [self isBankConfigured];
}

#pragma mark - Accessors

- (NSBundle *)nibBundle
{
    return [NSBundle mainBundle];
}

- (NSString *)nibName
{
    return @"BankSettings";
}

@end
