//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Parsing functions.
 */
OBJC_EXPORT NSArray * _Nullable SRGNetworkJSONArrayParser(NSData *data, NSError * __autoreleasing *pError);
OBJC_EXPORT NSDictionary * _Nullable SRGNetworkJSONDictionaryParser(NSData *data, NSError * __autoreleasing *pError);

NS_ASSUME_NONNULL_END
