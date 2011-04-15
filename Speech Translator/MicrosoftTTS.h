//
//  MicrosoftTTS.h
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataHTTPFetcher.h"
#import "GTMNSString+HTML.h"


#define SpeechURL @"http://api.microsofttranslator.com/v2/Http.svc/Speak?appId=B514C7B9E882AD6E237621DC437BCBED1902EC4B"


@protocol MicrosoftTTSDelegate <NSObject>
@optional
- (void)dataReady:(NSData *)audioData;
- (void)didFail;
@end


@interface MicrosoftTTS : NSObject
{
	GDataHTTPFetcher *fetcher;
    
	id<MicrosoftTTSDelegate> delegate;     
}


@property (assign) id delegate;


- (void)textToSpeech:(NSString *)text language:(NSString *)language;


@end
