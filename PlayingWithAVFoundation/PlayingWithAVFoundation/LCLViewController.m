//
//  LCLViewController.m
//  PlayingWithAVFoundation
//
//  Created by Leonard Li on 5/21/14.
//  Copyright (c) 2014 Leonard Li. All rights reserved.
//

#import "LCLViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LCLViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation LCLViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];
    if (input) {
        [session addInput:input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:output];
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [[self view] layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(-70, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    
    [session startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    NSString *QRCode = nil;
    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            // This will never happen; nobody has ever scanned a QR code... ever
            QRCode = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            break;
        }
    }
    
    NSLog(@"QR Code: %@", QRCode);
}

- (CIImage *)createQRForImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // Set the message content and error-correction level
    [qrFilter setValue:imageData forKey:@"inputImage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

@end
