//
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import HealthKit;

#import "CupHistoryViewController.h"
#import "SteepController.h"



@interface CupHistoryViewController ()
@property NSArray *history;
@end

@implementation CupHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [[SteepController sharedSteepController] queryHistoryWithCompletion:^(HKQuantityType *quantityType, NSArray *results, NSError *error) {
        self.history = results;
        [self.tableView reloadData];
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.history.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];


    HKQuantitySample *quantitySample = self.history[indexPath.row];
    HKQuantity *quantity = quantitySample.quantity;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0fmg", [quantity doubleValueForUnit:[HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli]]];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        #warning Need to delete the cup from HealthKit here!
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // rows are created while using the app, not manually
    }   
}

@end
