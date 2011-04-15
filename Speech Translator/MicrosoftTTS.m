//
//  MicrosoftTTS.m
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "MicrosoftTTS.h"


@implementation MicrosoftTTS


@synthesize delegate;


- (void)dealloc
{
	if (fetcher) [fetcher stopFetching], [fetcher release], fetcher = nil;	
    
    [super dealloc];
}


- (void)textToSpeech:(NSString *)text language:(NSString *)language
{
	NSString *textToSpeech = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	NSString *requestURL = [NSString stringWithFormat:@"%@&text=%@&language=%@", SpeechURL, textToSpeech, language];	
	
	NSURL *url = [NSURL URLWithString:requestURL];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
	
	fetcher = [[GDataHTTPFetcher httpFetcherWithRequest:request] retain];
	
	[fetcher beginFetchWithDelegate:self
					   didFinishSelector:@selector(audioFetcher:finishedWithData:)
						 didFailSelector:@selector(audioFetcher:didFail:)];
}


- (void)audioFetcher:(GDataHTTPFetcher *)aFetcher finishedWithData:(NSData *)retrievedData
{
	[fetcher release], fetcher = nil;
    
    if([delegate respondsToSelector:@selector(dataReady:)])
    {
        [delegate dataReady:retrievedData];
    }    
}


- (void)audioFetcher:(GDataHTTPFetcher *)aFetcher didFail:(NSError *)error
{
    [fetcher release], fetcher = nil;
    
    NSLog(@"MicrosoftTTS fetcher did failed");
    
    if([delegate respondsToSelector:@selector(didFail)])
    {
        [delegate didFail];
    }							
}

@end
