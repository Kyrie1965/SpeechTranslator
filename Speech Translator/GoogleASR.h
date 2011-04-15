//
//  GoogleASR.h
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataHTTPFetcher.h"
#import "GTMNSString+HTML.h"
#import "JSON.h"

#define GoogleASRURL	@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang="

@protocol GoogleASRDelegate <NSObject>
@optional
- (void)didSR:(NSString *)text;
- (void)didFail;
@end


@interface GoogleASR : NSObject
{
	GDataHTTPFetcher *fetcher;
    
	id<GoogleASRDelegate> delegate;        
}


@property (assign) id delegate;


- (void)speechRecognition:(NSString *)flacPath language:(NSString *)language;

@end
