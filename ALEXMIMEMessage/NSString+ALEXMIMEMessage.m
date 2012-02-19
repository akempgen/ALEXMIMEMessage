//
//  NSString+ALEXMIMEMessage.m
//  ALEXMIMEMessage
//
//  Created by Alexander Kempgen on 05.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import "NSString+ALEXMIMEMessage.h"

@implementation NSString (ALEXMIMEMessage)

- (NSDictionary*) ALEXMIMEMessage_headerFields
{
	NSMutableDictionary *fields	= [NSMutableDictionary dictionary];
	for ( NSString *line in [self componentsSeparatedByString:@"\r\n"] )
	{
		if ( ![line length] )
			break;
		
		NSUInteger location = [line rangeOfString:@": "].location;
		if ( location == NSNotFound )
			break;
		
		NSString *key	= [line substringToIndex:location];
		NSString *value	= [line substringFromIndex:location+2];
		if ( key && value )
			[fields setObject:value forKey:key];
	}
	
	return [fields copy];
}


- (NSString*) ALEXMIMEMessage_firstValueInHeaderField
{
	NSUInteger location = [self rangeOfString:@";"].location;
	NSString *value;
	if ( location != NSNotFound )
		value = [self substringToIndex:location];
	else
		value = self;
	return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


- (NSString*) ALEXMIMEMessage_valueInHeaderFieldForKey:(NSString*)key
{
	// Content-Type of a multipart msg:
	// multipart/related; type="text/xml"; start="<4C63F0A0988D8EFCCA90038F5E981D5F>"; 	boundary="----=_Part_23_1584902333.1316137295808"
	
	// check this method with the mime rfcs
	
	NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
	NSArray *fields = [self componentsSeparatedByString:@";"];
	for ( NSString *keyAndValue in fields )
	{
		NSString *trimmedKeyAndValue = [keyAndValue stringByTrimmingCharactersInSet:whitespaceCharacterSet];
		if ( [trimmedKeyAndValue hasPrefix:key] )
		{
			NSUInteger location = [keyAndValue rangeOfString:@"="].location;
			if ( location != NSNotFound )
			{
				NSString *value = [[keyAndValue substringFromIndex:location+1] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
				if ( [value hasPrefix:@"\""] && [value hasSuffix:@"\""] )
					value = [value substringWithRange:NSMakeRange(1, [value length]-2)];
				return value;
			}
		}
	}
	
	return nil;
}

@end
