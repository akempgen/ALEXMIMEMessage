//
//  ALEXMIMEParser.h
//  MIMEMessage
//
//  Created by Alexander Kempgen on 04.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//


@protocol ALEXMIMEParserDelegate;


@interface ALEXMIMEParser : NSObject

- (id) initWithHeaderSection:(NSDictionary*)headerSection bodyData:(NSData*)data;
- (id) initWithData:(NSData*)data;


@property (nonatomic, weak) id<ALEXMIMEParserDelegate> delegate;


- (BOOL) parse;




@end




@protocol ALEXMIMEParserDelegate <NSObject>

@optional
- (void) parserDidStartEntity:(ALEXMIMEParser *)parser;
- (void) parserDidEndEntity:(ALEXMIMEParser *)parser;

- (void) parser:(ALEXMIMEParser *)parser foundHeader:(NSDictionary *)header;

// Single-Part Messages
- (void) parser:(ALEXMIMEParser *)parser foundBody:(NSData *)body;

// Multi-Part Messages
- (void) parser:(ALEXMIMEParser *)parser foundPreamble:(NSData *)preamble;
- (void) parser:(ALEXMIMEParser *)parser foundEpilogue:(NSData *)epilogue;
- (void) parser:(ALEXMIMEParser *)parser didStartSubpartForHeader:(NSDictionary*)header;
- (void) parser:(ALEXMIMEParser *)parser didEndSubpartForHeader:(NSDictionary*)header;




@end
