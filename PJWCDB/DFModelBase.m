//
//  modelBase.m
//  HelpToBorrow
//
//  Created by chen on 14/12/19.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import "DFModelBase.h"
#import <objc/runtime.h>

@implementation DFModelBase

-(BOOL)parseToMode:(NSDictionary*)dic
{
    if (dic == nil) {
        NSLog(@"对象模型字典为空");
        return NO;
    }
    return YES;
}

+(id)modelWithDictionary:(NSDictionary*)dic
{
    if (dic == nil) {
        return nil;
    }
    
    DFModelBase *base = [DFModelBase new];
    [base parseToMode:dic];
    return base;
}


+(id)modelAutoParseWithDictionary:(NSDictionary*)dic
{
    if (dic == nil || [dic isKindOfClass:[NSDictionary class]] == NO) {
        return nil;
    }
    
    //    NSLog(@"%@",[self class]);
    
    DFModelBase *base = [self new];
    [base autoParseToModel:dic];
    return base;
    
}


-(BOOL)autoParseToModel:(NSDictionary*)dic
{
    if (dic == nil) {
        NSLog(@"字典为nil");
        return NO;
    }
    
    unsigned int count = 0;
    //成员变量指针
    Ivar *vars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        //取变量的名
        const char *varName = ivar_getName(var);
        //取变量的类型
//        const char *varType = ivar_getTypeEncoding(var);
        
        NSString *key = [NSString stringWithUTF8String:varName];
        NSRange range = NSMakeRange(1, key.length - 1);
        NSString *k = [key substringWithRange:range];
        
        id value = [dic objectForKey:k];
        
        if ([value isKindOfClass:[NSNull class]]) {
            
            value = @"";
        }
        if ([value isKindOfClass:[NSString class]]) {
            object_setIvar(self, var, value);
        }else if ([value isKindOfClass:[NSNumber class]]){
            

            NSString *v = [NSString stringWithFormat:@"%.2f",[value doubleValue]];
//            NSString *v = [value stringValue];
            
            object_setIvar(self, var, v);
        }
        //给成员变量设置值
        
        //取变量值看是否成功
        //id varValue =  object_getIvar(self, var);
        //        NSLog(@"类名:%@{%s *%@=%@}---字典里值:%@", [self class], varType, k, varValue, value);
        
    }
    
    [self autoParseToModelExpand:dic];
    return YES;
}

-(void)autoParseToModelExpand:(NSDictionary*)dic
{
    //扩展解析在这里进行
}



//对象转JSON或者字典
+ (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    for(int i = 0;i < propsCount; i++)
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        [dic setObject:value forKey:propName];
    }
    return dic;
}

+ (void)print:(id)obj
{
    NSLog(@"%@", [self getObjectData:obj]);
}


+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error
{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}

+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        
        return dic;
    }
    
    return [self getObjectData:obj];
}


@end
