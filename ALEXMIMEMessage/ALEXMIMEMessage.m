//
//  ALEXMIMEMessage.m
//  ALEXMIMETools
//
//  Created by Alexander Kempgen on 11.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import "ALEXMIMEMessage.h"




@interface ALEXMIMEMessage ()

@property (nonatomic, copy, readwrite)	NSDictionary	*headerFields;
@property (nonatomic, copy, readwrite)	id				objectValue;

@property (nonatomic, copy, readwrite)	NSArray			*subparts;

@end


@implementation ALEXMIMEMessage

@synthesize headerFields	= _headerFields;
@synthesize objectValue		= _objectValue;

@synthesize subparts		= _subparts;


- (id) initWithHeaderFields:(NSDictionary*)headerFields objectValue:(id)objectValue
{
	self = [self init];
	if ( self )
	{
		// deep copy?
		self.headerFields	= headerFields;
		
		// do some parsing? converting to image? store this at all?
		self.objectValue	= objectValue;
		
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
	ALEXLogObject([messageData subdataWithRange:messageRange]);
	
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
		NSString *fieldBody = [headerField substringFromIndex:range.location+range.length];
		
		ALEXLogObject(fieldName);
		ALEXLogObject(fieldBody);
		
	}
	
	
	return [self initWithHeaderFields:[headerFieldsDictionary copy] data:messageData bodyRange:bodyRange];
}


- (id) initWithHeaderFields:(NSDictionary*)headerFields data:(NSData *)messageData bodyRange:(NSRange)bodyRange
{
	ALEXLogObject([messageData subdataWithRange:bodyRange]);
	
	
	return nil;
}


@end
