//
//  ALEXMIMEMessage.h
//  ALEXMIMETools
//
//  Created by Alexander Kempgen on 11.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString *const ALEXMIMEHeaderNameMIMEVersion;
extern NSString *const ALEXMIMEHeaderNameContentType;
extern NSString *const ALEXMIMEHeaderNameContentTransferEncoding;


/*
#define _kCFHTTPMessageAcceptRangesHeader		CFSTR("Accept-Ranges")
#define _kCFHTTPMessageCacheControlHeader		CFSTR("Cache-Control")
#define _kCFHTTPMessageConnectHeader			CFSTR("Connection")
#define _kCFHTTPMessageContentLanguageHeader	CFSTR("Content-Language")
#define _kCFHTTPMessageContentLengthHeader		CFSTR("Content-Length")
#define _kCFHTTPMessageContentLocationHeader	CFSTR("Content-Location")
#define _kCFHTTPMessageContentTypeHeader		CFSTR("Content-Type")
#define _kCFHTTPMessageDateHeader				CFSTR("Date")
#define _kCFHTTPMessageEtagHeader				CFSTR("Etag")
#define _kCFHTTPMessageExpiresHeader			CFSTR("Expires")
#define _kCFHTTPMessageLastModifiedHeader		CFSTR("Last-Modified")
#define _kCFHTTPMessageLocationHeader			CFSTR("Location")
#define _kCFHTTPMessageProxyAuthenticateHeader	CFSTR("Proxy-Authenticate")
#define _kCFHTTPMessageServerHeader				CFSTR("Server")
#define _kCFHTTPMessageSetCookieHeader			CFSTR("Set-Cookie")
*/





@interface ALEXMIMEMessage : NSObject

- (id) initWithHeaderFields:(NSDictionary*)headerFields objectValue:(id)objectValue;

@property (nonatomic, copy, readonly)	NSDictionary	*headerFields;
@property (nonatomic, copy, readonly)	id				objectValue;

@property (nonatomic, assign, readonly)	BOOL			isMultipart;

@end

/*
@interface ALEXMIMEMultipartMessage : ALEXMIMEMessage



@end
*/



@interface ALEXMIMEMessage (ALEXMIMEDeserialization)


// Convenience for usage with NSURLConnection
/*
 Calls -initWithHeaderFields:bodyData: with the result of [HTTPURLResponse allHeaderFields]
 */
- (id) initWithHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse bodyData:(NSData*)bodyData;
/*
 Calls -initWithHeaderFields:data:bodyRange: with NSMakeRange(0, [bodyData length]) as bodyRange
 */
- (id) initWithHeaderFields:(NSDictionary*)headerFields bodyData:(NSData *)data;



// Parsing magic happens here
/*
 Parses the header section and then calls -initWithHeaderFields:data:bodyRange:
 */
- (id) initWithData:(NSData *)messageData;
- (id) initWithData:(NSData *)messageData messageRange:(NSRange)messageRange; // make private?


/*
 Parses the body (for multipart) and calls -initWithHeaderFields:objectValue:
 */
- (id) initWithHeaderFields:(NSDictionary*)headerFields data:(NSData *)messageData bodyRange:(NSRange)bodyRange;



@end






enum {
    ALEXMIMESerializationDefaultOptions				= 0,
	
	ALEXMIMESerializationCreateDefaultHeaders,			// Verbose Headers to avoid confusion
	ALEXMIMESerializationCreateMinimalHeaders,			// Don't include default and implied values in Headers
	ALEXMIMESerializationCreateHTTPHeaders,				// Add headers necessary for http
	ALEXMIMESerializationCreateMailHeaders,				// Add headers necessary for Mail
	
	ALEXMIMESerializationLineLength1000,				// Default?
	ALEXMIMESerializationLineLength80,					// For SMTP?
	ALEXMIMESerializationLineLengthUnlimited,			// Non-Standard
	
	ALEXMIMESerializationEncodeAsBinary,				// Default?
	ALEXMIMESerializationEncodeAs7bit,					// For SMTP?
	ALEXMIMESerializationEncodeAs8bit,
	
	
	
	ALEXMIMESerializationSMTPOptions				= (ALEXMIMESerializationCreateMailHeaders + ALEXMIMESerializationLineLength80 + ALEXMIMESerializationEncodeAs7bit),
	
};
typedef NSUInteger ALEXMIMESerializationOptions;




@interface ALEXMIMEMessage (ALEXMIMESerialization)

// Convenience
- (NSMutableURLRequest*) mutableURLRequestWithURL:(NSURL*)URL;


/*
 returns [self MIMEDataWithOptions:ALEXMIMESerializationDefaultOptions]
 */

- (NSData*) MIMEData;

/*
 returns [self MIMEDataWithOptions:options headerFields:NULL]
 */
- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options;

/*
 headerFields:
 - pass NULL to have the header section included in the MIMEData according to MIME rules
 - pass a pointer, if you want the header fields in a separate NSDictionary, for use with -[NSMutableURLRequest setHeaderFields:] or other APIs
 */
- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options headerFields:(NSDictionary**)headerFields;

@end

