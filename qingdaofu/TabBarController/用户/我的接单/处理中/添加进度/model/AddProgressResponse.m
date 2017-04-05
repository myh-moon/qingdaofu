//
//  AddProgressResponse.m
//  qingdaofu
//
//  Created by zhixiang on 17/2/7.
//  Copyright © 2017年 zhixiang. All rights reserved.
//

#import "AddProgressResponse.h"

@implementation AddProgressResponse

+ (NSDictionary *)objectClassInArray
{
    return @{@"actions" : @"AddProgressModel"};
}

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"actions" : @"result.actions"};
}

@end
