//
//  GoogleTranslate.h
//  Speech Translator
//
//  Created by Yuri Yuriev on 15.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataHTTPFetcher.h"
#import "GTMNSString+HTML.h"
#import "JSON.h"

#define GoogleURL	@"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0"

@protocol GoogleTranslateDelegate <NSObject>
@optional
- (void)didTranslate:(NSString *)translatedText;
- (void)didFail;
@end


@interface GoogleTranslate : NSObject
{
	GDataHTTPFetcher *fetcher;

	id<GoogleTranslateDelegate> delegate;        
}


@property (assign) id delegate;


- (void)translate:(NSString *)text from:(NSString *)inLanguage to:(NSString *)outLanguage;

@end
