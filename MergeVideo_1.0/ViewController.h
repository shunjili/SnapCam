//
//  ViewController.h
//  MergeVideo_1.0
//
//  Created by Shunji Li on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController
{
    BOOL assetLoaded;

}
@property (nonatomic, strong)     AVAsset *firstAsset;
@property (nonatomic, strong)     AVAsset *secondAsset;
@property (nonatomic, strong)     AVAsset *audioAsset;

- (void)MergeAndSave:(AVAsset*) asset1 with:(AVAsset*) asset2;
- (void)loadAsset: (NSURL*) firstURL with: (NSURL*) secondURL;
- (void)exportDidFinish:(AVAssetExportSession*)session;
- (NSString*) documentPath;

@end
