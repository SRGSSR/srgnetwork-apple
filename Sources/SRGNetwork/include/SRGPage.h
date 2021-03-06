//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

// Unspecified page size. The page size is defined by the service.
static const NSUInteger SRGPageUnspecifiedSize = 0;

/**
 *  Describe a page of content. You never instantiate page objects directly, they are merely returned from requests
 *  supporting pagination when a next page is available.
 */
@interface SRGPage : NSObject <NSCopying>

/**
 *  The page size.
 *
 *  @discussion The page size is the requested page size, not the actual number of records available for the page
 *              (this information can be extracted by counting the number of objects returned by a request).
 */
@property (nonatomic, readonly) NSUInteger size;

/**
 *  The page number, starting at 0 for the first page.
 */
@property (nonatomic, readonly) NSUInteger number;

@end

NS_ASSUME_NONNULL_END
