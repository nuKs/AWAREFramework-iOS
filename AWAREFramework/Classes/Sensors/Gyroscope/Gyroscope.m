//
//  Gyroscope.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 11/20/15.
//  Copyright © 2015 Yuuki NISHIYAMA. All rights reserved.
//

#import "Gyroscope.h"
#import "AWAREUtils.h"
#import "EntityGyroscope.h"

NSString* const AWARE_PREFERENCES_STATUS_GYROSCOPE = @"status_gyroscope";
NSString* const AWARE_PREFERENCES_FREQUENCY_GYROSCOPE = @"frequency_gyroscope";
NSString* const AWARE_PREFERENCES_FREQUENCY_HZ_GYROSCOPE = @"frequency_hz_gyroscope";

@implementation Gyroscope{
    CMMotionManager* gyroManager;
}

- (instancetype)initWithAwareStudy:(AWAREStudy *)study dbType:(AwareDBType)dbType{
    self = [super initWithAwareStudy:study
                          sensorName:SENSOR_GYROSCOPE
                        dbEntityName:NSStringFromClass([EntityGyroscope class])
                              dbType:dbType];
    if (self) {
        gyroManager = [[CMMotionManager alloc] init];
        super.sensingInterval = MOTION_SENSOR_DEFAULT_SENSING_INTERVAL_SECOND;
        super.savingInterval = MOTION_SENSOR_DEFAULT_DB_WRITE_INTERVAL_SECOND;
        [self setCSVHeader:@[@"timestamp",@"device_id", @"double_values_0", @"double_values_1",@"double_values_2", @"accuracy",@"label"]];
    }
    return self;
}

- (void) createTable{
    // Send a table create query
    if ([self isDebug]) {
        NSLog(@"[%@] Create Table", [self getSensorName]);
    }
    NSString *query = [[NSString alloc] init];
    query = @"_id integer primary key autoincrement,"
    "timestamp real default 0,"
    "device_id text default '',"
    "double_values_0 real default 0,"
    "double_values_1 real default 0,"
    "double_values_2 real default 0,"
    "accuracy integer default 0,"
    "label text default ''";
    [super createTable:query];
}

- (void)setParameters:(NSArray *)parameters{
    // Get a sensing frequency from settings
    if(parameters != nil){
        double frequency = [self getSensorSetting:parameters withKey:@"frequency_gyroscope"];
        if(frequency != -1){
            super.sensingInterval = [self convertMotionSensorFrequecyFromAndroid:frequency];
        }

        double tempHz = [self getSensorSetting:parameters withKey:AWARE_PREFERENCES_FREQUENCY_HZ_GYROSCOPE];
        if(tempHz > 0){
            super.sensingInterval = 1.0f/tempHz;
        }
    }
}

- (BOOL)startSensorWithSensingInterval:(double)sensingInterval savingInterval:(double)savingInterval{
    
    // Set and start a data uploader
    if([self isDebug]){
        NSLog(@"[%@] Start Gyro Sensor", [self getSensorName]);
    }
    
    [self setBufferSize:savingInterval/sensingInterval];

    gyroManager.gyroUpdateInterval = sensingInterval;
    
    // Start a sensor
    [gyroManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                             withHandler:^(CMGyroData * _Nullable gyroData,
                                           NSError * _Nullable error) {
                                 
                                 // dispatch_async(dispatch_get_main_queue(),^{
                                     
                                     if( error ) {
                                         NSLog(@"%@:%ld", [error domain], [error code] );
                                     } else {
                                         NSNumber *unixtime = [AWAREUtils getUnixTimestamp:[NSDate new]];
                                         NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                                         [dict setObject:unixtime forKey:@"timestamp"];
                                         [dict setObject:[self getDeviceId] forKey:@"device_id"];
                                         [dict setObject:@(gyroData.rotationRate.x) forKey:@"double_values_0"];
                                         [dict setObject:@(gyroData.rotationRate.y) forKey:@"double_values_1"];
                                         [dict setObject:@(gyroData.rotationRate.z) forKey:@"double_values_2"];
                                         [dict setObject:@3 forKey:@"accuracy"];
                                         [dict setObject:@"" forKey:@"label"];
                                         [self setLatestValue:[NSString stringWithFormat:@"%f, %f, %f",gyroData.rotationRate.x,gyroData.rotationRate.y,gyroData.rotationRate.z]];
                                         
                                         [self setLatestData:dict];
                                         
                                         if([self getDBType] == AwareDBTypeSQLite){
                                             [self saveData:dict];
                                         }else if([self getDBType] == AwareDBTypeJSON){
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self saveData:dict];
                                             });
                                         }
                                         
                                         NSDictionary *userInfo = [NSDictionary dictionaryWithObject:dict
                                                                                              forKey:EXTRA_DATA];
                                         [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_GYROSCOPE
                                                                                             object:nil
                                                                                           userInfo:userInfo];
                                    }
                                 // });
                             }];
    return YES;
}


- (void)insertNewEntityWithData:(NSDictionary *)data managedObjectContext:(NSManagedObjectContext *)childContext entityName:(NSString *)entity{
    EntityGyroscope* entityGyro = (EntityGyroscope *)[NSEntityDescription
                                                insertNewObjectForEntityForName:entity
                                                inManagedObjectContext:childContext];
    
    entityGyro.device_id = [data objectForKey:@"device_id"];
    entityGyro.timestamp = [data objectForKey:@"timestamp"];
    entityGyro.double_values_0 = [data objectForKey:@"double_values_0"];
    entityGyro.double_values_1 = [data objectForKey:@"double_values_1"];
    entityGyro.double_values_2 = [data objectForKey:@"double_values_2"];
    entityGyro.accuracy = [data objectForKey:@"accuracy"];
    entityGyro.label =  [data objectForKey:@"label"];
}

- (BOOL)stopSensor{
    [gyroManager stopGyroUpdates];
    return YES;
}


@end