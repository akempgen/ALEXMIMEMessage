ALEXMIMEMessage
===============

A class to parse received MIME (Multipurpose Internet Mail Extensions) messages into objects and to construct MIME messages from objects for sending.

Supports Multipart.

Usage
-----

One example of using ALEXMIMEMessage to parse the response of a NSURLConnection (also see included Test App):

	[NSURLConnection sendAsynchronousRequest:URLRequest
									   queue:queue
						   completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error)
	 {
		 self.mimeMessage = [[ALEXMIMEMessage alloc] initWithHTTPURLResponse:urlResponse bodyData:data];
		 [self.outlineView reloadData];
	 }];

API
---

Creation

		- (id) initWithHeaderFields:(NSDictionary*)headerFields objectValue:(id)objectValue;
		
		@property (nonatomic, copy, readonly)	NSDictionary	*headerFields;
		@property (nonatomic, copy, readonly)	id				objectValue;
	
		@property (nonatomic, assign, readonly)	BOOL			isMultipart;

Deserialization

		- (id) initWithHTTPURLResponse:(NSHTTPURLResponse*)HTTPURLResponse bodyData:(NSData*)bodyData;
		- (id) initWithHeaderFields:(NSDictionary*)headerFields bodyData:(NSData *)data;
		
		- (id) initWithData:(NSData *)messageData;
		- (id) initWithData:(NSData *)messageData messageRange:(NSRange)messageRange;
		- (id) initWithHeaderFields:(NSDictionary*)headerFields data:(NSData *)messageData bodyRange:(NSRange)bodyRange;

Serialization

		- (NSMutableURLRequest*) mutableURLRequestWithURL:(NSURL*)URL;

		- (NSData*) MIMEData;
		- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options;
		- (NSData*) MIMEDataWithOptions:(ALEXMIMESerializationOptions)options headerFields:(NSDictionary**)headerFields;


Status
------

**Note:** This code is work in progress and should not be used for anything yet, that would be crazy. While the following RFCs have been considered while writing this code, it is far from being compliant.

Relevant RFCs:

* [RFC 5322: Internet Message Format](http://tools.ietf.org/html/rfc5322)
* [RFC 2045: MIME Part One: Format of Internet Message Bodies](http://tools.ietf.org/html/rfc2045)
* [RFC 2046: MIME Part Two: Media Types](http://tools.ietf.org/html/rfc2046)
* [RFC 2047: MIME Part Three: Message Header Extensions for Non-ASCII Text](http://tools.ietf.org/html/rfc2047)
* [RFC 4288: Media Type Specifications and Registration Procedures](http://tools.ietf.org/html/rfc4288)
* [RFC 4289: MIME Part Four: Registration Procedures](http://tools.ietf.org/html/rfc4289)
* [RFC 4289: MIME Part Five: Conformance Criteria and Examples](http://tools.ietf.org/html/rfc2049)


License
-------

Not licensed (yet).

For two reasons: I simply haven't picked one and I *really* don't want you to use it yet


Version History
---------------
No releases.