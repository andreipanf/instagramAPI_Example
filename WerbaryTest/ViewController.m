//
//  ViewController.m
//  WerbaryTest
//
//  Created by Andrey on 19.08.15.
//  Copyright (c) 2015 Andrey. All rights reserved.
//

#import "ViewController.h"
#import "Photo.h"
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "InstagramRequests.h"


@interface ViewController () <UIWebViewDelegate>
{
    UIWebView *acessWebView;
    NSArray *sortedPhoto;
    int indexPhoto;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    
    //получение access_token
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accesToken = [userDefaults objectForKey:@"ACCESS_TOKEN"];
    if (accesToken == nil) {
        [self getAcessToken];
    }
    
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

- (IBAction)leftButtonPressed:(id)sender {
    self.rightButton.enabled = YES;
    indexPhoto--;
    
    if (indexPhoto == 0) {
        self.leftButton.enabled = NO;
    }
    [self loadPhoto];
    
}

- (IBAction)rightButtonPressed:(id)sender
{
    self.leftButton.enabled = YES;
    
    indexPhoto++;
    
    if (indexPhoto == sortedPhoto.count-1) {
        self.rightButton.enabled = NO;
    }
    [self loadPhoto];
    
}

- (IBAction)loadButtonPressed:(id)sender
{
    [sender setUserInteractionEnabled:NO];
    [sender setHidden:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accesToken = [userDefaults objectForKey:@"ACCESS_TOKEN"];
    
    NSString *path = [NSString stringWithFormat:@"%@self/media/recent?access_token=%@",kAPIURl, accesToken];
    
    [SVProgressHUD showWithStatus:@"Load and Sort photo"];
    //Получаем все фото пользователя
    [[InstagramRequests network] fetchAllUserMediaRecentFromURL:[NSURL URLWithString:path] success:^(NSArray *allPhoto){
        
        [self sortedAndLoadPhotoWith:allPhoto];
        [SVProgressHUD dismiss];
        if (indexPhoto == 0) {
            self.leftButton.enabled = NO;
            self.rightButton.enabled = YES;
        }
        [sender setUserInteractionEnabled:YES];
        [sender setHidden:NO];
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
    sortedPhoto = [allPhoto sortedArrayUsingDescriptors:sortDescriptors];
    
    if (sortedPhoto.count > 0) {
        Photo *firstPhoto = [sortedPhoto firstObject];
        indexPhoto = (int)[sortedPhoto indexOfObject:firstPhoto];
        [self loadPhoto];
        
    }
    
}

-(void)loadPhoto
{
    Photo *photo = [sortedPhoto objectAtIndex:indexPhoto];
    self.commentLabel.text = [NSString stringWithFormat:@"Comment:%i",photo.countComment];
    self.likesLabel.text = [NSString stringWithFormat:@"Likes:%i",photo.likes];
    [self.photoView sd_setImageWithURL:[NSURL URLWithString:photo.urlPhoto]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
