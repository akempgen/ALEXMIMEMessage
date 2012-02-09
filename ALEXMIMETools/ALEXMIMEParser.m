//
//  ALEXMIMEParser.m
//  MIMEMessage
//
//  Created by Alexander Kempgen on 04.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import "ALEXMIMEParser.h"

#import "ALEXMIMEDefinitions.h"
#import "NSString+ALEXMIMETools.h"


@interface ALEXMIMEParser ()

@property (nonatomic, copy) NSDictionary* headerSection;
@property (nonatomic, copy) NSData* data;



- (void) ALEXMIMEParserDelegate_didStartDocument;
- (void) ALEXMIMEParserDelegate_didEndDocument;
- (void) ALEXMIMEParserDelegate_foundHeaderSection:(NSDictionary*)headerSection;
- (void) ALEXMIMEParserDelegate_foundBody:(NSData *)body;
- (void) ALEXMIMEParserDelegate_foundPreamble:(NSData *)preamble;
- (void) ALEXMIMEParserDelegate_foundEpilogue:(NSData *)epilogue;
- (void) ALEXMIMEParserDelegate_didStartSubpartForHeader:(NSDictionary*)header;
- (void) ALEXMIMEParserDelegate_didEndSubpartForHeader:(NSDictionary*)header;

@end


@implementation ALEXMIMEParser


@synthesize delegate = _delegate;
// Class Extension
@synthesize headerSection = _headerSection;
@synthesize data = _data;


- (id)initWithHeaderSection:(NSDictionary*)headerSection bodyData:(NSData*)data
{
	self = [super init];
	if (self)
	{
		self.headerSection = headerSection;
		self.data = data;
	}
	return self;
}

- (id)initWithData:(NSData*)data
{
	return [self initWithHeaderSection:nil bodyData:data];
}


- (BOOL) parse
{
	[self ALEXMIMEParserDelegate_didStartDocument];
	
	NSData* data = self.data;
	NSUInteger location = 0;
	
	NSDictionary *headerSection = self.headerSection;
	NSRange bodyRange;
	
	if ( headerSection )
	{
		bodyRange = NSMakeRange(0, [data length]);
	}
	else
	{
		NSUInteger headerSectionBoundaryLocation = [data rangeOfData:[ALEXMIMETools_CRLF ALEXMIMETools_CRLF dataUsingEncoding:NSASCIIStringEncoding] options:0 range:NSMakeRange(location, [data length])].location;
		
		if ( headerSectionBoundaryLocation == NSNotFound )
		{
			NSLog(@"parsing error: headerBoundaryLocation == NSNotFound");
			return NO;
		}
		
		NSData *headerSectionData		= [data subdataWithRange:NSMakeRange(0, headerSectionBoundaryLocation)];
		NSString *headerSectionString	= [[NSString alloc] initWithData:headerSectionData encoding:NSASCIIStringEncoding];
		headerSection					= [headerSectionString ALEXMIMETools_headerFields];
		
		[self ALEXMIMEParserDelegate_foundHeaderSection:headerSection];
		
		
		bodyRange = NSMakeRange(headerSectionBoundaryLocation + headerSectionBoundarySize, [data length] - headerSectionBoundaryLocation - headerSectionBoundarySize);
	}
	
//TODO: some decoding might have to happen here, like base64
	
	NSString *contentType	= [headerSection objectForKey:@"Content-Type"];
	
	if ( ![[contentType ALEXMIMETools_firstValueInHeaderField] hasPrefix:@"multipart/"] )
	{
		NSData *bodyData	= [data subdataWithRange:bodyRange];
		
		[self ALEXMIMEParserDelegate_foundBody:bodyData];
	}
	else
	{
		// contentType for multipart/related:
		//multipart/related; type="text/xml"; start="<4C63F0A0988D8EFCCA90038F5E981D5F>"; 	boundary="----=_Part_23_1584902333.1316137295808"
		
		
		NSString *boundary		= [contentType ALEXMIMETools_valueInHeaderFieldForKey:@"boundary"];
		[boundary dataUsingEncoding:<#(NSStringEncoding)#>
		
		
		char newline[] = "\r\n";
		char doubleDash[] = "--";
		NSData *encapsulationBoundary = [NSString stringWithFormat:@"%@--%@", crlf, boundary];
		
		
	}
	
	[self ALEXMIMEParserDelegate_didEndDocument];
	
	return YES;
}

#pragma mark - Class Extension

- (void) ALEXMIMEParserDelegate_didStartDocument
{
	if ( [self.delegate respondsToSelector:@selector(parserDidStartDocument:)] )
		[self.delegate parserDidStartDocument:self];
	
	/*
	SEL delegateSelector = @selector(parserDidStartDocument:);
	if ( [self.delegate respondsToSelector:delegateSelector] )
		[self.delegate performSelector:delegateSelector withObject:self];
	 */
	
	/*
	if ( self.didStartDocumentHandler )
		self.didStartDocumentHandler();
	*/
}

- (void) ALEXMIMEParserDelegate_didEndDocument
{
	if ( [self.delegate respondsToSelector:@selector(parserDidEndDocument:)] )
		[self.delegate parserDidEndDocument:self];
}

- (void) ALEXMIMEParserDelegate_foundHeader:(NSDictionary*)header
{
	if ( [self.delegate respondsToSelector:@selector(parser:foundHeader:)] )
		[self.delegate parser:self foundHeader:header];
	
	/*
	 if ( self.foundHeaderHandler )
	 self.foundHeaderHandler(header);
	 */
}

- (void) ALEXMIMEParserDelegate_foundBody:(NSData *)body
{
	if ( [self.delegate respondsToSelector:@selector(parser:foundBody:)] )
		[self.delegate parser:self foundBody:body];
}

- (void) ALEXMIMEParserDelegate_foundPreamble:(NSData *)preamble
{
	if ( [self.delegate respondsToSelector:@selector(parser:foundPreamble:)] )
		[self.delegate parser:self foundPreamble:preamble];
}

- (void) ALEXMIMEParserDelegate_foundEpilogue:(NSData *)epilogue
{
	if ( [self.delegate respondsToSelector:@selector(parser:foundEpilogue:)] )
		[self.delegate parser:self foundEpilogue:epilogue];
}

- (void) ALEXMIMEParserDelegate_didStartSubpartForHeader:(NSDictionary*)header
{
	if ( [self.delegate respondsToSelector:@selector(parser:didStartSubpartForHeader:)] )
		[self.delegate parser:self didStartSubpartForHeader:header];
}

- (void) ALEXMIMEParserDelegate_didEndSubpartForHeader:(NSDictionary*)header
{
	if ( [self.delegate respondsToSelector:@selector(parser:didEndSubpartForHeader:)] )
		[self.delegate parser:self didEndSubpartForHeader:header];
}


@end

