//
//  AWAREFrameworkViewController.m
//  AWAREFramework
//
//  Created by tetujin on 03/22/2018.
//  Copyright (c) 2018 tetujin. All rights reserved.
//

#import "AWAREFrameworkViewController.h"
#import "AWAREFrameworkAppDelegate.h"
#import <AWAREFramework/AWARESensors.h>
#import <AWAREFramework/ESMSchedule.h>
#import <AWAREFramework/ESMScheduleManager.h>
#import <AWAREFramework/ESMScrollViewController.h>
#import <AWAREFramework/SyncExecutor.h>

@interface AWAREFrameworkViewController ()

@end

@implementation AWAREFrameworkViewController{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AWAREDelegate * delegate = (AWAREDelegate *) [UIApplication sharedApplication].delegate;
    AWAREStudy * study = delegate.sharedAWARECore.sharedAwareStudy;
    AWARESensorManager * manager = delegate.sharedAWARECore.sharedSensorManager;
    [study setMaximumNumberOfRecordsForDBSync:100];
    [study setWebserviceServer:@"https://api.awareframework.com/index.php/webservice/index/1749/ITrUqPkbcSNM"];
    
    // delegate.sharedAWARECore.requestBackgroundSensing;
    [delegate.sharedAWARECore requestNotification:[UIApplication sharedApplication]];
    // [self testSensingWithStudy:study dbType:AwareDBTypeCSV sensorManager:manager];
    // [self testAccelerometerSync];
    // [self audioSensorWith:study];
    // [self testESMSchedule];
    // [self testCSVStorageWithStudy:study];
    [self testSensingWithStudy:study dbType:AwareDBTypeSQLite sensorManager:manager];
}

- (void) testCSVStorageWithStudy:(AWAREStudy * )study{
    Battery * battery = [[Battery alloc] initWithAwareStudy:study dbType:AwareDBTypeCSV];
    [battery setIntervalSecond:1];
    [battery startSensor];
    [battery setSensorEventCallBack:^(NSDictionary *data) {
        NSLog(@"%@",data.debugDescription);
    }];
}

- (void) testAccelerometerSync{
    
    AWAREDelegate * delegate = (AWAREDelegate *) [UIApplication sharedApplication].delegate;
    AWAREStudy * study = delegate.sharedAWARECore.sharedAwareStudy;
    [study setMaximumNumberOfRecordsForDBSync:100];
    [study setMaximumByteSizeForDBSync:1000];
    [study setCleanOldDataType:cleanOldDataTypeAlways];
    
    Accelerometer * accelerometer = [[Accelerometer alloc] initWithAwareStudy:study dbType:AwareDBTypeJSON];
    [accelerometer.storage removeLocalStorageWithName:@"accelerometer" type:@"json"];
    
    [accelerometer.storage setBufferSize:10];
    for (int i =0; i<100; i++) {
//        NSNumber * timestamp = @([NSDate new].timeIntervalSince1970);
        [accelerometer.storage saveDataWithDictionary:@{@"timestamp":@(i),@"device_id":study.getDeviceId} buffer:YES saveInMainThread:YES];
    }
    // [accelerometer.storage resetMark];

    // [accelerometer setDebug:YES];
    [accelerometer.storage setSyncTaskIntervalSecond:1];
    [accelerometer performSelector:@selector(startSyncDB) withObject:nil afterDelay:10];
    
}

- (void)audioSensorWith:(AWAREStudy *)study{
    AmbientNoise * noise = [[AmbientNoise alloc] initWithAwareStudy:study dbType:AwareDBTypeSQLite];
    [noise saveRawData:YES];
    [noise createTable];
    [noise startSensor];
    [noise setSensorEventCallBack:^(NSDictionary *data) {
        NSLog(@"%@",[data objectForKey:@"timestamp"]);
    }];
    [noise setDebug:YES];
////    [noise.storage setBufferSize:55];
//    [noise.storage setDebug:YES];
//    for (int i =0; i<100; i++) {
//        //        NSNumber * timestamp = @([NSDate new].timeIntervalSince1970);
//        [noise.storage saveDataWithDictionary:@{@"timestamp":@(i),@"device_id":study.getDeviceId} buffer:YES saveInMainThread:YES];
//    }
//
    [noise.storage setDebug:YES];
    [noise performSelector:@selector(startSyncDB) withObject:nil afterDelay:10];
//    id callback = ^(NSString *name, double progress, NSError * _Nullable error) {
//        NSLog(@"[%@] %3.2f %%", name, progress*100.0f);
//    };
//    [noise performSelector:@selector(startSyncDB) withObject:callback afterDelay:5];
//    //[noise.storage resetMark];
//    // [noise startSyncDB];
//
//    [noise performSelector:@selector(startSyncDB) withObject:callback afterDelay:10];

}


- (void)viewDidAppear:(BOOL)animated{
    
        ESMScheduleManager * esmManager = [[ESMScheduleManager alloc] init];
        if ([esmManager getValidSchedules].count > 0) {
            ESMScrollViewController * esmView  = [[ESMScrollViewController alloc] init];
            [self.navigationController pushViewController:esmView animated:YES];
        }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) testSensingWithStudy:(AWAREStudy *) study dbType:(AwareDBType)dbType sensorManager:(AWARESensorManager *)manager{
    
    Accelerometer * accelerometer = [[Accelerometer alloc] initWithAwareStudy:study dbType:dbType];
    [accelerometer createTable];
    [accelerometer startSensor];
    
    Barometer * barometer = [[Barometer alloc] initWithAwareStudy:study dbType:dbType];
    [barometer startSensor];
    [barometer createTable];

    Bluetooth * bluetooth = [[Bluetooth alloc] initWithAwareStudy:study dbType:dbType];
    [bluetooth createTable];
    [bluetooth startSensor];

    Battery * battery = [[Battery alloc] initWithAwareStudy:study dbType:dbType];
    [battery createTable];
    [battery startSensor];

    Calls * call = [[Calls alloc] initWithAwareStudy:study dbType:dbType];
    [call createTable];
    [call startSensor];

    Gravity * gravity = [[Gravity alloc] initWithAwareStudy:study dbType:dbType];
    [gravity createTable];
    [gravity startSensor];

    Gyroscope * gyroscope = [[Gyroscope alloc] initWithAwareStudy:study dbType:dbType];
    [gyroscope createTable];
    [gyroscope startSensor];

    LinearAccelerometer * linearAccelerometer = [[LinearAccelerometer alloc] initWithAwareStudy:study dbType:dbType];
    [linearAccelerometer createTable];
    [linearAccelerometer startSensor];

    Locations * location = [[Locations alloc] initWithAwareStudy:study dbType:dbType];
    [location createTable];
    [location startSensor];

    Magnetometer * magnetometer = [[Magnetometer alloc] initWithAwareStudy:study dbType:dbType];
    [magnetometer createTable];
    [magnetometer startSensor];

    Network * network = [[Network alloc] initWithAwareStudy:study dbType:dbType];
    [network createTable];
    [network startSensor];

    Orientation * orientation = [[Orientation alloc] initWithAwareStudy:study dbType:dbType];
    [orientation createTable];
    [orientation startSensor];

    Pedometer * pedometer = [[Pedometer alloc] initWithAwareStudy:study dbType:dbType];
    [pedometer createTable];
    [pedometer startSensor];

    Processor * processor = [[Processor alloc] initWithAwareStudy:study dbType:dbType];
    [processor createTable];
    [processor startSensor];

    Proximity * proximity = [[Proximity alloc] initWithAwareStudy:study dbType:dbType];
    [proximity createTable];
    [proximity startSensor];

    Rotation * rotation = [[Rotation alloc] initWithAwareStudy:study dbType:dbType];
    [rotation createTable];
    [rotation startSensor];

    Screen * screen = [[Screen alloc] initWithAwareStudy:study dbType:dbType];
    [screen createTable];
    [screen startSensor];

    Timezone * timezone = [[Timezone alloc] initWithAwareStudy:study dbType:dbType];
    [timezone createTable];
    [timezone startSensor];

    Wifi * wifi = [[Wifi alloc] initWithAwareStudy:study dbType:dbType];
    [wifi createTable];
    [wifi startSensor];
    
    [manager addSensors:@[accelerometer,barometer,battery,bluetooth,call,gravity,gyroscope,linearAccelerometer,location,magnetometer,network,orientation,pedometer,processor,proximity,rotation,screen,timezone,wifi]];
    
    [manager setSensorEventCallbackToAllSensors:^(NSDictionary *data) {
        NSLog(@"%@",data);
    }];
    // [manager addSensor:accelerometer];
    // [manager performSelector:@selector(syncAllSensorsForcefully) withObject:nil afterDelay:10];
    
//    SyncProcessCallBack callback = ^(NSString *name, double progress, NSError * _Nullable error) {
//        NSLog(@"%@ %3.2f",name, progress);
//    };
//
//    [manager setSyncProcessCallbackToAllSensorStorages:callback];
}

- (void) testSQLite{
    
    AWAREDelegate * delegate = (AWAREDelegate *) [UIApplication sharedApplication].delegate;
    AWAREStudy * study = delegate.sharedAWARECore.sharedAwareStudy;
    Accelerometer * accelerometer = [[Accelerometer alloc] initWithAwareStudy:study dbType:AwareDBTypeSQLite];
    [accelerometer.storage setBufferSize:500];
    for (int i =0; i<1000; i++) {
        NSNumber * timestamp = @([NSDate new].timeIntervalSince1970);
        [accelerometer.storage saveDataWithDictionary:@{@"timestamp":timestamp,@"device_id":study.getDeviceId} buffer:YES saveInMainThread:YES];
    }
}


- (void) testESMSchedule{
    
    ESMSchedule * schedule = [[ESMSchedule alloc] init];
    schedule.notificationTitle = @"hello";
    schedule.noitificationBody = @"This is a test notification";
    schedule.fireHours = @[@8,@9,@10,@11,@16,@17,@18,@19,@20,@21,@22,@23,@24,@1];
    schedule.scheduleId = @"id_1";
    schedule.expirationThreshold = @60;
    schedule.startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24];
    schedule.endDate = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24];
    schedule.interface = @1;
    
    /////////////////////////
    ESMItem * text = [[ESMItem alloc] initAsTextESMWithTrigger:@"text"];
     [text setTitle:@"hello world!"];
    
    ESMItem * radio = [[ESMItem alloc] initAsRadioESMWithTrigger:@"radio"
                                                      radioItems:@[@"A",@"B",@"C",@"D",@"E"]];
    [schedule.esms addObject:radio];
    
    ///////////////////////
    ESMItem * checkbox = [[ESMItem alloc] initAsCheckboxESMWithTrigger:@"checkbox"
                                                            checkboxes:@[@"A",@"B",@"C",@"E",@"F"]];
    [schedule.esms addObject:checkbox];
    
    /////////////////////
    ESMItem * likertScale = [[ESMItem alloc] initAsLikertScaleESMWithTrigger:@"likert"
                                                                  likertMax:10
                                                             likertMinLabel:@"min"
                                                             likertMaxLabel:@"max"
                                                                 likertStep:1];
    [schedule.esms addObject:likertScale];
    
    ////////////////////////
    ESMItem * pam = [[ESMItem alloc] initAsPAMESMWithTrigger:@"pam"];
    [schedule.esms addObject:pam];
    
    
    ESMItem * video = [[ESMItem alloc] initAsVideoESMWithTrigger:@"video"];
    [schedule.esms addObject:video];
    
    
    ESMScheduleManager * esmManager = [[ESMScheduleManager alloc] init];
    [esmManager deleteAllSchedules];
    
    [esmManager addSchedule:schedule];
    
    [esmManager setNotificationSchedules];
}



@end
