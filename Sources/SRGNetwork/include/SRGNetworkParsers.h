//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Attempt to parse JSON data as an `NSArray`. If the data cannot be successfully parsed, the function returns `nil`
 *  and an error by reference.
 */
OBJC_EXPORT NSArray * _Nullable SRGNetworkJSONArrayParser(NSData *data, NSError * __autoreleasing *pError);

/**
 *  Attempt to parse JSON data as an `NSDictionary`. If the data cannot be successfully parsed, the function returns
 *  `nil` and an error by reference.
 */
OBJC_EXPORT NSDictionary * _Nullable SRGNetworkJSONDictionaryParser(NSData *data, NSError * __autoreleasing *pError);

NS_ASSUME_NONNULL_END
