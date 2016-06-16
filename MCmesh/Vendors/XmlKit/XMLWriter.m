//
//  XMLWriter.m
//
#import "XMLWriter.h"
#define PREFIX_STRING_FOR_ELEMENT @"@" //From XMLReader


@implementation XMLWriter

-(void)serialize:(id)root key:(NSString *)rootKey
{    
    if([root isKindOfClass:[NSArray class]])
        {
            int mula = (int)[root count];
            mula--;
            [nodes addObject:[NSString stringWithFormat:@"%i",(int)mula]];

            for(id objects in root)
            {
                if ([[nodes lastObject] isEqualToString:@"0"] || [nodes lastObject] == NULL || ![nodes count])
                {
                    [nodes removeLastObject];
                    [self serialize:objects key:rootKey];
                }
                else
                {
                    [self serialize:objects key:rootKey];
                    if(!isRoot)
                        xml = [xml stringByAppendingFormat:@"</%@><%@>",[treeNodes lastObject],[treeNodes lastObject]];
                    else
                        isRoot = FALSE;
                    int value = [[nodes lastObject] intValue];
                    [nodes removeLastObject];
                    value--;
                    [nodes addObject:[NSString stringWithFormat:@"%i",(int)value]];
                }
            }
        }
        else if ([root isKindOfClass:[NSDictionary class]])
        {
            //[self XMLFindAttribute:root];
            for (NSString* key in root) //遍历所有的key
            {
                if(!isRoot)
                {
                    //xml attribute value
                    if([key isEqualToString:XmlAttributeKey])
                    {
                        id dic = [root objectForKey:key];
                        if ([dic isKindOfClass:[NSDictionary class]])
                        {
                            NSString *attrStr = @"";
                            for (NSString* key in dic) {
                                attrStr = [attrStr stringByAppendingFormat:@" %@=\"%@\"", key, [dic objectForKey:key]];
                            }
                            NSMutableString *mutableXml = [[NSMutableString alloc] initWithString:xml];
                            if (rootKey) {
                                [mutableXml insertString:attrStr atIndex:[self XMLFindLastStringLocation:xml findStr:rootKey] + ([rootKey length] + 1)];
                                xml = mutableXml;
                            }
                        }
                    }
                    else
                    {
                        [treeNodes addObject:key];
                        if(![key isEqualToString:XmlTextKey])
                        {
                            xml = [xml stringByAppendingFormat:@"<%@>",key];
                        }
                        [self serialize:[root objectForKey:key] key:key];
                        if(![key isEqualToString:XmlTextKey])
                        {
                            xml =[xml stringByAppendingFormat:@"</%@>",key];
                        }
                        [treeNodes removeLastObject];
                    }
                } else {
                    isRoot = FALSE;
                    [self serialize:[root objectForKey:key] key: key];
                }
            }
        }
        else if ([root isKindOfClass:[NSString class]] || [root isKindOfClass:[NSNumber class]] || [root isKindOfClass:[NSURL class]])
        {
//            if ([root hasPrefix:"PREFIX_STRING_FOR_ELEMENT"])
//            is element
//            else
            xml = [xml stringByAppendingFormat:@"%@",root];
        }
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        // Initialization code here.
        xml = @"";
        if (withHeader)
            xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>";
        nodes = [[NSMutableArray alloc] init]; 
        treeNodes = [[NSMutableArray alloc] init];
        isRoot = YES;
        passDict = [[dictionary allKeys] lastObject];
        xml = [xml stringByAppendingFormat:@"<%@>\n",passDict];
        [self serialize:dictionary key:nil];
    }
    
    return self;
}
- (id)initWithDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header {
    withHeader = header;
    self = [self initWithDictionary:dictionary];
    return self;
}

-(void)dealloc
{
    //    [xml release],nodes =nil;
    [nodes release], nodes = nil ;
    [treeNodes release], treeNodes = nil;
    [super dealloc];
}

-(NSString *)getXML
{
    xml = [xml stringByReplacingOccurrencesOfString:@"</(null)><(null)>" withString:@"\n"];
    xml = [xml stringByAppendingFormat:@"\n</%@>",passDict];
    return xml;
}

+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary
{
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[[XMLWriter alloc]initWithDictionary:dictionary]autorelease];
    return [fromDictionary getXML];
}

+ (NSString *) XMLStringFromDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header {
    if (![[dictionary allKeys] count])
        return NULL;
    XMLWriter* fromDictionary = [[[XMLWriter alloc]initWithDictionary:dictionary withHeader:header]autorelease];
    return [fromDictionary getXML];
}

+(BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary toStringPath:(NSString *) path  Error:(NSError **)error
{
    
    XMLWriter* fromDictionary = [[[XMLWriter alloc]initWithDictionary:dictionary]autorelease];
    [[fromDictionary getXML] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:error];
    if (error)
        return FALSE;
    else
        return TRUE;
    
}

- (NSUInteger)XMLFindLastStringLocation:(NSString *)originalString findStr:(NSString *)keyString
{
    NSRange Range;
    NSUInteger location = 0;
    
    keyString = [NSString stringWithFormat:@"<%@>", keyString];
    while (originalString.length > 0) {
        
        Range = [originalString rangeOfString:keyString];
        if (Range.location != NSNotFound) {
            location += Range.location;
            originalString = [originalString substringFromIndex:Range.location + keyString.length];
            if ([originalString rangeOfString:keyString].location != NSNotFound) {
                location += keyString.length;
            }
        }
        else{
            break;
        }
    }
    
    return location;
}


/*
<CircleMemberList version="1.0" url="http://122.com">
 <CircleMember version="1.0" url="http://122.com”>
    <name version="1.0" url="http://122.com">tom</name>
    <NickName>wang</NickName>
 </CircleMember>
 
 <CircleMember version="1.0" url="http://122.com”>
    <name version="1.0" url="http://122.com">tom</name>
    <NickName>wang</NickName>
 </CircleMember>

 <CircleMember version="1.0" url="http://122.com”>
    <name version="1.0" url="http://122.com">tom</name>
    <NickName>wang</NickName>
 </CircleMember>
 
</CircleMemberList>
 */


- (NSDictionary *)GenerateDemoDic
{
    NSDictionary *attrDic = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"version", @"http://122.com",@"url", nil];
    
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:attrDic,XmlAttributeKey, @"tom",XmlTextKey, nil];
    NSDictionary *attrdic = [NSDictionary dictionaryWithObjectsAndKeys:attrDic,@"xmlAttribute", nameDic, @"name",@"wang", @"NickName", nil];
    
    NSArray *array = @[attrdic, attrdic, attrdic];

    NSDictionary *subDic = [NSDictionary dictionaryWithObjectsAndKeys:attrDic,XmlAttributeKey, array, @"CircleMember", nil];
    
    NSDictionary *objDic = [NSDictionary dictionaryWithObjectsAndKeys:subDic, @"CircleMemberList", nil];
    
    return objDic;
    
}


//首先遍历查询子节点是否有属性的key  -- add by tom
//- (void)XMLFindAttribute:(id)object
//{
//    for (NSString* key in object)
//    {
//        id obj = [object objectForKey:key];
//        
//        if ([obj isKindOfClass:[NSDictionary class]])
//        {
//            for (NSString *subKey in [object objectForKey:key])
//            {
//                if([subKey isEqualToString:XmlAttributeKey])
//                {
//                    [superKeys addObject:key];
//                }
//            }
//        }
//        else if ([obj isKindOfClass:[NSArray class]])
//        {
//            
//        }
//        
//    }
//}
@end