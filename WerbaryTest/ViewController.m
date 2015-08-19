//
//  ViewController.m
//  WerbaryTest
//
//  Created by Andrey on 19.08.15.
//  Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"


@interface ViewController ()
{
    UIWebView *acessWebView;
}

@end

@implementation ViewController
@synthesize photoView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
   //
}

-(void)viewWillAppear:(BOOL)animated
{
    //получение access_token
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accesToken = [userDefaults objectForKey:@"ACCESS_TOKEN"];
    if (accesToken == nil) {
        [self getAcessToken];
    }
    NSString *path = [NSString stringWithFormat:@"https://api.instagram.com//v1/users/self/media/recent?access_token=%@",accesToken];
    
    //Получаем все фото пользователя
    [self fetchAllUserMediaRecentFromURL:[NSURL URLWithString:path] success:^(NSArray *allPhoto){
        
        [self sortedAndLoadPhotoWith:allPhoto];
        
    }];
}

-(void)sortedAndLoadPhotoWith:(NSArray*)allPhoto
{
    //Сортируем их по коментам и лайкам
    NSSortDescriptor *comentSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"countComment"
                                                                         ascending:NO];
    NSSortDescriptor *likesSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"likes"
                                                                        ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:comentSortDescriptor,likesSortDescriptor,nil];
    NSArray *sortedPhoto = [allPhoto sortedArrayUsingDescriptors:sortDescriptors];
    
    Photo *firstPhoto = [sortedPhoto firstObject];
    self.commentLabel.text = [NSString stringWithFormat:@"Comment:%i",firstPhoto.countComment];
    self.likesLabel.text = [NSString stringWithFormat:@"Likes:%i",firstPhoto.likes];
    //[self.photoView removeFromSuperview];
    
    //photoView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:firstPhoto.urlPhoto]]];
    photoView.image = [UIImage imageWithData:firstPhoto.image];
    //[self.view addSubview:self.photoView];
    
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
                    //photo.urlPhoto = urlImage;
                    photo.image = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlImage]];
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


-(void)getAcessToken
{
    acessWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSString *fullURL = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token",KAUTHURL, KCLIENTID,kREDIRECTURI];
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [acessWebView loadRequest:requestObj];
    acessWebView.delegate = self;
    [self.view addSubview:acessWebView];
}


-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* urlString = [[request URL] absoluteString];
    NSArray *UrlParts = [urlString componentsSeparatedByString:[NSString stringWithFormat:@"%@/", kREDIRECTURI]];
    if ([UrlParts count] > 1) {
        
        urlString = [UrlParts objectAtIndex:1];
        NSRange accessToken = [urlString rangeOfString: @"#access_token="];
        if (accessToken.location != NSNotFound) {
            NSString* strAccessToken = [urlString substringFromIndex: NSMaxRange(accessToken)];
            
            [[NSUserDefaults standardUserDefaults] setValue:strAccessToken forKey:@"ACCESS_TOKEN"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //NSLog(@"AccessToken = %@ ", strAccessToken);
            [acessWebView removeFromSuperview];
            //[self loadRequestForMediaData];
            //[self getJSON];
        }
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftButtonPressed:(id)sender {
}

- (IBAction)rightButtonPressed:(id)sender {
}
@end
