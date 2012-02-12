//
//  NSObject+ALEXDelegation.m
//  ALEXMIMETools
//
//  Created by Alexander Kempgen on 05.02.12.
//  Copyright (c) 2012 Alexander Kempgen. All rights reserved.
//

#import "NSObject+ALEXDelegation.h"

@implementation NSObject (ALEXDelegation)

/*
- (id) ALEXDelegation_performSelector:(SEL)adSelector withObject:(id)object
{
	if ( ![self conformsToProtocol:@protocol(ALEXDelegation)] )
		[NSException raise:@"ALEXDelegationException" format:@"It is a programmer error to call '%@' on an object that does not conform to the ALEXDelegation protocol", NSStringFromSelector(_cmd)];
	
	id ALEXDelegation_delegate = [self performSelector:@selector(ALEXDelegation_delegate)];
	Protocol* ALEXDelegation_protocol = [self performSelector:@selector(ALEXDelegation_delegateProtocol)];
	
	if ( [theDelegate respondsToSelector:aSelector] )
		return [ALEXDelegation_delegate performSelector:nssele withObject:self withObject:object];
}

*/

@end
