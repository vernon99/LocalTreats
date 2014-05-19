//
//  JMImageCache.h
//  JMCache
//
//  Created by Jake Marsh on 2/7/11.
//  Copyright 2011 Jake Marsh. All rights reserved.
//


@class JMImageCache;

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week
static const NSInteger kDefaultMaxCaccheSize = 100000000; // 100 MB

@interface JMImageCache : NSCache

+ (JMImageCache *) sharedCache;

@property(nonatomic,strong)NSString*prefix;
@property (assign, nonatomic) unsigned long long maxCacheSize;
@property (assign, nonatomic) NSInteger maxCacheAge;

-(void)applicationDidReceiveMemoryWarning;

- (UIImage *) imageFromDiskForKey:(NSString *)key;

- (void) imageFromDiskForKey:(NSString *)key block:(void (^)(UIImage *image))completion;

-(void)saveToDisk:(UIImage*)data withKey:(NSString*)key;

- (UIImage *)decodedImageWithImage:(UIImage* )image;

-(void)cleanCache;
@end
