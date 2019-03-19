//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "NSHTTPURLResponse+SRGNetwork.h"

#import <XCTest/XCTest.h>

@interface NSHTTPURLResponse_NetworkTestCase : XCTestCase

@end

@implementation NSHTTPURLResponse_NetworkTestCase

#pragma mark Tests

- (void)testLocalizedStringForNetworkErrorCode
{
    NSArray *errorCodes = @[ @(NSURLErrorUnknown),
                             @(NSURLErrorCancelled), @(NSURLErrorBadURL), @(NSURLErrorTimedOut), @(NSURLErrorUnsupportedURL),
                             @(NSURLErrorCannotFindHost), @(NSURLErrorCannotConnectToHost), @(NSURLErrorNetworkConnectionLost),
                             @(NSURLErrorDNSLookupFailed), @(NSURLErrorHTTPTooManyRedirects), @(NSURLErrorResourceUnavailable),
                             @(NSURLErrorNotConnectedToInternet), @(NSURLErrorRedirectToNonExistentLocation), @(NSURLErrorBadServerResponse),
                             @(NSURLErrorUserCancelledAuthentication), @(NSURLErrorUserAuthenticationRequired), @(NSURLErrorZeroByteResource),
                             @(NSURLErrorCannotDecodeRawData), @(NSURLErrorCannotDecodeContentData), @(NSURLErrorCannotParseResponse),
                             @(NSURLErrorAppTransportSecurityRequiresSecureConnection), @(NSURLErrorFileDoesNotExist),
                             @(NSURLErrorFileIsDirectory), @(NSURLErrorNoPermissionsToReadFile), @(NSURLErrorDataLengthExceedsMaximum),
                             @(NSURLErrorSecureConnectionFailed), @(NSURLErrorServerCertificateHasBadDate),
                             @(NSURLErrorServerCertificateUntrusted), @(NSURLErrorServerCertificateHasUnknownRoot),
                             @(NSURLErrorServerCertificateNotYetValid), @(NSURLErrorClientCertificateRejected),
                             @(NSURLErrorClientCertificateRequired), @(NSURLErrorCannotLoadFromNetwork),
                             @(-9789) ];
    
    for (NSNumber *errorCode in errorCodes) {
        NSString *message = [NSHTTPURLResponse srg_localizedStringForURLErrorCode:errorCode.integerValue];
        NSLog(@"%@: %@", errorCode, message);
        XCTAssertNotNil(message);
    }
}

- (void)testLocalizedStringForStatusCode
{
    NSArray *statusCodes = @[ @100, @101, @102,
                              @200, @201, @202, @203, @204, @205, @206, @207, @208, @226,
                              @300, @301, @302, @303, @304, @305, @306, @307, @308,
                              @400, @401, @402, @403, @404, @405, @406, @407, @408, @409, @410, @411, @412, @413, @414, @415, @416, @417, @418, @421, @422, @423, @424, @426, @428, @429, @431, @451,
                              @500, @501, @502, @503, @504, @505, @506, @507, @508, @510, @511,
                              @103, @420, @450, @498, @499, @509, @530, @598, @599,
                              @440, @449, @451,
                              @444, @495, @496, @497, @499,
                              @520, @521, @522, @523, @524, @525, @526, @527 ];
    
    for (NSNumber *statusCode in statusCodes) {
        NSString *message = [NSHTTPURLResponse srg_localizedStringForStatusCode:statusCode.integerValue];
        NSLog(@"%@: %@", statusCode, message);
        XCTAssertNotNil(message);
    }
}

@end
