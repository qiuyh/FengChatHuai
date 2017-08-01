//
//  QYHContactModel.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/13.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHContactModel.h"

@implementation QYHContactModel

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.vCard       forKey:@"vCard"];
    [aCoder encodeObject:self.jid         forKey:@"jid"];
    [aCoder encodeObject:self.nickname    forKey:@"nickname"];
    [aCoder encodeObject:self.displayName forKey:@"displayName"];
    [aCoder encodeObject:self.photo       forKey:@"photo"];
    [aCoder encodeObject:self.sectionNum  forKey:@"sectionNum"];

}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        self.vCard       = [aDecoder decodeObjectForKey:@"vCard"];
        self.jid         = [aDecoder decodeObjectForKey:@"jid"];
        self.nickname    = [aDecoder decodeObjectForKey:@"nickname"];
        self.displayName = [aDecoder decodeObjectForKey:@"displayName"];
        self.photo       = [aDecoder decodeObjectForKey:@"photo"];
        self.sectionNum  = [aDecoder decodeObjectForKey:@"sectionNum"];
       
    }
    
    return self;
}

@end
