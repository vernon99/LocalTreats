//
//  JMImageCache.m
//  JMCache
//
//  Created by Jake Marsh on 2/7/11.
//  Copyright 2011 Jake Marsh. All rights reserved.
//

#import "JMImageCache.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>



#if OS_OBJECT_USE_OBJC
#define SDDispatchQueueRelease(q)
#define SDDispatchQueueSetterSementics strong
#else
#define SDDispatchQueueRelease(q) (dispatch_release(q))
#define SDDispatchQueueSetterSementics assign
#endif

@interface JMImageCache()
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;
@end

static inline NSString *JMImageCacheDirectory() {
	static NSString *_JMImageCacheDirectory;
	static dispatch_once_t onceToken;
    
	dispatch_once(&onceToken, ^{
		_JMImageCacheDirectory = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/JMCache"] copy];
	});

	return _JMImageCacheDirectory;
}





@implementation JMImageCache{
    NSMutableDictionary *_touchedImages;
}

-(NSString *)cachePathForKey:(NSString *)key {
    NSString *fileName = [NSString stringWithFormat:@"JMImageCache-%u-%@", (unsigned int)[key hash],
                          self.prefix];
	return [JMImageCacheDirectory() stringByAppendingPathComponent:fileName];
}

+ (JMImageCache *) sharedCache {
	static JMImageCache *_sharedCache = nil;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		_sharedCache = [[JMImageCache alloc] init];
	});

	return _sharedCache;
}

- (id) init {
    self = [super init];
    if(!self) return nil;
    self.maxCacheAge = kDefaultCacheMaxCacheAge;
    self.maxCacheSize = kDefaultMaxCaccheSize;
    _ioQueue = dispatch_queue_create("com.soundtracker.imageio", DISPATCH_QUEUE_SERIAL);
    _touchedImages = [[NSMutableDictionary alloc]initWithCapacity:10];
    [[NSFileManager defaultManager] createDirectoryAtPath:JMImageCacheDirectory()
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
	return self;
}

- (void)dealloc
{
    SDDispatchQueueRelease(_ioQueue);
}

-(void)saveToDisk:(UIImage*)data withKey:(NSString*)key{
    NSString *cachePath = [self  cachePathForKey:key];
    dispatch_async(_ioQueue, ^{
        [self writeData:data toPath:cachePath];
    });
}



-(void)applicationDidReceiveMemoryWarning{
    [super removeAllObjects];
}

- (void) removeAllObjects {
    [super removeAllObjects];

    dispatch_async(_ioQueue, ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error = nil;
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:JMImageCacheDirectory() error:&error];

        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [JMImageCacheDirectory() stringByAppendingPathComponent:path];

                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                if (!removeSuccess) {
                    //Error Occured
                }
            }
        } else {
            //Error Occured
        }
    });
}

- (void) removeObjectForKey:(id)key {
    [super removeObjectForKey:key];

    dispatch_async(_ioQueue, ^{
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSString *cachePath = [self cachePathForKey:key];
        NSError *error = nil;
        [fileMgr removeItemAtPath:cachePath error:&error];
    });
}

#pragma mark -
#pragma mark Getter Methods


-(void)touchImagefForPath:(NSString*)path{
    if (_touchedImages[path]) {
        return;
    }
    _touchedImages[path] = @"";
    NSDictionary* todayAttr  = @{NSFileModificationDate: [NSDate date]};
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[NSFileManager defaultManager ] setAttributes: todayAttr
                                          ofItemAtPath: path
                                                 error: NULL];
    });
}


- (UIImage *)decodedImageWithImage:(UIImage* )image
{
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
	
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
	
    CGContextRelease(context);
	
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

- (void) imageFromDiskForKey:(NSString *)key block:(void (^)(UIImage *image))completion{
    dispatch_async(_ioQueue, ^{
        UIImage *im = [self imageFromDiskForKey:key];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(im);
        });
    });
}

- (UIImage *) imageFromDiskForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    
    
    NSString *path =[self cachePathForKey:key];
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return nil;
    }
    UIImage *image = [UIImage imageWithData:data];
    UIImage *i = nil;
    if (image) {
        i = [self decodedImageWithImage:image];
        [self touchImagefForPath:path];
    }
	return i;
}




#pragma mark -
#pragma mark Disk Writing Operations

- (void) writeData:(UIImage*)image toPath:(NSString *)path {
    if (!image || !path) {
        return;
    }
    NSData *data = UIImagePNGRepresentation(image);
    
    if (data) {
        NSFileManager *fileManager = NSFileManager.new;
        [fileManager createFileAtPath:path
                             contents:data
                           attributes:nil];
    }

}


-(void)cleanCache{
    dispatch_async(_ioQueue, ^{
        [self removeOldFiles];
    });
}

//84362730 = 2013-04-30 19:56:49 +0000
//29062240 = 2013-04-30 19:56:45 +0000
-(void)removeOldFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *diskCacheURL = [NSURL fileURLWithPath:JMImageCacheDirectory() isDirectory:YES];
    NSArray *resourceKeys = @[ NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey ];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtURL:diskCacheURL
                                              includingPropertiesForKeys:resourceKeys
                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                            errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    unsigned long long currentCacheSize = 0;
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    for (NSURL *fileURL in fileEnumerator)
    {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue])
        {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [fileManager removeItemAtURL:fileURL error:nil];
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += [totalAllocatedSize unsignedLongLongValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }

    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize)
    {
        // Target half of our maximum cache size for this cleanup pass.
        const unsigned long long desiredCacheSize = self.maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2)
                                {
                                    return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles)
        {
            if ([fileManager removeItemAtURL:fileURL error:nil])
            {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= [totalAllocatedSize unsignedLongLongValue];
                
                if (currentCacheSize < desiredCacheSize)
                {
                    break;
                }
            }
        }
    }
}
@end