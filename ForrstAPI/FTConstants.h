//
//  FTConstants.h
//  ForrstAPI
//
//  Created by Kyle Hickinson on 11-06-04.
//  Copyright 2011 Kyle Hickinson. All rights reserved.
//

#if !__has_feature(objc_arc)
    #define FT_RELEASE(__PTR)   { [__PTR release]; __PTR = nil; }
    #define strong              nonatomic, retain
#else
    #define FT_RELEASE(__PTR)   { __PTR = nil; }
#endif

#define FT_API_BASEURL      @"http://forrst.com/api/v2/"

#define FT_API_LOG          0

#define FT_API_USERAGENT    @"__YourUserAgent__"
