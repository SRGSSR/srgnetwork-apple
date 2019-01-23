//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

OBJC_EXPORT NSArray * _Nullable SRGNetworkJSONArrayParser(NSData * _Nullable data, NSError **pError);
OBJC_EXPORT NSDictionary * _Nullable SRGNetworkJSONDictionaryParser(NSData * _Nullable data, NSError **pError);

NS_ASSUME_NONNULL_END
