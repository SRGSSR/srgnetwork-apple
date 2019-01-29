//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGNetworkParsers.h"

#import "NSBundle+SRGNetwork.h"
#import "SRGNetworkError.h"

static id SRGNetworkJSONParser(NSData *data, Class expectedClass, NSError **pError)
{
    if (! data) {
        return nil;
    }
    
    NSError *parsingError = nil;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
    if (parsingError) {
        if (pError) {
            *pError = parsingError;
        }
        return nil;
    }
    
    if (! [JSONObject isKindOfClass:expectedClass]) {
        if (pError) {
            NSString *description = [NSString stringWithFormat:SRGNetworkNonLocalizedString(@"Incorrect JSON type. Expected %@ but found %@"), NSStringFromClass(expectedClass), NSStringFromClass([JSONObject class])];
            *pError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                          code:SRGNetworkErrorInvalidData
                                      userInfo:@{ NSLocalizedDescriptionKey : description }];
        }
        return nil;
    }
    
    return JSONObject;
}

NSArray *SRGNetworkJSONArrayParser(NSData *data, NSError **pError)
{
    return SRGNetworkJSONParser(data, NSArray.class, pError);
}

NSDictionary *SRGNetworkJSONDictionaryParser(NSData *data, NSError **pError)
{
    return SRGNetworkJSONParser(data, NSDictionary.class, pError);
}
