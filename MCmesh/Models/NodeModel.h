//
//  NodeModel.h
//  MCmesh
//
//  Created by zhoulanjun on 16/6/16.
//  Copyright © 2016年 ZhouLanjun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface NodeModel : NSObject

@property (nonatomic,retain)CBPeripheral *peripheral;
@property (nonatomic,retain)NSString *peripheralName;
@property (nonatomic,assign)PeripheralType peripType;
@end
