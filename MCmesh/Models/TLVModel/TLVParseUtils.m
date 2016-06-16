//
//  SAXUnionFiled55Utils.m
//  CashBox
//
//  Created by ZKF on 13-11-18.
//  Copyright (c) 2013年 ZKF. All rights reserved.
//

#import "TLVParseUtils.h"

@implementation TLVParseUtils
{
    int i ;
    NSInteger nextLength;
    BOOL _isNext;
}

-(NSArray*)saxUnionField55_2List:(NSString*) hexfiled55
{
    if (nil == hexfiled55)
    {
        
    }
    return [[[self builderTLV:hexfiled55] retain] autorelease];
}


#pragma mark 1-
-(NSArray*) builderTLV:(NSString *)hexString
{
    NSMutableArray *arr = [[[NSMutableArray alloc] initWithCapacity:1024] autorelease];
    
    NSInteger position = 0;
    while (position != hexString.length)
    {
        NSString * _hexTag = [self getUnionTag:hexString P:position]; //
        
        NSLog(@"tlv----t----%@",_hexTag);
        if ([_hexTag isEqualToString:@"60"])
        {
            _isNext = YES;
        }
        
        if ([_hexTag isEqualToString:@"00"] || [_hexTag isEqualToString:@"0000"])
        {
            position += _hexTag.length;
            continue;
        }
        
        position += _hexTag.length;
        
        LPositon *l_position = [[[self getUnionLAndPosition:hexString P:position] retain] autorelease]; //
        
        if ([_hexTag isEqualToString:@"61"] && _isNext == YES)
        {
            l_position.vl=nextLength;
        }
        
        NSInteger _vl = l_position.vl;
        
        NSLog(@"tlv----l----%ld",_vl);
        
        position = l_position.position;
        
        NSString* _value = [hexString substringWithRange:NSMakeRange(position, _vl * 2)];
        NSLog(@"tlv----v----%@",_value);
        
        if (i==0x60)
        {
            int k = ChangeNum((char *)[_value UTF8String],4);
            
            nextLength = k;
        }
        
        position = position + _value.length;
        TLV *tlv = [[[TLV alloc] init] autorelease];
        
        tlv.tag = _hexTag;
        tlv.value = _value;
        tlv.length = _vl;
        // NSLog(@"%@")
        
        [arr addObject:tlv];
    }
    
    //恢复为初始值
    _isNext=NO;
    
    return arr;
}


#pragma mark 2-
-(NSString*) getUnionTag:(NSString* )hexString P:(NSInteger) position
{
    NSString* firstByte = [hexString substringWithRange:NSMakeRange(position, 2)];
    
    i= ChangeNum((char *)[firstByte UTF8String],2);  //
    
    
    
    //    if (i==0x56 || i==0x55 || i==0x58 || i==0x61)
    //    {
    //        NSLog(@"%@",[hexString substringWithRange:NSMakeRange(position, 2)]);
    //        return [hexString substringWithRange:NSMakeRange(position, 2)];
    //
    //    }else
    //    {
    //        NSLog(@"%@",[hexString substringWithRange:NSMakeRange(position, 2)]);
    //        return [hexString substringWithRange:NSMakeRange(position, 2)];
    //    }
    
    
    if ((i & 0x1f) == 0x1f)
    {
//        NSLog(@"%@",[hexString substringWithRange:NSMakeRange(position, 4)]);
        return [hexString substringWithRange:NSMakeRange(position, 4)];
        
    } else
    {
//        NSLog(@"%@",[hexString substringWithRange:NSMakeRange(position, 2)]);
        
        return [hexString substringWithRange:NSMakeRange(position, 2)];
        
    }
    
}

#pragma mark 3-
int ChangeNum(char * str,int length)
{
    char  revstr[128] = {0};  //根据十六进制字符串的长度，这里注意数组不要越界
    int   num[16] = {0};
    int   count = 1;
    int   result = 0;
    strcpy(revstr,str);
    
    for (int i = length - 1;i >= 0;i--)
    {
//        NSLog(@"%c",revstr[i]);
        
        if ((revstr[i] >= '0') && (revstr[i] <= '9'))
        {
            num[i] = revstr[i] - 48;//字符0的ASCII值为48
            
        } else if ((revstr[i] >= 'a') && (revstr[i] <= 'f'))
        {
            num[i] = revstr[i] - 'a' + 10;
            
        } else if ((revstr[i] >= 'A') && (revstr[i] <= 'F'))
        {
            num[i] = revstr[i] - 'A' + 10;
            
        }else
        {
            num[i] = 0;
        }
        
        NSLog(@"%d",num[i]);
        
        result = result+num[i]*count;
        count = count*16;//十六进制(如果是八进制就在这里乘以8)
    }
//    NSLog(@"%d",result);
    return result;
}

#pragma mark 4-
-(LPositon *)getUnionLAndPosition:(NSString *)hexString P:(NSInteger) position
{
    NSString *firstByteString = [hexString substringWithRange:NSMakeRange(position, 2)];
    int j = ChangeNum((char *)[firstByteString UTF8String],2);
    
    NSString * hexLength = @"";
    if (((j >> 7) & 1) == 0)
    {
        hexLength = [hexString substringWithRange:NSMakeRange(position, 2)];
//        NSLog(@"%@",hexLength);
        
        position = position + 2;
        
    } else
    {
        // 当最左侧的bit位为1的时候，取得后7bit的值，
        int _L_Len = j & 127;
        position = position + 2;
        hexLength = [hexString substringWithRange:NSMakeRange(position, _L_Len * 2)];
//        NSLog(@"%@",hexLength);
        
        // position表示第一个字节，后面的表示有多少个字节来表示后面的Value值
        position = position + _L_Len * 2;
        
    }
    LPositon *LP = [[[LPositon alloc] init] autorelease];
    
    LP.vl = ChangeNum((char *)[hexLength UTF8String],2);   //
    
    
    LP.position = position;
    return LP;
}

@end
