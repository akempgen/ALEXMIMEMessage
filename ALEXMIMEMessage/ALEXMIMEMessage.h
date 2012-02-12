//
//  ALEXMIMEMessage.h
//  ALEXMIMETools
//
//  Created by Alexander Kempgen on 11.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ALEXMIMEMessage : NSObject

- (id) initWithHeaderFields:(NSDictionary*)headerFields objectValue:(id)objectValue;

@property (nonatomic, copy, readonly)	NSDictionary	*headerFields;
@property (nonatomic, copy, readonly)	id				objectValue;

@property (nonatomic, copy, readonly)	NSArray			*subparts;

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