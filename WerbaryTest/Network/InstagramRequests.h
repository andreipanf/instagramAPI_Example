//
//  InstagramRequests.h
//  WerbaryTest
//
//  Created by Andrey on 02.01.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramRequests : NSObject

+(InstagramRequests*) network;

- (void)fetchAllUserMediaRecentFromURL:(NSURL *)url success:(void(^)(NSArray *posts))success;

@end
