//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Use to avoid user-facing text analyzer warnings.
 *
 *  See https://clang-analyzer.llvm.org/faq.html.
 */
__attribute__((annotate("returns_localized_nsstring")))
OBJC_EXPORT NSString *SRGNetworkNonLocalizedString(NSString *string);

/**
 *  Convenience macro for localized strings associated with the framework.
 */
#define SRGNetworkLocalizedString(key, comment) [NSBundle.srg_networkBundle localizedStringForKey:(key) value:@"" table:nil]

@interface NSBundle (SRGNetwork)

/**
 *  The framework resource bundle.
 */
@property (class, nonatomic, readonly) NSBundle *srg_networkBundle;

@end

NS_ASSUME_NONNULL_END
