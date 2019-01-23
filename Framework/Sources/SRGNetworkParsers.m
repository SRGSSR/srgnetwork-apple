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
    
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (! JSONObject || ! [JSONObject isKindOfClass:expectedClass]) {
        if (pError) {
            *pError = [NSError errorWithDomain:SRGNetworkErrorDomain
                                          code:SRGNetworkErrorInvalidData
                                      userInfo:@{ NSLocalizedDescriptionKey : SRGNetworkLocalizedString(@"The data is invalid.", @"Error message returned when a server response data is incorrect.") }];
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
