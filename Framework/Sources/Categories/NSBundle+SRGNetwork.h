//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Convenience macro for localized strings associated with the framework.
 */
#define SRGNetworkLocalizedString(key, comment) [[NSBundle srg_networkBundle] localizedStringForKey:(key) value:@"" table:nil]

@interface NSBundle (SRGNetwork)

/**
 *  The framework resource bundle.
 */
+ (NSBundle *)srg_networkBundle;

@end

NS_ASSUME_NONNULL_END
