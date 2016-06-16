//
//  singleMacros.h
//  MarcosDefine
//
//  Created by zhoulanjun on 16/3/4.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#ifndef singleMacros_h
#define singleMacros_h


// .h  如果要声明一个单例 在类的.h中这样写
#define single_interface(class)  + (class *)shared##class;

// .m  在类的.m中这样写 调用的时候 [类名 sharedPersonManager]
// \ 代表下一行也属于宏
// ## 是分隔符
#define single_implementation(class) \
static class *_instance; \
\
+ (class *)shared##class \
{ \
if (_instance == nil) { \
_instance = [[self alloc] init]; \
} \
return _instance; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instance = [super allocWithZone:zone]; \
}); \
return _instance; \
}



#endif /* singleMacros_h */
