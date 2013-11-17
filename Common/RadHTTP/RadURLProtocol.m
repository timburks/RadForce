//
//  RadURLProtocol.m
//
//  Created by Tim Burks on 11/02/13.
//  Copyright (c) 2013 Radtastical Inc. All rights reserved.
//

#import "RadURLProtocol.h"
#import "RadHTTPHelpers.h"

#define ROOT @"dl.dropboxusercontent.com/u/36329533/renio/videos"
#define MOCK @"192.0.2.1"

static NSMutableDictionary *originalURLs;

@interface RadURLProtocol ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@end

@implementation RadURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *host = [[request URL] host];
    // NSLog(@"HOST %@", host);

    if (![host isEqualToString:MOCK]) {
        return NO;
    }
    
/*
    NSString *scheme = [[request URL] scheme];
    NSLog(@"SCHEME: %@", scheme);
    NSLog(@"METHOD: %@", [request HTTPMethod]);
    NSLog(@"URL: %@", [request URL]);
    NSLog(@"HEADERS: %@", [request allHTTPHeaderFields]);
    if ([[request HTTPMethod] isEqualToString:@"POST"]) {
        NSLog(@"POST LENGTH: %d", (int) [[request HTTPBody] length]);
        NSDictionary *post = [[request HTTPBody] rad_URLQueryDictionary];
        NSLog(@"POST DICTIONARY: %@", post);
        NSLog(@"POST STRING: %@", [[NSString alloc]
                                   initWithData:[request HTTPBody]
                                   encoding:NSUTF8StringEncoding]);
    }
*/
    
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (void)startLoading
{
    if (!originalURLs) {
        originalURLs = [NSMutableDictionary dictionary];
    }
    
    NSMutableURLRequest *newRequest = [self.request mutableCopy];
    
    NSURL *originalURL = [self.request URL];

    NSString *originalPath = originalURL.absoluteString;
    
    NSString *newPath = [originalPath stringByReplacingOccurrencesOfString:MOCK withString:ROOT];
    
    NSLog(@"REWRITING %@ to %@", originalPath, newPath);

    NSURL *newURL = [NSURL URLWithString:newPath];
    newRequest.URL = newURL;

    [originalURLs setValue:originalPath forKey:newPath];
    
 //   NSLog(@"loading %@", [newRequest.URL absoluteString]);
 //   NSLog(@"METHOD: %@", [newRequest HTTPMethod]);
 //   NSLog(@"URL: %@", [newRequest URL]);
 //   NSLog(@"HEADERS: %@", [newRequest allHTTPHeaderFields]);
    
    [NSURLProtocol setProperty:originalURL
                        forKey:@"OriginalURL"
                     inRequest:newRequest];
    
    //newRequest.HTTPBody = data;
    
    // NSLog(@"start loading %@", self.request);
    
    // Here we set the User Agent
    //    [newRequest setValue:@"Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/29.0.1547.2 Safari/537.36 Kifi/1.0f" forHTTPHeaderField:@"User-Agent"];
    
    self.connection = [NSURLConnection connectionWithRequest:newRequest delegate:self];
}

- (void)stopLoading
{
    [self.connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response
{
    NSString *newPath = response.URL.absoluteString;
    NSString *originalPath = [originalURLs objectForKey:newPath];
    
    NSLog(@"RESTORING %@ to %@", newPath, originalPath);
    
    NSURL *originalURL = [NSURL URLWithString:originalPath];

    NSHTTPURLResponse *alternateResponse =
    [[NSHTTPURLResponse alloc] initWithURL:originalURL
                                statusCode:response.statusCode
                               HTTPVersion:@"1.1"
                              headerFields:[response allHeaderFields]];

    [self.client URLProtocol:self
          didReceiveResponse:alternateResponse
          cacheStoragePolicy:NSURLCacheStorageAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}


@end