#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XYIAPKit.h"
#import "NSNotification+XYStore.h"
#import "XYReceiptRefreshService.h"
#import "XYStore.h"
#import "XYStoreProductService.h"
#import "XYStoreProtocol.h"

FOUNDATION_EXPORT double XYIAPKitVersionNumber;
FOUNDATION_EXPORT const unsigned char XYIAPKitVersionString[];

