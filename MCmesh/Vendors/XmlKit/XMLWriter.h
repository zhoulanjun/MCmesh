//
// XMLWriter.h
//

#import <Foundation/Foundation.h>

/*如果XML有属性节点，则需要定义key = xmlAttribute 的字典*/
#define XmlAttributeKey     @"xmlAttribute"

/*如果有属性节点的标签无子节点，则value需要定义为key = xmltext的字典*/
#define XmlTextKey          @"xmltext"

@interface XMLWriter : NSObject{
@private
    NSMutableArray* nodes;
    NSString* xml;
    NSMutableArray* treeNodes;
    BOOL isRoot;
    NSString* passDict;
    BOOL withHeader;
}
+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary;
+(NSString *)XMLStringFromDictionary:(NSDictionary *)dictionary withHeader:(BOOL)header;
+(BOOL)XMLDataFromDictionary:(NSDictionary *)dictionary toStringPath:(NSString *) path  Error:(NSError **)error;

@end
