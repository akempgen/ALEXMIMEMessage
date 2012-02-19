//
//  ALEXAppDelegate.m
//  MIMEMessage
//
//  Created by Alexander Kempgen on 02.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
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
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.heise.de/icons/ho/heise_online_logo_top.gif"]];
	[urlRequest setValue:@"bytes=0-1,2-3,4-5" forHTTPHeaderField:@"Range"];
	
	
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
		return ( [item isMultipart] ? [[item objectValue] count] : 0 );
	
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
	if ( !item )
		return self.mimeMessage;
	
	else if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return ( [item isMultipart] ? [[item objectValue] objectAtIndex:index] : nil );
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
	if ( [item isKindOfClass:[ALEXMIMEMessage class]] )
		return [item isMultipart];
	
	return YES;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
	return item;
}

#pragma mark - NSOutlineViewDelegate



@end
