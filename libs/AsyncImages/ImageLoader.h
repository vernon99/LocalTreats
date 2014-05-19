//
//  ImageLoader.h
//  Ymo3
//
//  Created by Constantine Fry on 11/15/12.
//  Copyright (c) 2012 South Ventures USA, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum kCFAsyncCachePolicy{
    CFAsyncCachePolicyDiskAndMemory = 1,
    CFAsyncCachePolicyMemory
}CFAsyncCachePolicy;


typedef enum kCFAsyncLoadPolicy{
    CFAsyncReturnCacheDataElseLoad,
    CFAsyncReturnCacheDataAndUpdateCachedImageOnce
}CFAsyncLoadPolicy;

@class JMImageCache;
typedef void (^ImageHandler)(UIImage *image);

@interface ImageLoader : NSObject
@property (nonatomic) CFAsyncCachePolicy cachPolicy;
@property (nonatomic) CFAsyncLoadPolicy loadPolicy;

@property (nonatomic,strong) UIImage *imageMask;
@property (nonatomic,strong) JMImageCache *imageCache;
@property (nonatomic) NSUInteger maxImageSize;
@property (nonatomic) CGSize maxSize;

- (id)init;

-(UIImage*)getImage:(NSString*)url rounded:(Boolean)rounded;
-(void)setImage:(UIImage*)image url:(NSString*)url;
-(void)loadImageWithUrl:(NSString*)url
                handler:(ImageHandler)handler;
-(void)cancel;

@end
