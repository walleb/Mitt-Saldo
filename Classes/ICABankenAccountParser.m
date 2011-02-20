//
//  Created by Björn Sållarp on 2010-07-29.
//  NO Copyright 2010 MightyLittle Industries. NO rights reserved.
// 
//  Use this code any way you like. If you do like it, please
//  link to my blog and/or write a friendly comment. Thank you!
//
//  Read my blog @ http://blog.sallarp.com
//

#import "ICABankenAccountParser.h"


@implementation ICABankenAccountParser
@synthesize contentsOfCurrentProperty, accountsParsed;

-(id) initWithContext: (NSManagedObjectContext *) context
{
	self = [super init];
	managedObjectContext = context;
	[managedObjectContext retain];
	
	return self;
}

- (BOOL)parseXMLData:(NSData *)XMLMarkup parseError:(NSError **)error
{
	BOOL successfull = TRUE;
	
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:XMLMarkup];
    
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
	
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
	
	isParsingAccounts = NO;
	
    // Start parsing
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		
		successfull = FALSE;
    }
    
    [parser release];
	
	return successfull;
}


-(void)emptyCurrentProperty
{
	// Create a mutable string to hold the contents of the 'title' element.
	// The contents are collected in parser:foundCharacters:.
	if(self.contentsOfCurrentProperty == nil)
	{
		self.contentsOfCurrentProperty = [NSMutableString string];
	}
	else
		[self.contentsOfCurrentProperty setString:@""];
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict
{
	if (qName) {
        elementName = qName;
    }
	
	
	// These are the elements we read information from.
	if([elementName isEqualToString:@"ul"] && [[attributeDict valueForKey:@"id"] isEqualToString:@"acount-list"])
	{
		isParsingAccounts = YES;
	} 
	else if(isParsingAccounts && [elementName isEqualToString:@"li"] && [[attributeDict valueForKey:@"class"] isEqualToString:@"row-link"])
	{
		isParsingAccount = YES;
	}
	else if(isParsingAccount && [elementName isEqualToString:@"a"])
	{
		currentAccount = nil;
		
		NSString *accountId = [NSString stringWithFormat:@"%d", accountsParsed];
		
		NSMutableArray* mutableFetchResults = [CoreDataHelper searchObjectsInContext:@"Account" 
																		   predicate:[NSPredicate predicateWithFormat:@"(accountid == %@) && (bankIdentifier == 'ICA')", accountId] 
																			 sortKey:@"accountid" 
																	   sortAscending:YES 
																managedObjectContext:managedObjectContext];
		if([mutableFetchResults count] > 0)
		{
			currentAccount = (BankAccount*)[mutableFetchResults objectAtIndex:0];
		}
		else 
		{
			currentAccount = (BankAccount *)[NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:managedObjectContext];
		}
		
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		
		[currentAccount setAccountid:[f numberFromString:accountId]];
		[currentAccount setBankIdentifier:@"ICA"];
		[currentAccount setUpdatedDate:[NSDate date]];
		
		[f release];
		
		[self emptyCurrentProperty];
	}
	else if(isParsingAccount && [elementName isEqualToString:@"label"])
	{
		[self emptyCurrentProperty];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{     
    if (qName) {
        elementName = qName;
    }
    
	
	if(isParsingAccounts && [elementName isEqualToString:@"ul"])
	{
		isParsingAccounts = NO;
	}
	else if(isParsingAccount && [elementName isEqualToString:@"a"])
	{
		NSString *accountName = [self.contentsOfCurrentProperty stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
		accountName = [accountName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		
        // If the account name changed we update and also change the user set account name.
        if(![accountName isEqualToString:currentAccount.accountName])
        {
            [currentAccount setAccountName: accountName];
            [currentAccount setDisplayName: accountName];
        }
	}
	else if((isParsingAmount || isParsingAvailableAmount) && [elementName isEqualToString:@"div"] )
	{
		NSString *amountString = [self.contentsOfCurrentProperty stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
		amountString = [amountString stringByReplacingOccurrencesOfString:@" " withString:@""];
		amountString = [amountString stringByReplacingOccurrencesOfString:@"." withString:@""];
		
		NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		[f setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"] autorelease]];
		
		
		if(isParsingAmount)
		{
			[currentAccount setAmount:[f numberFromString:amountString]];
			isParsingAmount = NO;
		}
		else if(isParsingAvailableAmount)
		{
			[currentAccount setAvailableAmount:[f numberFromString:amountString]];
			isParsingAvailableAmount = NO;
		}
				
		[f release];
	}	
	else if(isParsingAccount && [elementName isEqualToString:@"li"])
	{
		debug_NSLog(@"%@. %@ -> %@ kr. Disponibelt: %@", currentAccount.accountid, currentAccount.accountName, currentAccount.amount, currentAccount.availableAmount);
		
		NSError * error;
		// Store the objects
		if (![managedObjectContext save:&error]) {
			
			// Handle the error?
			NSLog(@"%@, %@, %@", [error domain], [error localizedDescription], [error localizedFailureReason]);
			
		}
		
		accountsParsed++;
		isParsingAccount = NO;
	}
	else if(isParsingAccount && [elementName isEqualToString:@"label"])
	{
		NSString *labelString = [self.contentsOfCurrentProperty stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\t\n "]];
		
		if([[labelString lowercaseString] isEqualToString:@"saldo"])
		{
			isParsingAmount = YES;
			[self emptyCurrentProperty];				
		}
		else if([[labelString lowercaseString] isEqualToString:@"disponibelt"])
		{
			isParsingAvailableAmount = YES;
			[self emptyCurrentProperty];
		}
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (self.contentsOfCurrentProperty) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        [self.contentsOfCurrentProperty appendString:string];
    }
}


#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
	[contentsOfCurrentProperty release];
	[managedObjectContext release];
	[super dealloc];
}

@end
