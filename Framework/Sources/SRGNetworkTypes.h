//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPage.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Rquest options.
 */
typedef NS_OPTIONS(NSUInteger, SRGRequestOptions) {
    /**
     *  By default, cancelled requests will not call the associated completion block. If this flag is set, though,
     *  cancelled requests will call the completion block with an associated error.
     */
    SRGRequestOptionCancellationErrorsEnabled = (1UL << 0),
    /**
     *  By default, and unlike `NSURLSession` tasks, requests return an `NSError` when an HTTP error status code has
     *  been received. If this flag is set, though, this mechanism is disabled, and the behavior is similar to the
     *  one of `NSURLSession` tasks (the status code can be retrieved from the response).
     */
    SRGRequestOptionHTTPErrorsDisabled = (1UL << 1),
    /**
     *  Some errors might be related to a public WiFi being used, which is why friendly error messages are returned
     *  by default when this might be the case. The error domain and code are left unaltered. This behavior can be
     *  disabled, in which case the original (non-friendly) error message is kept.
     */
    SRGNetworkOptionFriendlyWiFiMessagesDisabled = (1UL << 2),
    /**
     *  By default, request completion blocks are called on the main thread. The reason is that parsing and other
     *  time-consuming operations will always occur on background threads, the completion block will thus in most
     *  cases be dedicated to UI updates. If you want to have the completion block called on a background thread,
     *  simply enable the following option.
     */
    SRGNetworkRequestBackgroundThreadCompletionEnabled = (1UL << 2),
};

/**
 *  Request queue options.
 */
typedef NS_OPTIONS(NSUInteger, SRGRequestQueueOptions) {
    /**
     *  By default, requests associated with a queue will continue, even if one of them fails. When this flag is
     *  enabled, though, the queue will automatically cancel all its remaining requests when a non-`nil` error is
     *  reported to it.
     */
    SRGRequestQueueOptionAutomaticCancellationOnErrorEnabled = (1UL << 0)
};

// Parser signature.
typedef id _Nullable (^SRGResponseParser)(NSData *data, NSError * __autoreleasing *pError);

// Sizer signature.
typedef NSURLRequest * (^SRGPageSizer)(NSURLRequest *URLRequest, NSUInteger size);

// Paginator signatures.
typedef NSURLRequest * _Nullable (^SRGDataPaginator)(NSURLRequest *URLRequest, NSData * _Nullable data, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number);
typedef NSURLRequest * _Nullable (^SRGJSONArrayPaginator)(NSURLRequest *URLRequest, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number);
typedef NSURLRequest * _Nullable (^SRGJSONDictionaryPaginator)(NSURLRequest *URLRequest, NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number);
typedef NSURLRequest * _Nullable (^SRGObjectPaginator)(NSURLRequest *URLRequest, id _Nullable object, NSURLResponse * _Nullable response, NSUInteger size, NSUInteger number);

// Completion block signatures.
typedef void (^SRGDataCompletionBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONArrayCompletionBlock)(NSArray * _Nullable JSONArray, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONDictionaryCompletionBlock)(NSDictionary * _Nullable JSONDictionary, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGObjectCompletionBlock)(id _Nullable object, NSURLResponse * _Nullable response, NSError * _Nullable error);

// Paginated completion block signatures.
typedef void (^SRGDataPageCompletionBlock)(NSData * _Nullable data, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONArrayPageCompletionBlock)(NSArray * _Nullable JSONArray, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGJSONDictionaryPageCompletionBlock)(NSDictionary * _Nullable JSONDictionary, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);
typedef void (^SRGObjectPageCompletionBlock)(id _Nullable object, SRGPage *page, SRGPage * _Nullable nextPage, NSURLResponse * _Nullable response, NSError * _Nullable error);

NS_ASSUME_NONNULL_END
