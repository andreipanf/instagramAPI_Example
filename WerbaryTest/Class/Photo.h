//
//  Photo.h
//  WerbaryTest
//
//  Created by Andrey on 19.08.15.
//  Copyright (c) 2015 Andrey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (nonatomic,strong) NSString *urlPhoto;
@property (nonatomic,strong) NSData *image;

@property (nonatomic) int countComment;
@property (nonatomic) int likes;


@end
