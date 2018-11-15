//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <SRGLogger/SRGLogger.h>

/**
 *  Helper macros for logging.
 */
#define SRGNetworkLogVerbose(category, format, ...) SRGLogVerbose(@"ch.srgssr.network", category, format, ##__VA_ARGS__)
#define SRGNetworkLogDebug(category, format, ...)   SRGLogDebug(@"ch.srgssr.network", category, format, ##__VA_ARGS__)
#define SRGNetworkLogInfo(category, format, ...)    SRGLogInfo(@"ch.srgssr.network", category, format, ##__VA_ARGS__)
#define SRGNetworkLogWarning(category, format, ...) SRGLogWarning(@"ch.srgssr.network", category, format, ##__VA_ARGS__)
#define SRGNetworkLogError(category, format, ...)   SRGLogError(@"ch.srgssr.network", category, format, ##__VA_ARGS__)
