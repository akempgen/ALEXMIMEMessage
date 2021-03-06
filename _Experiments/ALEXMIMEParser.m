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



- (void) ALEXMIMEParserDelegate_didStartEntity;
- (void) ALEXMIMEParserDelegate_didEndEntity;
- (void) ALEXMIMEParserDelegate_didStartHeaderSection;
- (void) ALEXMIMEParserDelegate_didEndHeaderSection;
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
	[self ALEXMIMEParserDelegate_didStartEntity];
	
	/*
	NSString* testString = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
	ALEXLog(@"test:\n%@", [testString componentsSeparatedByString:@"\r\n"]);
	*/
	
	NSCharacterSet *wsCS = [NSCharacterSet whitespaceCharacterSet];
	
	NSData* data = self.data;
	NSUInteger dataLength = [data length];
	NSUInteger location = 0;
	
	NSDictionary *headerSection = self.headerSection;
	NSRange bodyRange;
	
	if ( headerSection )
	{
		bodyRange = NSMakeRange(0, dataLength);
	}
	else
	{
		[self ALEXMIMEParserDelegate_didStartHeaderSection];
		
		NSMutableArray *unfoldedHeaderFields = [NSMutableArray array];
		
		
		while ( location < dataLength )
		{
			NSUInteger lineBeginning = location;
			
			
			
			NSRange range = NSMakeRange(location, dataLength-location);
			NSRange crlfRange = [data rangeOfData:[NSData dataWithBytes:"\r\n" length:2] options:0 range:range];
			
			//ALEXLog(@"range: location %u length %u", range.location, range.length);
			//ALEXLog(@"crlfRange: location %u length %u", crlfRange.location, crlfRange.length);
			
			if ( crlfRange.location == NSNotFound )
			{
				ALEXLog(@"not found");
				break;
			}
			
			
			if ( crlfRange.location == location )
			{
				ALEXLog(@"header end");
				break;
			}
			
			NSUInteger lineLength = crlfRange.location-lineBeginning;
			
#warning this can change for subparts? use data instead?
			NSStringEncoding stringEncoding = NSASCIIStringEncoding;
			NSString *line = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(lineBeginning, lineLength)] encoding:stringEncoding];
			
			/*
			if ( [line length] < 600 )
				ALEXLog(@"line: %@", line);
			else
				ALEXLog(@"line length: %u", [line length]);
			*/
			
			if ( [wsCS characterIsMember:[line characterAtIndex:0]] )
			{
				if ( ![unfoldedHeaderFields count] )
				{
					ALEXLog(@"parsing error, whitespace at beginning of data");
					break;
				}
				
				[unfoldedHeaderFields replaceObjectAtIndex:([unfoldedHeaderFields count]-1) withObject:[[unfoldedHeaderFields lastObject] stringByAppendingString:line]];
			}
			else
			{
				[unfoldedHeaderFields addObject:line];
			}
			
			
			location += lineLength+2;
		}
		
		
		NSMutableDictionary *headerFieldsDictionary = [NSMutableDictionary dictionaryWithCapacity:[unfoldedHeaderFields count]];
		
		// could also do this with nsdata, necessary?
		for ( NSString* headerField in unfoldedHeaderFields )
		{
			NSRange range = [headerField rangeOfString:ALEXMIMETools_Colon];
			if ( range.location == NSNotFound )
			{
				ALEXLog(@"parsing error, no colon (':') in header field: %@", headerField);
			}
			
			NSString *fieldName = [headerField substringToIndex:range.location];
			NSString *fieldBody = [headerField substringFromIndex:range.location+range.length];
			
			ALEXLogObject(fieldName);
			ALEXLogObject(fieldBody);
			
		}
		
		
		
		
		
		[self ALEXMIMEParserDelegate_didEndHeaderSection];
		
		ALEXLogObject(unfoldedHeaderFields);
		
		// TODO: deep copy?
		//[self ALEXMIMEParserDelegate_foundHeaderSection:[headerSection copy]];
		
		/*
		NSUInteger headerSectionBoundaryLocation = [data rangeOfData:[ALEXMIMETools_CRLF ALEXMIMETools_CRLF dataUsingEncoding:NSASCIIStringEncoding] options:0 range:NSMakeRange(location, [data length])].location;
		
		if ( headerSectionBoundaryLocation == NSNotFound )
		{
			ALEXLog(@"parsing error: headerBoundaryLocation == NSNotFound");
			return NO;
		}
		
		NSData *headerSectionData		= [data subdataWithRange:NSMakeRange(0, headerSectionBoundaryLocation)];
		NSString *headerSectionString	= [[NSString alloc] initWithData:headerSectionData encoding:NSASCIIStringEncoding];
		headerSection					= [headerSectionString ALEXMIMETools_headerFields];
		
		[self ALEXMIMEParserDelegate_foundHeaderSection:headerSection];
		
		bodyRange = NSMakeRange(headerSectionBoundaryLocation + headerSectionBoundarySize, [data length] - headerSectionBoundaryLocation - headerSectionBoundarySize);
		*/
	}
	
//TODO: some decoding might have to happen here, like base64
	
	/*
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
		
		NSString *encapsulationBoundary = [ALEXMIMETools_CRLF ALEXMIMETools_DoubleDash stringByAppendingString:boundary];
		
		
	}
	
	[self ALEXMIMEParserDelegate_didEndEntity];
	*/
	
	return YES;
}

#pragma mark - Class Extension

- (void) ALEXMIMEParserDelegate_didStartEntity
{
	if ( [self.delegate respondsToSelector:@selector(parserDidStartEntity:)] )
		[self.delegate parserDidStartEntity:self];
	
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

- (void) ALEXMIMEParserDelegate_didEndEntity
{
	if ( [self.delegate respondsToSelector:@selector(parserDidEndEntity:)] )
		[self.delegate parserDidEndEntity:self];
}

- (void) ALEXMIMEParserDelegate_didStartHeaderSection
{
	if ( [self.delegate respondsToSelector:@selector(parserDidStartHeaderSection:)] )
		[self.delegate parserDidStartHeaderSection:self];
}


- (void) ALEXMIMEParserDelegate_didEndHeaderSection
{
	if ( [self.delegate respondsToSelector:@selector(parserDidEndHeaderSection:)] )
		[self.delegate parserDidEndHeaderSection:self];
}



- (void) ALEXMIMEParserDelegate_foundHeaderSection:(NSDictionary*)header
{
	if ( [self.delegate respondsToSelector:@selector(parser:foundHeaderSection:)] )
		[self.delegate parser:self foundHeaderSection:header];
	
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

