//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Dispatch the specified block synchronously onto the main queue, if needed.
 */
OBJC_EXPORT void dispatch_sync_on_main_queue_if_needed(DISPATCH_NOESCAPE dispatch_block_t block);

NS_ASSUME_NONNULL_END
