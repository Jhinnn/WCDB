//
//  modelBase.h
//  HelpToBorrow
//
//  Created by chen on 14/12/19.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFModelBase : NSObject

//字典转成对象模型
-(BOOL)parseToMode:(NSDictionary*)dic;
+(id)modelWithDictionary:(NSDictionary*)dic;

//完成自动解析
+(id)modelAutoParseWithDictionary:(NSDictionary*)dic;
-(BOOL)autoParseToModel:(NSDictionary*)dic;
//如果有扩展的解析实现以下消息就可以
-(void)autoParseToModelExpand:(NSDictionary*)dic;


//对象转JSON或者字典
+ (NSDictionary*)getObjectData:(id)obj;
+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;
+ (void)print:(id)obj;

@end
