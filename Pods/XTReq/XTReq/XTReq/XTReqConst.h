//
//  XTReqConst.h
//  XTReq
//
//  Created by teason23 on 2018/10/17.
//  Copyright Β© 2018εΉ΄ teaason. All rights reserved.
//

#import "XTReqSessionManager.h"

#ifndef XTReqConst_h
#define XTReqConst_h

#define XTREQLog1(format, ...)                \
    do {                                      \
        fprintf(stderr, "ππππxtreqππππ\n");   \
        (NSLog)((format), ##__VA_ARGS__);     \
        fprintf(stderr, "ππππxtreqππππ\n\n"); \
    } while (0)


#define XTREQLog(format, ...)               \
    if (XTReq_isDebug) {                    \
        XTREQLog1((format), ##__VA_ARGS__); \
    };


#endif /* XTReqConst_h */
