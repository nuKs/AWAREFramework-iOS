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
#import <AWAREFramework/CalendarESMScheduler.h>

@interface AWAREFrameworkViewController ()

@end

@implementation AWAREFrameworkViewController{
    NSTimer * timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AWAREDelegate * delegate = (AWAREDelegate *) [UIApplication sharedApplication].delegate;
    AWARECore * core = delegate.sharedAWARECore;
    [core requestBackgroundSensing];
    [core requestNotification:[UIApplication sharedApplication]];
    
//    Accelerometer * acc = [[Accelerometer alloc] init];
//    acc.threshold = 1.0;
//    // [acc setDebug:YES];
//    [acc setSensorEventHandler:^(AWARESensor *sensor, NSDictionary *data) {
//        NSLog(@"%@", data);
//    }];
//    [acc startSensor];
    // [acc.storage setDebug:YES];
    
//    CalendarESMScheduler * calScheduler = [[CalendarESMScheduler alloc] init];
//    [calScheduler setDebug:YES];
//    [calScheduler startSensor];

    Screen * screen = [[Screen alloc] init];
    [screen startSensor];
    
    core.sharedESMManager.debug = YES;
    [core.sharedESMManager removeAllNotifications];
    [core.sharedESMManager removeAllSchedulesFromDB];
    [core.sharedESMManager removeAllESMHitoryFromDB];

    ESMSchedule * schdule = [[ESMSchedule alloc] init];
    // [schdule setContexts:@[ACTION_AWARE_SCREEN_LOCKED]];
    [schdule setFireHours:@[@22,@23]];
     [schdule setExpirationThreshold:@60];
    
//    ESMItem * item = [[ESMItem alloc] initAsQuickAnawerESMWithTrigger:@"quick" quickAnswers:@[@"A",@"B"]];
//    [item setTitle:@"Which is your best?"];
//
//    ESMItem * itemA = [[ESMItem alloc] initAsNumericESMWithTrigger:@"num"];
//    [itemA setTitle:@"hello"];
//
//    ESMItem * itemB = [[ESMItem alloc] initAsAudioESMWithTrigger:@"audio"];
//    [itemB setTitle:@"hello2"];
//
//    [item setFlowWithItems:@[itemA, itemB] answerKey:@[@"A",@"B"]];
    ESMItem * item = [[ESMItem alloc] initAsAudioESMWithTrigger:@"trigger"];
    [schdule addESM:item];
    [core.sharedESMManager addSchedule:schdule];
    
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:ACTION_AWARE_SCREEN_UNLOCKED
//                                                            object:nil
//                                                          userInfo:nil];
//        NSLog(@"timer is called");
//    }];

    
//    [self testESMSchedule];
//    Bluetooth * bluetooth = [[Bluetooth alloc] init];
//    [bluetooth setDebug:YES];
//    [bluetooth setScanInterval:60];
//    [bluetooth setScanDuration:30];
//    [bluetooth startSensor];
//
//    [core.sharedSensorManager addSensor:bluetooth];
}


- (void) sendContextBasedESMNotification:(id)sender {
    NSLog(@"%@",sender);
}

- (void) setNotifWithHour:(int)hour min:(int)min sec:(int)sec title:(NSString *)title notifId:(NSString *)notifId {
    NSCalendar * cal = [NSCalendar currentCalendar];
    NSDateComponents * componetns = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate new]];
    componetns.hour = hour;
    componetns.minute = min;
    componetns.second = sec;
    UNNotificationTrigger * notificationTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:componetns repeats:NO];
    
    NSLog(@"[CalendarESMScheduler] Set ESM Notification at %ld:%ld",(long)componetns.hour, (long)componetns.minute);
    
    UNMutableNotificationContent * notificationContent = [[UNMutableNotificationContent alloc] init];
    notificationContent.title = @"Hello 1";
    notificationContent.badge = @1;
    notificationContent.sound = [UNNotificationSound defaultSound];
    notificationContent.categoryIdentifier = PLUGIN_CALENDAR_ESM_SCHEDULER_NOTIFICATION_CATEGORY;
    
    // NOTE: Notification ID should use an unified ID
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:notifId content:notificationContent trigger:notificationTrigger];
    
    UNUserNotificationCenter * notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error!=nil) {
            NSLog(@"%@",error.debugDescription);
        }
    }];
}

- (void) calendarESMTest {
    AWAREDelegate * delegate = (AWAREDelegate *) [UIApplication sharedApplication].delegate;
    AWARECore * core = delegate.sharedAWARECore;
    [core requestBackgroundSensing];
    [core requestNotification:[UIApplication sharedApplication]];
}

- (void) testCSVStorageWithStudy:(AWAREStudy * )study{
    Battery * battery = [[Battery alloc] initWithAwareStudy:study dbType:AwareDBTypeCSV];
    [battery setIntervalSecond:1];
    [battery startSensor];
//    [battery setSensorEventCallBack:^(NSDictionary *data) {
//        NSLog(@"%@",data.debugDescription);
//    }];
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
    [noise setDebug:YES];

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
    [super viewDidAppear:animated];
    ESMScheduleManager * esmManager = [[ESMScheduleManager alloc] init];
    NSArray * schdules = [esmManager getValidSchedules];
    if (schdules.count > 0) {
        // UIColor *customColor = [UIColor colorWithRed:0.1 green:0.5 blue:0.3 alpha:1.0];
        ESMScrollViewController * esmView  = [[ESMScrollViewController alloc] init];
        // esmView.view.backgroundColor = customColor;
        [self presentViewController:esmView animated:YES completion:^{
            \
        }];
        /** or, following code if your project using Navigation Controller */
        // [self.navigationController pushViewController:esmView animated:YES];
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
    
//    [manager setSensorEventCallbackToAllSensors:^(NSDictionary *data) {
//        NSLog(@"%@",data);
//    }];
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
    schedule.notificationTitle = @"title";
    schedule.notificationBody = @"body";
    schedule.scheduleId = @"id";
    schedule.expirationThreshold = @60;
    schedule.startDate = [[NSDate alloc] initWithTimeIntervalSinceNow:-60*60*24*10];
    schedule.endDate = [[NSDate alloc] initWithTimeIntervalSinceNow:60*60*24*10];
    // schedule.interface = @1;
    for (int i=8; i<24; i++){
        [schedule addHour:@(i)];
    }
    
    /////////////////////////
    ESMItem * text = [[ESMItem alloc] initAsTextESMWithTrigger:@"text"];
    [text setTitle:@"Freetext"];
    [text setInstructions:@"Open-ended text input"];
    
    ESMItem * radio = [[ESMItem alloc] initAsRadioESMWithTrigger:@"radio"
                                                      radioItems:@[@"A",@"B",@"C",@"D",@"E"]];
    [radio setTitle:@"Radio"];
    [radio setInstructions:@"Single choice is allowed"];
    
    ESMItem * checkbox = [[ESMItem alloc] initAsCheckboxESMWithTrigger:@"checkbox"
                                                            checkboxes:@[@"A",@"B",@"C",@"E",@"Other"]];
    [checkbox setTitle:@"Checkbox"];
    [checkbox setInstructions:@"Multiple choice is allowed"];
    
    ESMItem * likertScale = [[ESMItem alloc] initAsLikertScaleESMWithTrigger:@"4_likert"
                                                                  likertMax:10
                                                             likertMinLabel:@"min"
                                                             likertMaxLabel:@"max"
                                                                 likertStep:1];
    [likertScale setTitle:@"Likert"];
    [likertScale setInstructions:@"Likert ESM"];
    
    
    ESMItem * quickAnswer = [[ESMItem alloc] initAsQuickAnawerESMWithTrigger:@"quick" quickAnswers:@[@"A",@"B",@"C"]];
    [quickAnswer setTitle:@"Quick Answers ESM"];
    
    
    ESMItem * scale = [[ESMItem alloc] initAsScaleESMWithTrigger:@"scalse"
                                                        scaleMin:0
                                                        scaleMax:100
                                                      scaleStart:50
                                                   scaleMinLabel:@"Poor"
                                                   scaleMaxLabel:@"Perfect"
                                                       scaleStep:10];
    [scale setTitle:@"Scale"];
    [scale setInstructions:@"Scale ESM"];
    
    ESMItem * datetime = [[ESMItem alloc] initAsDateTimeESMWithTrigger:@"datetime"];
    [datetime setTitle:@"Date Time"];
    [datetime setInstructions:@"Date and Time ESM"];

    ESMItem * pam = [[ESMItem alloc] initAsPAMESMWithTrigger:@"pam"];
    
    ESMItem * numeric = [[ESMItem alloc] initAsNumericESMWithTrigger:@"number"];
    [numeric setTitle:@"Numeric"];
    [numeric setInstructions:@"The user can enter a number"];

    ESMItem * web = [[ESMItem alloc] initAsWebESMWithTrigger:@"web" url:@"https://google.com"];
    [web setTitle:@"Web"];
    [web setInstructions:@"Web ESM"];
    
    ESMItem * date = [[ESMItem alloc] initAsDatePickerESMWithTrigger:@"date"];
    [date setTitle:@"Date"];
    [date setInstructions:@"Date ESM"];
    
    ESMItem * time = [[ESMItem alloc] initAsTimePickerESMWithTrigger:@"time"];
    [time setTitle:@"Time"];
    [time setInstructions:@"Time ESM"];

    ESMItem * clock = [[ESMItem alloc] initAsClockDatePickerESMWithTrigger:@"clock"];
    [clock setTitle:@"Clock"];
    [clock setInstructions:@"Clock ESM"];
    
    ESMItem * picture = [[ESMItem alloc] initAsPictureESMWithTrigger:@"picture"];
    [picture setTitle:@"Picture"];
    [picture setInstructions:@"Picture ESM"];
    
    ESMItem * audio = [[ESMItem alloc] initAsAudioESMWithTrigger:@"audio"];
    [audio setTitle:@"Audio"];
    [audio setInstructions:@"Audio ESM"];
    
    ESMItem * video = [[ESMItem alloc] initAsVideoESMWithTrigger:@"5_video"];
    
    [schedule addESMs:@[text,radio,checkbox,likertScale,quickAnswer, scale, datetime, pam, numeric, web, date, time, clock, picture, audio, video]];
    
    
    ESMScheduleManager * esmManager = [[ESMScheduleManager alloc] init];
    esmManager.debug = YES;
    [esmManager addSchedule:schedule];
    
//    if ([esmManager getValidSchedules].count > 0) {
//        ESMScrollViewController * esmView  = [[ESMScrollViewController alloc] init];
//        [self.navigationController pushViewController:esmView animated:YES];
//    }
    
}



@end
