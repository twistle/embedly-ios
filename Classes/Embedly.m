// Copyright 2011 Embed.ly, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Embedly.m
//  Embedly
//
//  Created by Thomas Boetig on 2/16/11.
//

#import "Embedly.h"
#import "AFNetworking.h"

@implementation Embedly

//===========================================================
#pragma mark -
#pragma mark Lifecycle
//===========================================================

- (id)init {
	_key = nil;
	_userAgent = kEmbedlyDefaultUserAgent;
	return self;
}

- (id)initWithKey:(NSString *)k {
	_key = k;
	
	_endpoint = kEmbedlyOembedEndpoint;
	_userAgent = kEmbedlyDefaultUserAgent;

	return self;
}

- (id)initWithKey:(NSString *)k andEndpoint:(NSString *)e {
	_key = k;
	
	if( self.key == nil){
		_endpoint = kEmbedlyOembedEndpoint;
	} else {
		NSString *u = [[NSString alloc] initWithString:[e lowercaseString]];
        if ([u isEqualToString:@"preview"]){
            _endpoint = kEmbedlyPreviewEndpoint;
        } else if ([u isEqualToString:@"objectify"]){
            _endpoint = kEmbedlyObjectifyEndpoint;
        } else if ([u isEqualToString:@"oembed"]){
            _endpoint = kEmbedlyOembedEndpoint;
        } else {
            _endpoint = e;
        }
	}
	_userAgent = kEmbedlyDefaultUserAgent;
    
	
	return self;
}


- (NSString *)escapeUrlWithString:(NSString *)string {
    return [string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
}

//===========================================================
#pragma mark -
#pragma mark API Access
//===========================================================

// Call the Embedly API with One URL. Will return a Dictionary
- (void)callWithUrl:(NSString *)url {
    
    url = [self escapeUrlWithString:url];
    
	NSString* request = [[NSString alloc] initWithFormat:@"https://%@/%@?&url=%@", kEmbedlyProPath, self.endpoint, url];
    if( self.key != nil){
		request = [request stringByAppendingFormat:@"&key=%@", self.key];
	}
	if (self.maxWidth != nil){
		request = [request stringByAppendingFormat:@"&maxwidth=%@", self.maxWidth];
	}
	if (self.maxHeight != nil){
		request = [request stringByAppendingFormat:@"&maxheight=%@", self.maxHeight];
	}
	
	NSURL* u = [[NSURL alloc] initWithString:request];
    [self callEmbedlyWithURL:u];
}

// Call the Embedly API with Multiple URLs. Will return an Array of Dictionaries
- (void)callWithArray:(NSArray *)urls {
	NSString* set = @"";
	for( NSString *s in urls){
		set = [set stringByAppendingString:@","];
		set = [set stringByAppendingString: [self escapeUrlWithString:s]];
	}
	set = [set substringFromIndex:1];	// remove the initial , from the url string
	
	NSString* request = [[NSString alloc] initWithFormat:@"https://%@/%@?&urls=%@", kEmbedlyProPath, self.endpoint, set];
	
	if( self.key != nil){
		request = [request stringByAppendingFormat:@"&key=%@", self.key];
	}
	if (self.maxWidth != nil){
		request = [request stringByAppendingFormat:@"&maxwidth=%@", self.maxWidth];
	}
	if (self.maxHeight != nil){
		request = [request stringByAppendingFormat:@"&maxheight=%@", self.maxHeight];
	}
	
	
	NSURL* u = [[NSURL alloc] initWithString:request];
	[self callEmbedlyWithURL:u];
}

- (void) callEmbedlyWithURL:(NSURL *)url{
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
	[request addValue:kEmbedlyClientHeader forHTTPHeaderField:@"X-Embedly-Client"];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(embedlyDidLoad:)]) {
            [self.delegate embedlyDidLoad:JSON];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(embedlyDidFailWithError:)]) {
            [self.delegate embedlyDidFailWithError:error];
        }
    }];
                                         
    [operation start];
}



//===========================================================
#pragma mark -
#pragma mark Singleton definitons
//===========================================================

static Embedly *sharedEmbedly = nil;

+ (Embedly *)sharedInstance {
	@synchronized(self) {
		if(sharedEmbedly == nil) {
			sharedEmbedly = [[self alloc] init];
		}
	}
	
	return sharedEmbedly;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self){
		if(sharedEmbedly == nil){
			sharedEmbedly = [super allocWithZone:zone];
		}
	}
	return sharedEmbedly;
}


@end
