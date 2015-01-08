//
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import AudioToolbox;

#import "MakeTeaViewController.h"



@interface MakeTeaViewController () {
    UITapGestureRecognizer *tapper;
    IASKAppSettingsViewController *appSettingsViewController;
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender;
-(IBAction)showSettings:(id)sender;
- (void)settingDidChange:(NSNotification*)notification;


@property (nonatomic, strong, readonly) IASKAppSettingsViewController *appSettingsViewController;

@property IBOutlet UITableView *configurationView;
@property IBOutlet UIPickerView *teaType;

@property IBOutlet UITextField *cupSizeField;
@property IBOutlet UITextField *waterTemperatureField;
@property IBOutlet UITextField *steepTimeField;
@property IBOutlet UITextField *caffeineField;

@property IBOutlet UISwitch *caffeineSwitch;

@property IBOutlet UIButton *makeTeaButton;

@property NSNumber *cupOunces;
@property NSNumber *waterTemp;
@property NSNumber *caffeine;
@property NSNumber *steepTimeMinutes;
@property enum TeaType selectedTeaType;
@end

@implementation MakeTeaViewController
@dynamic appSettingsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[SteepController sharedSteepController] setControllerDelegate:self];

    NSNumberFormatter *volumeFormatter = [[NSNumberFormatter alloc] init];
    [volumeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    volumeFormatter.positiveSuffix = @"oz";

    NSNumberFormatter *temperatureFormatter = [[NSNumberFormatter alloc] init];
    [temperatureFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    temperatureFormatter.positiveSuffix = @"℉";

    NSNumberFormatter *weightFormatter = [[NSNumberFormatter alloc] init];
    [weightFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    weightFormatter.positiveSuffix = @"mg";

    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    [self configureCupForTeaType:[self.teaType selectedRowInComponent:0]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}



-(void)viewDidAppear:(BOOL)animated {
    if ([[SteepController sharedSteepController] isHealthDataAvailable]) {
        [[SteepController sharedSteepController] ensureAuth];
    }
    else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
            NSString *warningMessage = [NSString stringWithFormat:@"HealthKit is not currently available on your device. \r\n\r\nAs a result, %@ will not be able to save caffeine consumption or other data in HealthKit for you.", appName];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:warningMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                //
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:^{
                //
            }];
        });


    }

}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
    appSettingsViewController = nil;
}

#pragma mark - Tap Recognizer

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


#pragma mark - Settings

- (IASKAppSettingsViewController*)appSettingsViewController {
    if (!appSettingsViewController) {
        appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
        appSettingsViewController.delegate = self;
    }
    return appSettingsViewController;
}


-(void)showSettings:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    aNavController.navigationBar.barStyle = UIBarStyleBlack;
    [self.appSettingsViewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

- (void)settingDidChange:(NSNotification*)notification {

}

#pragma mark IASKAppSettingsViewControllerDelegate protocol

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    // your code here to reconfigure the app for changed settings
}

#pragma mark
#pragma mark SteepControllerDelegate

-(void)delegateShouldDisplayError:(NSString *)title withMessage:(NSString *)message {
    //NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
}





#pragma mark 
#pragma mark Internal configuration

-(NSString *)nameForTeaType:(enum TeaType)type {
    NSString *teaName = nil;

    switch (type) {
        case TeaTypeWhite:
            teaName = @"White";
            break;
        case TeaTypeGreen:
            teaName = @"Green";
            break;
        case TeaTypeBlack:
            teaName = @"Black";
            break;
        case TeaTypeOolong:
            teaName = @"Oolong";
            break;
        case TeaTypeRooibos:
            teaName = @"Rooibos";
            break;
        case TeaTypeHerbal:
            teaName = @"Herbal";
            break;
        default:
            break;
    }
    return teaName;
}

-(NSDecimalNumber *)averageCaffeinePerOunceForTeaType:(enum TeaType)type {
    NSDecimalNumber *averageCaffeine;

    switch (type) {
        case TeaTypeWhite:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(40.0/8.0) decimalValue]];
            break;
        case TeaTypeGreen:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(40.0/8.0) decimalValue]];
            break;
        case TeaTypeBlack:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(70.0/8.0) decimalValue]];
            break;
        case TeaTypeOolong:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(40.0/8.0) decimalValue]];
            break;
        case TeaTypeRooibos:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(0.0) decimalValue]];
            break;
        case TeaTypeHerbal:
            averageCaffeine = [NSDecimalNumber decimalNumberWithDecimal:[@(0.0) decimalValue]];
            break;
        default:
            break;
    }
    return averageCaffeine;
}

-(NSNumber *)waterTemperatureForTeaType:(enum TeaType)type {
    NSNumber *waterTemperature;

    switch (type) {
        case TeaTypeWhite:
            waterTemperature = @(170);
            break;
        case TeaTypeGreen:
            waterTemperature = @(170);
            break;
        case TeaTypeBlack:
            waterTemperature = @(212);
            break;
        case TeaTypeOolong:
            waterTemperature = @(180);
            break;
        case TeaTypeRooibos:
            waterTemperature = @(212);
            break;
        case TeaTypeHerbal:
            waterTemperature = @(212);
            break;
        default:
            break;
    }
    return waterTemperature;
}

-(NSNumber *)steepTimeForTeaType:(enum TeaType)type {
    NSNumber *steepTimeMinutes;

    switch (type) {
        case TeaTypeWhite:
            steepTimeMinutes = @(2);
            break;
        case TeaTypeGreen:
            steepTimeMinutes = @(2);
            break;
        case TeaTypeBlack:
            steepTimeMinutes = @(5);
            break;
        case TeaTypeOolong:
            steepTimeMinutes = @(3);
            break;
        case TeaTypeRooibos:
            steepTimeMinutes = @(3);
            break;
        case TeaTypeHerbal:
            steepTimeMinutes = @(5);
            break;
        default:
            break;
    }
    return steepTimeMinutes;
}

-(void)configureCupForTeaType:(enum TeaType)type {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    NSDecimalNumber *averageCaffeine = [self averageCaffeinePerOunceForTeaType:type];

    NSNumber *waterTemperatureForTeaType = [self waterTemperatureForTeaType:type];

    NSNumber *steepTimeForTeaType = [self steepTimeForTeaType:type];

    NSNumber *localcupOunces = [formatter numberFromString:self.cupSizeField.text];
    NSNumber *localwaterTemp = [formatter numberFromString:self.waterTemperatureField.text];
    NSNumber *localcaffeine = [formatter numberFromString:self.caffeineField.text];
    NSNumber *localSteepTime = [formatter numberFromString:self.steepTimeField.text];

    if (localSteepTime) {
        self.steepTimeMinutes = localSteepTime;
    }
    else {
        self.steepTimeMinutes = steepTimeForTeaType;
        self.steepTimeField.text = @"";
        self.steepTimeField.placeholder = [NSString stringWithFormat:@"%@ min", self.steepTimeMinutes];
    }

    if (localcupOunces) {
        self.cupOunces = localcupOunces;
    }
    else {
        self.cupOunces = @(8);
        self.cupSizeField.text = @"";
    }

    if (localwaterTemp) {
        self.waterTemp = localwaterTemp;
    }
    else {
        self.waterTemp = waterTemperatureForTeaType;
        self.waterTemperatureField.text = @"";
        self.waterTemperatureField.placeholder = [NSString stringWithFormat:@"%@℉", self.waterTemp];
    }

    if (localcaffeine) {
        self.caffeine = localcaffeine;
        self.caffeineField.text = [NSString stringWithFormat:@"%@", self.caffeine];
    }
    else if (localcupOunces) {
        self.caffeine = [averageCaffeine decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[localcupOunces decimalValue]]];
        self.caffeineField.text = @"";
        self.caffeineField.placeholder = [NSString stringWithFormat:@"%@mg", self.caffeine];
    }
    else {
        self.caffeine = [averageCaffeine decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithDecimal:[self.cupOunces decimalValue]]];
        self.caffeineField.text = @"";
        self.caffeineField.placeholder = [NSString stringWithFormat:@"%@mg", self.caffeine];
    }


    NSLog(@"Configure for %@ ounces, %@F, %@mg caffeine, steep time %@", self.cupOunces, self.waterTemp, self.caffeine, self.steepTimeMinutes);
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TeaTimerSegue"]) {
        TimerViewController *teaTimerViewController = [segue destinationViewController];
        [[SteepController sharedSteepController] setTimerDelegate:teaTimerViewController];
        [[SteepController sharedSteepController] startSteepTimerForMinutes:self.steepTimeMinutes];
    }
}





#pragma mark
#pragma mark SteepControllerDelegate actions

-(void)steepDidFinish:(id)sender {
    [[SteepController sharedSteepController] addCupWithSize:self.cupOunces temperature:self.waterTemp caffeine:self.caffeine type:[self.teaType selectedRowInComponent:0] recordCaffeineToHealthkit:self.caffeineSwitch.isOn];

    [self dismissViewControllerAnimated:YES completion:^{
        if ([[SteepController sharedSteepController] isBackgrounded]) {
            UILocalNotification *steepFinishedNotification = [[UILocalNotification alloc] init];
            steepFinishedNotification.alertBody = @"Tea finished";
            steepFinishedNotification.soundName = UILocalNotificationDefaultSoundName;
            NSLog(@"Local sound name: %@", UILocalNotificationDefaultSoundName);
            //steepFinishedNotification.applicationIconBadgeNumber = 1;
            [[UIApplication sharedApplication] scheduleLocalNotification:steepFinishedNotification];
        }
        else {
            AudioServicesPlayAlertSound(1009);
            [self displayAlert:@"" withMessage:@"Tea finished"];
        }
    }];

}


-(void)displayAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
}


#pragma mark
#pragma mark SteepController actions





#pragma mark
#pragma mark UIPickerViewDelegate


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self nameForTeaType:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self configureCupForTeaType:row];
    [self.view endEditing:YES];
}





#pragma mark
#pragma mark UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 6;
}





#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber* resultingNumber = [numberFormatter numberFromString:resultString];
    return resultingNumber != nil || string.length == 0;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self configureCupForTeaType:[self.teaType selectedRowInComponent:0]];
}

-(void)textFieldDidChange:(id)sender {
    [self configureCupForTeaType:[self.teaType selectedRowInComponent:0]];
}

@end
