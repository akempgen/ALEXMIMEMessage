//
//  NSString+ALEXMIMEMessage.h
//  ALEXMIMEMessage
//
//  Created by Alexander Kempgen on 05.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ALEXMIMEMessage)

- (NSDictionary*) ALEXMIMEMessage_headerFields;
- (NSString*) ALEXMIMEMessage_firstValueInHeaderField;
- (NSString*) ALEXMIMEMessage_valueInHeaderFieldForKey:(NSString*)key;

@end
