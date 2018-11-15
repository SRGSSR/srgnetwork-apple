//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SRGPageRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Request for the first page of a list of results.
 */
@interface SRGFirstPageRequest : SRGPageRequest

/**
 *  Return an equivalent request, but with the specified page size.
 *
 *  @param pageSize The page size to use (values < 1 will be fixed to 1). The maximum page size, usually 100, varies
 *                  depending on the request (see `Documentation/Service-availability.md` for more information).
 */
- (SRGFirstPageRequest *)requestWithPageSize:(NSInteger)pageSize;

/**
 *  Return an equivalent request, but for the specified page. You never instantiate pages yourself, you receive them
 *  in the completion block of a service request supporting pagination.
 *
 *  @param page The page to request. If `nil`, the first page is requested (for the same page size as the receiver).
 *
 *  @discussion The `-requestWithPage:` method must be called on a related request, otherwise the behavior is undefined.
 */
- (SRGPageRequest *)requestWithPage:(nullable SRGPage *)page;

@end

NS_ASSUME_NONNULL_END
