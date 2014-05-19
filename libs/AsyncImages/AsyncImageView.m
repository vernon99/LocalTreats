//
//  AsyncImageView.m
//  YellowJacket
//
//  Created by Wayne Cochran on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <malloc/malloc.h>

#define SPINNY_TAG 5555


@implementation AsyncImageView

@synthesize isRounded,shadowed;
@synthesize imageView,urlString;




- (void)setup {
    self.cachPolicy = CFAsyncCachePolicyDiskAndMemory;
    self.loadPolicy = CFAsyncReturnCacheDataAndUpdateCachedImageOnce;
    self.backgroundColor = [UIColor clearColor];
    cornerRadius = 4.0;
    shadowed = NO;
     
    spinny.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    [spinny startAnimating];
    [self addSubview:spinny];
    


    if (!imageView){
        imageView = [[UIImageView alloc] init];

        CGFloat r = 0.0f;
//        if([[STStyle sharedInstance] isIpad]){
//            r = 2.0f;
//        }
        if (self.frame.size.width > 60) {
            imageView.frame = CGRectMake(4*r, 4*r, self.frame.size.width-8*r, self.frame.size.height-8*r);
        }else
            imageView.frame = CGRectMake(2*r, 2*r, self.frame.size.width-4*r, self.frame.size.height-4*r);
        
        imageView.contentMode      = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:imageView atIndex:0];
        if (isRounded) {
            imageView.clipsToBounds = YES;
            imageView.layer.cornerRadius = 4.0;
            imageView.layer.masksToBounds = YES;
        }
    }
    
    /*if (self.frame.size.width > 40 && !logo) {
        logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_etched.png"]];
        logo.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
        [imageView addSubview:logo];
        logo.center = CGPointMake(imageView.frame.size.width/2, imageView.frame.size.height/2);
        logo.frame = CGRectIntegral(logo.frame);
    }*/
    

}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

-(void)cutCorners{
    isRounded = YES;
}






- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        self.cachPolicy = CFAsyncCachePolicyDiskAndMemory;
        self.loadPolicy = CFAsyncReturnCacheDataAndUpdateCachedImageOnce;
        [self setup];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cachPolicy = CFAsyncCachePolicyDiskAndMemory;
        self.loadPolicy = CFAsyncReturnCacheDataAndUpdateCachedImageOnce;
//        [self setup];
    }
    return self;
}

-(void)cleanSubviews{
    spinny.alpha = 0;
    [shadowImage removeFromSuperview];
}

- (void)addImageToImageView:(UIImage *)image animated:(BOOL)animated{
    [loader cancel];
    
    [self cleanSubviews];
    if (!imageView && !spinny) {
        BOOL oldaValue = self.shadowed;
        [self setup];
        logo.hidden = NO;
        [spinny stopAnimating];
        self.shadowed = oldaValue;
    }
    imageView.image = image;
    
    if (animated) {
        imageView.alpha = 0; 
        spinny.alpha = 1;
        [UIView beginAnimations:@"" context:nil];
        [UIView setAnimationDuration:0.1];
        spinny.alpha = 0;
        imageView.alpha = 1;
        [UIView commitAnimations];
    }

    if (image) 
        logo.hidden = YES;
    
	// is this necessary if superview gets setNeedsLayout?
//	[imageView setNeedsLayout];
	[self setNeedsLayout];
}








-(void)loadImage:(UIImage*)image {
	if (!image) {
        [loader cancel];
        imageView.image = nil;
        logo.hidden = NO;
        [self setNeedsDisplay];
        return;
    }
    [self cleanSubviews];
    [self addImageToImageView:image animated:NO];
}


-(void)loadImageFromName:(NSString *)imageName {	
	
    if (!imageName) {
        logo.hidden = NO;
        return;
    }
	[self cleanSubviews];
		
    UIImage *image = [UIImage imageNamed:imageName];
    [self addImageToImageView:image animated:NO];
	
}

-(void)loadImageFromURL:(NSString*)url {
    [self loadImageFromURL:url withTarger:nil selector:nil];
}

-(void)loadImageFromURL:(NSString*)url withTarger:(id)target_ selector:(SEL)selector_ {
	_target = target_;
    selector = selector_;
    
    if (currentHash == url.hash && imageView.image) {
        return;
    }
    currentHash = url.hash;
    if (!loader) {
        loader = [[ImageLoader alloc]init];
        loader.cachPolicy = self.cachPolicy;
        loader.loadPolicy = self.loadPolicy;
    }

    UIImage *im = [loader getImage:url rounded:FALSE];
    if (im) {
        [self addImageToImageView:im animated:NO];
        [_target performSelector:selector withObject:im];
        return;
    }
    [self cleanSubviews];
    imageView.image = nil;
    logo.hidden = NO;
    
    [loader loadImageWithUrl:url handler:^(UIImage *image) {
        [self addImageToImageView:image animated:YES];
        [_target performSelector:selector withObject:image];
    }];
}







@end
