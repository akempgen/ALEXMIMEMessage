//
//  ALEXAppDelegate.m
//  MIMEMessage
//
//  Created by Alexander Kempgen on 02.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ALEXAppDelegate.h"

#import "ALEXMIMEMessage.h"



@interface ALEXAppDelegate () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *sourceTextField;
@property (weak) IBOutlet NSOutlineView *outlineView;


@property (strong) ALEXMIMEMessage *mimeMessage;

@end


@implementation ALEXAppDelegate



@synthesize window = _window;

@synthesize sourceTextField = _sourceTextField;
@synthesize outlineView = _outlineView;


@synthesize mimeMessage = _mimeMessage;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
	
	/*
	//NSURL *jasperMIMEURL = [[NSBundle mainBundle] URLForResource:@"jasper" withExtension:@"mime"];
	NSURL *jasperMIMEURL = [NSURL URLWithString:@"http://foobox.de/multipart.php"];
	if ( !jasperMIMEURL) return;
	
	NSError *error;
	NSData *jasperMIMEData = [NSData dataWithContentsOfURL:jasperMIMEURL options:0 error:&error];
	NSString *jasperMIMEString = [[NSString alloc] initWithData:jasperMIMEData encoding:NSASCIIStringEncoding];
	if ( !jasperMIMEData) {
		[self.sourceTextField setStringValue:[error description]];
		return;
	}
	[self.sourceTextField setStringValue:jasperMIMEString];
	 
	 
	 ALEXMIMEParser* parser = [[ALEXMIMEParser alloc] initWithData:jasperMIMEData];
	 
	 [parser setDelegate:self];
	 
	 if ( ![parser parse] )
	 ALEXLog(@"parser error: " / *, [parser lastError]* /);
	else
		ALEXLog(@"parsererfolg!");
	

	*/
	
	
	
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.heise.de/icons/ho/heise_online_logo_top.gif"]];
	[urlRequest setValue:@"bytes=0-10,20-50" forHTTPHeaderField:@"Range"];
	
	
	[NSURLConnection sendAsynchronousRequest:urlRequest
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error)
	 {
		 NSDictionary *headerFields = [(NSHTTPURLResponse*)urlResponse allHeaderFields];
		 
		 NSMutableData *message = [NSMutableData data];
		 
		 for (NSString *key in headerFields)
		 {
			 [message appendData:[[key stringByAppendingFormat:@": %@%@", [headerFields objectForKey:key], @"\r\n"] dataUsingEncoding:NSASCIIStringEncoding]];
		 }
		 [message appendData:data];
		 
		 NSString *source = [[NSString alloc] initWithData:message encoding:NSASCIIStringEncoding];
		 [self.sourceTextField setStringValue:source];
		 
		 
		 ALEXMIMEMessage *MIMEMessage = [[ALEXMIMEMessage alloc] initWithData:message];
		 
		 ALEXLogObject(MIMEMessage);
		 
		 self.mimeMessage = MIMEMessage;
		 
		 [self.outlineView reloadData];
		 
	 }];
}


#pragma mark - NSOutlineViewDataSource


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
{
	if ( !item )
		return ( self.mimeMessage ? 1 : 0 );
	
	else if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return [[item subparts] count];
	
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
	if ( !item )
		return self.mimeMessage;
	
	else if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return [[item subparts] objectAtIndex:index];
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return ([[item subparts] count] > 0);
	
	return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
	return item;
}

#pragma mark - NSOutlineViewDelegate

/*
 View Based OutlineView: See the delegate method -tableView:viewForTableColumn:row: in NSTableView.
 */
/*
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSView* view;
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		view = [outlineView makeViewWithIdentifier:@"ProjectCell" owner:self];
	
	
	//AKLogObject(view);
	
	
	
	return view;
}
*/


/* View Based OutlineView: See the delegate method -tableView:rowViewForRow: in NSTableView.
 */
/*
 - (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item NS_AVAILABLE_MAC(10_7);
 */

/* View Based OutlineView: This delegate method can be used to know when a new 'rowView' has been added to the table. At this point, you can choose to add in extra views, or modify any properties on 'rowView'.
 */
/*
 - (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
 {
 AKLog(@"rowView %@ row: %d", rowView, row);
 
 if ( [[outlineView itemAtRow:row] isKindOfClass:[ALEXMIMEMessage class]] )
 {
 AKLogObject(@"JA");
 rowView.floating = YES;
 // doesnt work
 }
 }
 */

/* View Based OutlineView: This delegate method can be used to know when 'rowView' has been removed from the table. The removed 'rowView' may be reused by the table so any additionally inserted views should be removed at this point. A 'row' parameter is included. 'row' will be '-1' for rows that are being deleted from the table and no longer have a valid row, otherwise it will be the valid row that is being removed due to it being moved off screen.
 */
/*
 - (void)outlineView:(NSOutlineView *)outlineView didRemoveRowView:(NSTableRowView *)rowView forRow:(NSInteger)row NS_AVAILABLE_MAC(10_7);
 */
/*

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item;
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return 44.;
	
	return [outlineView rowHeight];
}
*/

/*
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return YES;
	
	return NO;
}
//*/

/*
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return NO;
	
	return YES;
}

- (BOOL) outlineView:(NSOutlineView*)outlineView shouldShowOutlineCellForItem:(id)item
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return NO;
	
	return YES;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	//AKLogObject(notification);
	
	self.selectedObject = [self.sourceList itemAtRow:[self.sourceList selectedRow]];
}
*/


@end
