//
//  HGIncidentView.m
//  kryptonite
//
//  Created by Brian McManus on 6/9/13.
//  Copyright (c) 2013 Brian McManus. All rights reserved.
//

#import "HGIncidentView.h"
#import <QuartzCore/QuartzCore.h>

@implementation HGIncidentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1.0;
    [super drawRect:rect];
}

@end
