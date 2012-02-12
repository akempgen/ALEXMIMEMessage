//
//  NSString+ALEXMIMETools.h
//  MIMEMessage
//
//  Created by Alexander Kempgen on 05.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ALEXMIMETools)

- (NSDictionary*) ALEXMIMETools_headerFields;
- (NSString*) ALEXMIMETools_firstValueInHeaderField;
- (NSString*) ALEXMIMETools_valueInHeaderFieldForKey:(NSString*)key;

@end
