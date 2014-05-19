//
//  ImageLoader.m
//  Ymo3
//
//  Created by Constantine Fry on 11/15/12.
//  Copyright (c) 2012 South Ventures USA, LLC. All rights reserved.
//

#import "ImageLoader.h"
#import "GMCAppDelegate.h"
#import "JMImageCache.h"

static inline NSMutableDictionary *updatedImages() {
	static NSMutableDictionary *_loadedImages;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_loadedImages = [NSMutableDictionary dictionaryWithCapacity:10];
	});
	return _loadedImages;
}

@implementation ImageLoader{
    NSURLConnection *connection;
    NSMutableData *data;
    NSString *__weak _urlString;
    ImageHandler _handler;
    BOOL needToPassImageToBlock;
}

/*- (id)initForCircleImages
{
    self = [super init];
    if (self) {
        roundedImages = YES;
        self.cachPolicy = CFAsyncCachePolicyDiskAndMemory;
        self.loadPolicy = CFAsyncReturnCacheDataAndUpdateCachedImageOnce;
        FugeAppDelegate *dlgt = (FugeAppDelegate*)[[UIApplication sharedApplication]delegate];
        _imageCache = dlgt.circledImageCache;
        self.maxImageSize = 400000;
        self.maxSize = CGSizeMake(200, 200);
    }
    return self;
}*/

- (id)init
{
    self = [super init];
    if (self) {
        self.cachPolicy = CFAsyncCachePolicyDiskAndMemory;
        self.loadPolicy = CFAsyncReturnCacheDataElseLoad;
        GMCAppDelegate *dlgt = (GMCAppDelegate*)[[UIApplication sharedApplication]delegate];
        _imageCache = dlgt.imageCache;
        self.maxImageSize = 400000;
        self.maxSize = CGSizeMake(200, 200);
    }
    return self;
}

-(UIImage*)getImage:(NSString*)url rounded:(Boolean)rounded{
    UIImage *image = [_imageCache objectForKey:url];
    if (!image) {
        image = [_imageCache imageFromDiskForKey:url];
        if (image) {
            
            [self setImage:image url:url];
            
            if (self.loadPolicy == CFAsyncReturnCacheDataAndUpdateCachedImageOnce) {
                NSMutableDictionary *d = updatedImages();
                if (!d[url]){
                    d[url] = @"";
                    needToPassImageToBlock = NO;
                    [self makeRequestWithURL:_urlString];
                }
            }
            
        }
    }
    
    // Rounded
    UIImage *roundedImg = nil;
    if ( rounded )
    {
        //roundedImg = [UIImage appleMask:[UIImage imageNamed:@"mask35.png"] forImage:image];
        return roundedImg;
    }
    
    return image;
}

-(void)setImage:(UIImage*)image url:(NSString*)url {
    [_imageCache setObject:image
                    forKey:url
                      cost:image.size.width*image.size.height*image.scale];
}

-(void)loadImageWithUrl:(NSString*)url
                handler:(ImageHandler)handler{
    
    [connection cancel];
    data = nil;
    
    if (!url ) {
        handler(nil);
    }
    
    _urlString = url;
    UIImage *cachedImage = [_imageCache objectForKey:_urlString];
    
    if ( cachedImage != nil ) {
        handler(cachedImage);
        return;
    }
    
    _handler = handler;
    needToPassImageToBlock = YES;
    [self makeRequestWithURL:_urlString];
}

-(void)sendImageToBlockOnMainQueue:(UIImage*)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_handler)
            _handler(image);
        _handler = nil;
    });
}

-(void)makeRequestWithURL:(NSString*)url{
    
    data = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:10];
    
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                 delegate:self
                                         startImmediately:NO];
    
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSRunLoopCommonModes];
    
    
    [connection start];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    if ( data == nil ) {
        data = [[NSMutableData alloc] initWithCapacity:2048];
    }
    [data appendData:incrementalData];
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    NSData *d = data;
    NSString *originUrl = aConnection.originalRequest.URL.absoluteString;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self processData:d withUrl:originUrl];
    });
    connection = nil;
    //data = nil;
}

-(void)saveInCache:(UIImage*)image withUrl:(NSString*)url{
    [_imageCache setObject:image
                    forKey:url
                      cost:image.scale*image.size.width*image.size.height];
    if (self.cachPolicy == CFAsyncCachePolicyDiskAndMemory) {
        [_imageCache saveToDisk:image withKey:url];
    }
}


-(void)processData:(NSData*)d withUrl:(NSString*)url{
    
    UIImage *cachedImage = [_imageCache objectForKey:url];
    if (cachedImage && self.loadPolicy == CFAsyncReturnCacheDataElseLoad) {
        [self sendImageToBlockOnMainQueue:cachedImage];
        return;
    }
    
    // Image
    UIImage *image = [UIImage imageWithData:d];
    /*UIImage *rounded = nil;
    if ( roundedImages )
        rounded = [UIImage appleMask:[UIImage imageNamed:@"mask35.png"]
                  forImage:image];
    if ( rounded )
        image = rounded;*/
    
    // Saving
    if ( image )
        [self saveInCache:image withUrl:url];
    
    // Sending back
    if (needToPassImageToBlock && _urlString.hash == url.hash)
        [self sendImageToBlockOnMainQueue:image];
}



-(void)cancel{
    [connection cancel];
    connection = nil;
    data = nil;
}

@end
