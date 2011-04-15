//
//  GoogleASR.m
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "GoogleASR.h"


@implementation GoogleASR


@synthesize delegate;


- (void)dealloc
{
	if (fetcher) [fetcher stopFetching], [fetcher release], fetcher = nil;	

    [super dealloc];
}

- (void)speechRecognition:(NSString *)flacPath language:(NSString *)language
{
    NSData *data = [NSData dataWithContentsOfFile:flacPath];
    
    NSMutableString *requestURL = [NSMutableString stringWithString:GoogleASRURL];
    [requestURL appendString:language];

    NSURL *url = [NSURL URLWithString:requestURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    fetcher = [[GDataHTTPFetcher httpFetcherWithRequest:request] retain];
    [fetcher beginFetchWithDelegate:self
                   didFinishSelector:@selector(httpFetcher:finishedWithData:)
                     didFailSelector:@selector(httpFetcher:didFail:)];    
}


- (void)httpFetcher:(GDataHTTPFetcher *)aFetcher finishedWithData:(NSData *)retrievedData
{
    [fetcher release], fetcher = nil;

    NSString *jsonResponse = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];

    if ((!jsonResponse) || ([jsonResponse length] == 0))
    {
        NSLog(@"GA ParseServerResponse: Response is empty.");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							

        if (jsonResponse) [jsonResponse release];
        
        return;        
    }
    
    NSDictionary *responseData = [jsonResponse JSONValue];
    [jsonResponse release];
    
    if ((!responseData) || (![responseData isKindOfClass:[NSDictionary class]]))
    {
        
        NSLog(@"GA ParseServerResponse: JSONReader failed or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;
    }
    
    NSArray *tmpArray = [responseData objectForKey:@"hypotheses"];
    
    if ((!tmpArray) || (![tmpArray isKindOfClass:[NSArray class]]) || ([tmpArray count] == 0))
    {
        
        NSLog(@"GA ParseServerResponse: No hypotheses array or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;
    }
    
    NSString *result = nil;
    
    for (int i = 0; i < [tmpArray count]; i++)
    {
        NSDictionary *hypothesesDict = [tmpArray objectAtIndex:i];
        
        if ((hypothesesDict) && ([hypothesesDict isKindOfClass:[NSDictionary class]]))
        {
            NSString *utterance = [hypothesesDict objectForKey:@"utterance"];
            
            if ((utterance) && ([utterance isKindOfClass:[NSString class]]))
            {
                result = utterance;
            }
            
        }
        
    }
        
    if (!result)
    {
        NSLog(@"GA ParseServerResponse: No utterance string or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;        
    }

    NSLog(@"GA ParseServerResponse: SR (%@)", result);
    
    if([delegate respondsToSelector:@selector(didSR:)])
    {
        [delegate didSR:result];
    }						
}


- (void)httpFetcher:(GDataHTTPFetcher *)aFetcher didFail:(NSError *)error
{
    [fetcher release], fetcher = nil;
    
    NSLog(@"GoogleASR fetcher did failed");
    
    if([delegate respondsToSelector:@selector(didFail)])
    {
        [delegate didFail];
    }							
}

@end
