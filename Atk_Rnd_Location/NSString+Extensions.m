//
//  NSString+Extensions.m
//  Atk_Rnd_Location
//
//  Created by Rick Boykin on 8/15/14.
//  Copyright (c) 2014 Asymptotik Limited. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

+ (NSString *)stringWithOffsetInSeconds:(NSUInteger)offset
{
    int64_t timeFromStart = offset;
    int64_t hours   = floorl(timeFromStart / 3600);
    int64_t minutes = (int32_t)(timeFromStart / 60) % 60;
    int64_t seconds = timeFromStart % 60;
    NSString *text;
    if (hours == 0) {
        if (minutes == 0) {
            text = [NSString stringWithFormat:@"%llds", seconds];
        }
        else {
            text = [NSString stringWithFormat:@"%lld:%02lld", minutes, seconds];
        }
    }
    else {
        text = [NSString stringWithFormat:@"%lld:%lld:02%lld", hours, minutes, seconds];
    }
    
    return text;
}

@end
