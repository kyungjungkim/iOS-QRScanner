//
//  ViewController.h
//  QR Scanner
//
//  Created by Kyungjung Kim on 2023/02/13.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) IBOutlet UIView *viewforCamera;
@property (strong, nonatomic) IBOutlet UILabel *lblStatus;
@property (strong, nonatomic) IBOutlet UITextView *textView;

- (IBAction)startButtonClicked:(UIButton *)sender;

- (BOOL)startReading;
- (void)stopReading;
- (void)loadBeepSound;

@property (nonatomic) BOOL isReading;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;


@end

