//
//  ViewController.m
//  QR Scanner
//
//  Created by Kyungjung Kim on 2023/02/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize isReading, lblStatus, captureSession, videoPreviewLayer, audioPlayer, textView, viewforCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isReading = false;
}


#pragma mark - IBAction methods

- (IBAction)startButtonClicked:(UIButton *)sender {
    if (!isReading) {
        if ([self startReading]) {
            [lblStatus setText:@"Scanning for QR Code..."];
        }
    } else {
        [self stopReading];
    }

    isReading = !isReading;
}


#pragma mark - Instance methods

- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (captureDevice.position == AVCaptureDevicePositionBack) {
        NSLog(@"back camera");
    } else if (captureDevice.position == AVCaptureDevicePositionFront) {
        NSLog(@"Front Camera");
    } else {
        NSLog(@"Unspecified");
    }
       
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        
        return NO;
    }

    captureSession = [AVCaptureSession new];
    [captureSession addInput:input];

    AVCaptureMetadataOutput *captureMetadataOutput = [AVCaptureMetadataOutput new];
    [captureSession addOutput:captureMetadataOutput];

    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPreviewLayer setFrame:viewforCamera.layer.bounds];
    [viewforCamera.layer addSublayer:videoPreviewLayer];
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        [self->captureSession startRunning];
    });

    return YES;
}

- (void)stopReading {
    [captureSession stopRunning];
    captureSession = nil;
    [videoPreviewLayer removeFromSuperlayer];
}

- (void)loadBeepSound {
   NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
   NSURL *beepURL = [NSURL URLWithString:beepFilePath];
   NSError *error;

   audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];

   if (error) {
       NSLog(@"Could not play beep file.");
       NSLog(@"%@", [error localizedDescription]);
   } else {
       [audioPlayer prepareToPlay];
   }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
       AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];

       if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
           [textView performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];

           if ([textView.text containsString:@"http"]) {
               NSString *text = textView.text;

               NSURL *url  = [[NSURL alloc] initWithString:text];
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:@"This code have a http link.Do you want to open it.?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];

               UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                   [[UIApplication sharedApplication] openURL:url];
               }];

               UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                   self->lblStatus.text = @"Your Text Will Shown Below.";
               }];

               [alert addAction:cancel];
               [alert addAction:okAction];

               [self presentViewController:alert animated:YES completion:nil];
           } else {
              // you can show your custom alert like - there is no HTTP link present in the QR Code. //
           }

           [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];

          // [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];

           isReading = NO;
           if (audioPlayer) {
               [audioPlayer play];
           }
       }
   }
}

@end
