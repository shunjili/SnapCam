//
//  ViewController.m
//  MergeVideo_1.0
//
//  Created by Shunji Li on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"



@interface ViewController 
()

@end

@implementation ViewController
@synthesize firstAsset, secondAsset, audioAsset;

-(NSString*) documentPath{
NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return documentsDirectory;

}

- (void)MergeAndSave
{
    if(firstAsset !=nil && secondAsset!=nil){
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        //VIDEO TRACK
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];

        
        //firstTrack.preferredTransform = invert;
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        //secondTrack.preferredTransform = invert;
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:firstAsset.duration error:nil];

        //AUDIO TRACK
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, firstAsset.duration) ofTrack:[[firstAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]  atTime:kCMTimeZero error:nil];
        [audioTrack insertTimeRange: CMTimeRangeMake(kCMTimeZero, secondAsset.duration) ofTrack:[[secondAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]  atTime:firstAsset.duration error:nil];
        if(audioAsset!=nil){
            AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration)) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        } 
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration));
        
        //FIXING ORIENTATION//
        AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *FirstAssetTrack = [[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [FirstlayerInstruction setOpacity:0.0 atTime:firstAsset.duration];
        [FirstlayerInstruction setTransform:FirstAssetTrack.preferredTransform atTime:kCMTimeZero];
        AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
         AVAssetTrack *SecondAssetTrack = [[secondAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [SecondlayerInstruction setTransform:SecondAssetTrack.preferredTransform atTime:firstAsset.duration];
        NSLog(@"%f, %f", FirstAssetTrack.naturalSize.width, FirstAssetTrack.naturalSize.height);
        
        MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];;
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, 30);
        MainCompositionInst.renderSize = CGSizeMake(1280, 720);
        NSString *documentsDirectory = [self documentPath];

        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
        
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset1280x720];
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.videoComposition = MainCompositionInst;
        exporter.shouldOptimizeForNetworkUse = NO;
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self exportDidFinish:exporter];
             });
         }];
    }


}

- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                }else{
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                    [alert show];
                                                }
                                                
                                            });
                                            
                                        }];
        } 
    }
	
    audioAsset = nil;
    firstAsset = nil;
    secondAsset = nil;
   // [ActivityView stopAnimating];
}
- (void)loadAsset: (NSURL*) firstURL with: (NSURL*) secondURL
{
    firstAsset = [AVAsset assetWithURL:firstURL];
    secondAsset = [AVAsset assetWithURL:secondURL];

}


- (void)viewDidLoad

{
    [super viewDidLoad];
    NSString *path = [self documentPath];
    NSString *firstPath = [path stringByAppendingPathComponent:@"v1.mov"];
    NSString *secondPath = [path stringByAppendingPathComponent:@"v2.mov"];

    NSURL *firstURL = [NSURL fileURLWithPath:firstPath];
    NSURL *secondURL = [NSURL fileURLWithPath:secondPath];
    [self loadAsset:firstURL with:secondURL];
    [self MergeAndSave];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
