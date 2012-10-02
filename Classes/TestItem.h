//
//  TestItem.h
//  CPT
//
//  Created by Jonatan Liljedahl on 10/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TestItem : NSObject {
	int type;
	NSTimeInterval length;
	NSTimeInterval duration;
	BOOL expectation;
	BOOL failed;
	NSString *filename;
	UIImageView *image;
	AVAudioPlayer *sound;
}

@property (assign, nonatomic) int type;
@property (assign, nonatomic) NSTimeInterval length;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL expectation;
@property (assign, nonatomic) BOOL failed;
@property (retain, nonatomic) NSString *filename;
@property (retain, nonatomic) UIImageView *image;
@property (retain, nonatomic) AVAudioPlayer *sound;

@end
