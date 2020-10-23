//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSHTTPURLResponse+SRGNetwork.h"

#import "NSBundle+SRGNetwork.h"

static NSString *SRGNetworkCapitalizeFirstLetterOfString(NSString *string)
{
    if (! string) {
        return nil;
    }
    
    NSString *capitalizedFirstLetter = [[string substringToIndex:1] uppercaseStringWithLocale:[NSLocale currentLocale]];
    return [string stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:capitalizedFirstLetter];
}

@implementation NSHTTPURLResponse (SRGNetwork)

+ (NSString *)srg_localizedStringForURLErrorCode:(NSInteger)errorCode
{
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *key = [NSString stringWithFormat:@"Err%@", @(errorCode)];
    
    static NSString * const kMissingValue = @"srgnetwork_missing";
    NSString *localizedString = [bundle localizedStringForKey:key value:kMissingValue table:nil];
    if (! [localizedString isEqualToString:kMissingValue]) {
        return SRGNetworkCapitalizeFirstLetterOfString(localizedString);
    }
    else {
        return SRGNetworkLocalizedString(@"Unknown error", @"Generic error description when the actual error is not identified");
    }
}

// TODO: Remove this workaround when the bug has been fixed on all supported iOS versions
+ (NSString *)srg_localizedStringForStatusCode:(NSInteger)statusCode
{
    // The +localizedStringForStatusCode: method always returns the English version, which we use as localization key
    NSString *localizationKey = [self localizedStringForStatusCode:statusCode];
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.apple.CFNetwork"];
    NSString *localizedString = [bundle localizedStringForKey:localizationKey value:localizationKey table:nil];
    return SRGNetworkCapitalizeFirstLetterOfString(localizedString);
}

@end
