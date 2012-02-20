//
//  ALEXMIMEMessage.m
//  ALEXMIMETools
//
//  Created by Alexander Kempgen on 11.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import "ALEXMIMEMessage.h"

#import "NSString+ALEXMIMEMessage.h"





NSString *const ALEXMIMEHeaderNameMIMEVersion				= @"MIME-Version";
NSString *const ALEXMIMEHeaderNameContentType				= @"Content-Type";
NSString *const ALEXMIMEHeaderNameContentTransferEncoding	= @"Content-Type-Encoding";


NSString *const ALEXMIMEContentTypeMultipart					= @"multipart";
NSString *const ALEXMIMEContentTypeMultipartSubtypeAlternative	= @"alternative";
NSString *const ALEXMIMEContentTypeMultipartSubtypeMixed		= @"mixed";


NSString *const ALEXMIMEContentTypeMultipartParameterBoundary	= @"boundary";


@interface ALEXMIMEMessage ()

@property (nonatomic, copy, readwrite)	NSDictionary	*headerFields;
@property (nonatomic, copy, readwrite)	id				objectValue;


@property (nonatomic, assign, readwrite)	BOOL			isMultipart;


@end


@implementation ALEXMIMEMessage

@synthesize headerFields	= _headerFields;
@synthesize objectValue		= _objectValue;

@synthesize isMultipart		= _isMultipart;


- (id) initWithHeaderFields:(NSDictionary*)headerFields objectValue:(id)objectValue
{
	self = [self init];
	if ( self )
	{
		// deep copy?
		self.headerFields	= headerFields;
		
		// do some parsing? converting to image? store this at all?
		self.objectValue	= objectValue;
		
		if ( [objectValue isKindOfClass:[NSArray class]] )
			self.isMultipart = YES;
		
		
		// return a different subclass depending on headers and object value?
		
		
	}
	return self;
}



@end








#define ALEXMIMEMessage_CRLF			@"\r\n"
#define ALEXMIMEMessage_Colon			@":"
#define ALEXMIMEMessage_DoubleHyphen	@"--"


@implementation ALEXMIMEMessage (ALEXMIMEDeserialization)


// Convenience

- (id) initWithHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse bodyData:(NSData*)bodyData;
{
	return [self initWithHeaderFields:[HTTPURLResponse allHeaderFields] bodyData:bodyData];
}

- (id) initWithHeaderFields:(NSDictionary*)headerFields bodyData:(NSData *)bodyData
{
	return [self initWithHeaderFields:headerFields data:bodyData bodyRange:NSMakeRange(0, [bodyData length])];
	
}


// Parsing

- (id) initWithData:(NSData *)messageData
{
	return [self initWithData:messageData messageRange:NSMakeRange(0, [messageData length])];
}

- (id) initWithData:(NSData *)messageData messageRange:(NSRange)messageRange
{
	ALEXLogDataAsASCIIString([messageData subdataWithRange:messageRange]);
	
	NSCharacterSet *wsCS = [NSCharacterSet whitespaceCharacterSet];
	
	NSUInteger location = messageRange.location;
	NSUInteger dataLength = messageRange.length;
	
	NSMutableArray *unfoldedHeaderFields = [NSMutableArray array];
	
	
	while ( location < dataLength )
	{
		NSUInteger lineBeginning = location;
		
		
		
		NSRange range = NSMakeRange(location, dataLength-location);
		NSRange crlfRange = [messageData rangeOfData:[ALEXMIMEMessage_CRLF dataUsingEncoding:NSUTF8StringEncoding] options:0 range:range];
		
		//ALEXLog(@"range: location %u length %u", range.location, range.length);
		//ALEXLog(@"crlfRange: location %u length %u", crlfRange.location, crlfRange.length);
		
		if ( crlfRange.location == NSNotFound )
		{
			ALEXLog(@"parsing error, no header found, not even a crlf");
			return nil;
		}
		
		
		if ( crlfRange.location == location )
		{
			ALEXLog(@"header end");
			location += 2;
			break;
		}
		
		NSUInteger lineLength = crlfRange.location-lineBeginning;
		
//#warning this can change for subparts? use data instead?
		NSStringEncoding stringEncoding = NSUTF8StringEncoding;
		NSString *line = [[NSString alloc] initWithData:[messageData subdataWithRange:NSMakeRange(lineBeginning, lineLength)] encoding:stringEncoding];
		
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
	
	
	NSRange bodyRange = NSMakeRange(location, messageRange.location + messageRange.length - location);
	
	
	
	NSMutableDictionary *headerFieldsDictionary = [NSMutableDictionary dictionaryWithCapacity:[unfoldedHeaderFields count]];
	
	// could also do this with nsdata, necessary?
	for ( NSString* headerField in unfoldedHeaderFields )
	{
		NSRange range = [headerField rangeOfString:ALEXMIMEMessage_Colon];
		if ( range.location == NSNotFound )
		{
			ALEXLog(@"parsing error, no colon (':') in header field: %@", headerField);
		}
		
		NSString *fieldName = [headerField substringToIndex:range.location];
		NSString *fieldBody = [[headerField substringFromIndex:range.location+range.length] stringByTrimmingCharactersInSet:wsCS];
		
		[headerFieldsDictionary setObject:fieldBody forKey:fieldName];
	}
	
	
	return [self initWithHeaderFields:[headerFieldsDictionary copy] data:messageData bodyRange:bodyRange];
}


- (id) initWithHeaderFields:(NSDictionary*)headerFields data:(NSData *)messageData bodyRange:(NSRange)bodyRange
{
	NSParameterAssert(headerFields != nil);
	NSParameterAssert(messageData != nil);
	
	id objectValue = nil;
	
	ALEXLogDataAsASCIIString([messageData subdataWithRange:bodyRange]);
	
	NSString *contentType = [headerFields objectForKey:ALEXMIMEHeaderNameContentType];
	//ALEXLogObject(contentType);
	NSString *mediaType = [[contentType ALEXMIMEMessage_firstValueInHeaderField] lowercaseString];
	//ALEXLogObject(mediaType);
	
	if ( [mediaType hasPrefix:ALEXMIMEContentTypeMultipart] )
	{
		NSMutableArray *subparts = [NSMutableArray array];
		
		
		
		NSString *boundary = [contentType ALEXMIMEMessage_valueInHeaderFieldForKey:ALEXMIMEContentTypeMultipartParameterBoundary];
		ALEXLogObject(boundary);
		
		
		NSData *boundaryData = [[ALEXMIMEMessage_CRLF ALEXMIMEMessage_DoubleHyphen stringByAppendingString:boundary] dataUsingEncoding:NSASCIIStringEncoding];
		
		
		ALEXLogDataAsASCIIString([messageData subdataWithRange:bodyRange]);
		
		NSUInteger location = bodyRange.location;
		NSUInteger bodyLength = bodyRange.length;
		while ( bodyLength > 0 )
		{
			
			ALEXLog(@"bodyRange.location: %u .length %u", bodyRange.location, bodyRange.length);
			
			NSRange boundaryRange = [messageData rangeOfData:boundaryData options:0 range:NSMakeRange(location, bodyLength)];
			ALEXLog(@"boundaryRange.location: %u .length %u", boundaryRange.location, boundaryRange.length);
			/*
			NSData *partData = [messageData subdataWithRange:NSMakeRange(location, boundaryRange.location-location)];
			
			
			ALEXLogDataAsASCIIString(partData);
			*/
			
			
			ALEXMIMEMessage *subpart = [[ALEXMIMEMessage alloc] initWithData:messageData messageRange:NSMakeRange(location, boundaryRange.location-location)];
			if (subpart) {
				[subparts addObject:subpart];
			}
			
			
			bodyLength -= (boundaryRange.location + boundaryRange.length -location);
			location = boundaryRange.location + boundaryRange.length;
#warning whitespace +crlf überspringen
			
			NSRange doubleHyphenRange = [messageData rangeOfData:[ALEXMIMEMessage_DoubleHyphen dataUsingEncoding:NSASCIIStringEncoding] options:0 range:NSMakeRange(location, 2)];
			if ( doubleHyphenRange.location != NSNotFound )
				break;
			
			NSRange crlfRange = [messageData rangeOfData:[ALEXMIMEMessage_CRLF dataUsingEncoding:NSASCIIStringEncoding] options:0 range:NSMakeRange(location, bodyLength)];
			
			bodyLength -= (crlfRange.location + crlfRange.length -location);
			location = crlfRange.location + crlfRange.length;
			
		}
		
		
		objectValue = subparts;
	}
	else
	{
		//objectValue = [messageData subdataWithRange:bodyRange];
		NSString *string = [[NSString alloc] initWithData:[messageData subdataWithRange:bodyRange] encoding:NSUTF8StringEncoding];
		objectValue = [string stringByReplacingOccurrencesOfString:ALEXMIMEMessage_CRLF withString:@"  »  "];
	}
	// do other parsing here, like creating nsimages
	
	
	
	return [self initWithHeaderFields:headerFields objectValue:objectValue];
}

@end




@implementation ALEXMIMEMessage (ALEXMIMESerialization)

- (NSMutableURLRequest*) mutableURLRequestWithURL:(NSURL*)URL
{
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:URL];
	
	NSDictionary *HTTPHeaderFields;
	NSData *httpBody = [self MIMEDataWithOptions:ALEXMIMESerializationCreateHTTPHeaders headerFields:&HTTPHeaderFields];
	
	[urlRequest setAllHTTPHeaderFields:HTTPHeaderFields];
	[urlRequest setHTTPBody:httpBody];
	
	return urlRequest;
}

- (NSData*) MIMEData
{
	return [self MIMEDataWithOptions:ALEXMIMESerializationDefaultOptions];
}

- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options
{
	return [self MIMEDataWithOptions:options headerFields:NULL];
}


- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options headerFields:(NSDictionary**)outHeaderFields
{
	NSMutableData *MIMEData = [NSMutableData data];
	
	if ( outHeaderFields )
	{
		*outHeaderFields = [self.headerFields copy];
	}
	else
	{
		
		NSMutableArray *foldedHeaderFields = [NSMutableArray arrayWithCapacity:[self.headerFields count]];
		for (NSString *headerName in self.headerFields)
		{
			NSUInteger maxLineLength = 80; // should be configurable through options
			
			
			NSString *line = [NSString stringWithFormat:@"%@: %@", headerName, [self.headerFields objectForKey:headerName]];
			if ( [line length] < maxLineLength )
			{
				[foldedHeaderFields addObject:line];
			}
			else
			{
				// header field folding
				NSMutableArray *lines = [NSMutableArray arrayWithCapacity:[line length]/ maxLineLength];
				
				// this might not be correct, check rfcs. it's definately not the preferred way, because it does not fold at syntactical borders
				NSUInteger searchLocation = 0;
				
				// loop
				NSRange lastWhitespaceRange = [line rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch range:NSMakeRange(searchLocation, maxLineLength)];
				
				[lines addObject:[line substringWithRange:NSMakeRange(searchLocation, searchLocation + lastWhitespaceRange.location)]];
				searchLocation += lastWhitespaceRange.location;
				// end loop
				
				
				[foldedHeaderFields addObjectsFromArray:lines];
			}
		}
		
		NSString *headerSection = [foldedHeaderFields componentsJoinedByString:ALEXMIMEMessage_CRLF];
		
		[MIMEData appendData:[headerSection dataUsingEncoding:NSASCIIStringEncoding]];
		[MIMEData appendData:[ALEXMIMEMessage_CRLF ALEXMIMEMessage_CRLF dataUsingEncoding:NSASCIIStringEncoding]];
	}
	
	
	return MIMEData;
}


@end
