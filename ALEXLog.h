//
//  ALEXLog.h
//  ALEXFoundation
//
//  Created by Alexander Kempgen on 24.10.11.
//  Copyright (c) 2011 Alexander Kempgen. All rights reserved.
//

#ifndef ALEXLog_h
#define ALEXLog_h


#define ALEXLog(format,...) fprintf(stderr, "%s %s\n", __PRETTY_FUNCTION__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#define ALEXLogObject(NSObject) ALEXLog(@"" #NSObject ": '%@'", NSObject)

//#define ALEXLogDataAsASCIIString(NSData) ALEXLog(@"Data " #NSData " as ASCII string: '%@'", [[NSString alloc] initWithData:NSData encoding:NSASCIIStringEncoding])

#endif
