//
//  NSObject+SLRuntime.h
//
//  Created by 秦-政 on 2016/08/16.
//

#import "NSObject+SLRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (SLRuntime)

+ (NSArray *)sl_objectsWithArray:(NSArray *)array {
    
    if (array.count == 0) {
        return nil;
    }
    
    NSAssert([array[0] isKindOfClass:[NSDictionary class]], @"必须传入字典数组");

    NSArray *list = [self sl_propertiesList];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        
        id obj = [self new];
        
        for (NSString *key in dict) {
            if (![list containsObject:key]) {
                continue;
            }
            
            [obj setValue:dict[key] forKey:key];
        }
        
        [arrayM addObject:obj];
    }
    
    return arrayM.copy;
}

void *propertiesKey = "cn.itcast.propertiesList";

+ (NSArray *)sl_propertiesList {
    
    // 获取关联对象
    NSArray *result = objc_getAssociatedObject(self, propertiesKey);
    
    if (result != nil) {
        return result;
    }
    
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (unsigned int i = 0; i < count; i++) {
    
        objc_property_t pty = list[i];
        
        const char *cName = property_getName(pty);
        NSString *name = [NSString stringWithUTF8String:cName];
        
        [arrayM addObject:name];
    }
    
    free(list);
    
    // 设置关联对象
    objc_setAssociatedObject(self, propertiesKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, propertiesKey);
}

void *ivarsKey = "cn.itcast.ivarsList";

+ (NSArray *)sl_ivarsList {
    
    // 获取关联对象
    NSArray *result = objc_getAssociatedObject(self, ivarsKey);
    
    if (result != nil) {
        return result;
    }
    
    unsigned int count = 0;
    Ivar *list = class_copyIvarList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (unsigned int i = 0; i < count; i++) {
        
        Ivar ivar = list[i];
        
        const char *cName = ivar_getName(ivar);
        NSString *name = [NSString stringWithUTF8String:cName];
        
        [arrayM addObject:name];
    }
    
    free(list);
    
    // 设置关联对象
    objc_setAssociatedObject(self, ivarsKey, arrayM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return objc_getAssociatedObject(self, ivarsKey);
}

+ (NSArray *)sl_methodList {

    unsigned int count = 0;
    Method *list = class_copyMethodList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];

    for (unsigned int i = 0; i < count; i++) {
        
        Method method = list[i];
        
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        
        [arrayM addObject:name];
    }
    
    free(list);
    
    return arrayM.copy;
}

+ (NSArray *)sl_protocolList {
    
    unsigned int count = 0;
    __unsafe_unretained Protocol **list = class_copyProtocolList([self class], &count);
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (unsigned int i = 0; i < count; i++) {
        
        Protocol *protocol = list[i];
        
        const char *cName = protocol_getName(protocol);
        NSString *name = [NSString stringWithUTF8String:cName];
        
        [arrayM addObject:name];
    }
    
    free(list);
    
    return arrayM.copy;
}

@end
