//
//  InstagramRequests.m
//  WerbaryTest
//
//  Created by Andrey on 02.01.16.
//  Copyright © 2016 Andrey. All rights reserved.
//

#import "InstagramRequests.h"
#import "Photo.h"

@implementation InstagramRequests

+(InstagramRequests *) network {
    static InstagramRequests *network = nil;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    return network;
    
}

- (void)fetchAllUserMediaRecentFromURL:(NSURL *)url success:(void(^)(NSArray *posts))success {
    
    __block NSArray *allPosts = [NSMutableArray array];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        if (!error) {
            
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([result isKindOfClass:[NSDictionary class]] && !error) {
                
                NSMutableArray *tempArray = [NSMutableArray array];
                for (NSDictionary *jsonData in [result objectForKey:@"data"]) {
                    //фото
                    NSDictionary *images = [jsonData objectForKey:@"images"];
                    NSDictionary *standartResolution = [images objectForKey:@"standard_resolution"];
                    NSString *urlImage = [standartResolution objectForKey:@"url"];
                    
                    //Коменты
                    NSDictionary *comments = [jsonData objectForKey:@"comments"];
                    int comentsCount = [[comments objectForKey:@"count"]intValue];
                    
                    //лайки
                    NSDictionary *likes = [jsonData objectForKey:@"likes"];
                    int likeCount = [[likes objectForKey:@"count"]intValue];
                    
                    Photo *photo = [[Photo alloc]init];
                    photo.urlPhoto = urlImage;
                    //photo.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlImage]];
                    photo.countComment = comentsCount;
                    photo.likes = likeCount;
                    
                    [tempArray addObject:photo];
                }
                allPosts = [NSArray arrayWithArray:tempArray];
            }
            
            NSURL *paginationURL = [self getPaginationUrlFromJSON:result];
            
            if (paginationURL) {
                
                [self fetchAllUserMediaRecentFromURL:paginationURL success:^(NSArray *posts) {
                    allPosts = [allPosts arrayByAddingObjectsFromArray:posts];
                    success(allPosts);
                }];
                
            } else {
                
                success(allPosts);
            }
            
        } else {
            
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    
    [dataTask resume];
}

-(NSURL*)getPaginationUrlFromJSON:(NSDictionary*)result
{
    NSDictionary *pagination = [result objectForKey:@"pagination"];
    
    NSURL *paginationUrl = [NSURL URLWithString:[pagination objectForKey:@"next_url"]];
    return paginationUrl;
}

@end
