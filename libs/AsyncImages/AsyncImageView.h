//
//  AsyncImageView.h
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//





//extern size_t malloc_size(const void *ptr);
//
// Key's are URL strings.
// Value's are ImageCacheObject's
//
//static ImageCache *imageCache = nil;
#import "ImageLoader.h"
@class ImageLoader;
@interface AsyncImageView : UIView {
    ImageLoader *loader;
	int cornerRadius;
	BOOL isRounded;
	UIImageView *imageView;
    UIImageView *shadowImage;
    UIActivityIndicatorView *spinny;
    SEL selector;
    UIImageView *logo;
    NSUInteger currentHash;
}

@property (nonatomic) CFAsyncCachePolicy cachPolicy;
@property (nonatomic) CFAsyncLoadPolicy loadPolicy;

@property (nonatomic,weak)id target;
@property (weak, nonatomic,readonly)NSString* urlString;
@property (nonatomic,assign)BOOL shadowed;
@property(nonatomic,strong) UIImageView* imageView;
@property (nonatomic) BOOL isRounded;


-(void)cutCorners;
-(void)loadImageFromURL:(NSString*)url withTarger:(id)target_ selector:(SEL)selector_ ;



-(void)loadImage:(UIImage*)image;
-(void)loadImageFromName:(NSString*)image;
-(void)loadImageFromURL:(NSString*)url;

- (void)addImageToImageView:(UIImage *)image animated:(BOOL)animated;



@end
