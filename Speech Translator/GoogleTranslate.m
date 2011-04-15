//
//  GoogleTranslate.m
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "GoogleTranslate.h"


@implementation GoogleTranslate


@synthesize delegate;


- (void)dealloc
{
	if (fetcher) [fetcher stopFetching], [fetcher release], fetcher = nil;	
    
    [super dealloc];
}


- (void)translate:(NSString *)text from:(NSString *)inLanguage to:(NSString *)outLanguage
{
	NSString *sourceText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];	
	NSString *langs = [[NSString stringWithFormat:@"%@|%@", inLanguage, outLanguage] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *requestURL = [NSString stringWithFormat:@"%@&q=%@&langpair=%@", GoogleURL, sourceText, langs];
	
	NSURL *url = [NSURL URLWithString:requestURL];
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	
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
        NSLog(@"GT ParseServerResponse: Response is empty.");
        
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
        
        NSLog(@"GT ParseServerResponse: JSONReader failed or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;
    }
    
    NSDictionary *rData = [responseData objectForKey:@"responseData"];
    
    if ((!rData) || (![rData isKindOfClass:[NSDictionary class]]))
    {
        
        NSLog(@"GT ParseServerResponse: No responseData or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;
    }

    NSString *translatedText = [rData objectForKey:@"translatedText"];
    
    if ((!translatedText) || (![translatedText isKindOfClass:[NSString class]]))
    {
        
        NSLog(@"GT ParseServerResponse: No translatedText or Unexpected response type");
        
        if([delegate respondsToSelector:@selector(didFail)])
        {
            [delegate didFail];
        }							
        
        return;
    }
    
    NSLog(@"GT ParseServerResponse: Translated (%@)", translatedText);
    
    if([delegate respondsToSelector:@selector(didTranslate:)])
    {
        [delegate didTranslate:translatedText];
    }
}

- (void)httpFetcher:(GDataHTTPFetcher *)aFetcher didFail:(NSError *)error
{
    [fetcher release], fetcher = nil;
    
    NSLog(@"GoogleTranslate fetcher did failed");
    
    if([delegate respondsToSelector:@selector(didFail)])
    {
        [delegate didFail];
    }							
}


@end
