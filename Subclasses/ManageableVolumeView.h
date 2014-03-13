//
//  ManageableVolumeView.h
//  CircularProgressViewTest
//
//  Created by Vladimir Doukhanine on 3/11/14.
//  Copyright (c) 2014 Vladimir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CircularProgressView.h"

@interface ManageableVolumeView : MPVolumeView

- (void)setValue:(float)value;
@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;

@end
