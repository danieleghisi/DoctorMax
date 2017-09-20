//
//  TableController.m
//  DoctorMax
//
//  Created by Daniele Ghisi on 14/01/16.
//
//

#import "TableController.h"
#import "DoctorMaxAppDelegate.h"

@implementation TableController



#pragma mark - Custom Initialisers

- (NSMutableArray *)names {
    
    if (!_names) {
        _names = [[NSMutableArray alloc] init];
        [_names addObject:[NSString stringWithFormat:@"fooname"]];
//        _names = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10"];
    }
    return _names;
}

- (NSMutableArray *)realnames {
    
    if (!_realnames) {
        _realnames = [[NSMutableArray alloc] init];
        [_realnames addObject:[NSString stringWithFormat:@"foorealname"]];
//        _realnames = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
    }
    return _realnames;
}

- (NSMutableArray *)csources {
    
    if (!_csources) {
        _csources = [[NSMutableArray alloc] init];
        [_csources addObject:[NSString stringWithFormat:@"foosource"]];
        //        _realnames = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
    }
    return _csources;
}

- (NSMutableArray *)types {
    if (!_types) {
        _types = [[NSMutableArray alloc] init];
        [_types addObject:[NSString stringWithFormat:@"footype"]];
        //        _realnames = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
    }
    return _types;
}

- (NSMutableArray *)digests {
    if (!_digests) {
        _digests = [[NSMutableArray alloc] init];
        [_digests addObject:[NSString stringWithFormat:@"foodigest"]];
        //        _realnames = @[@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten"];
    }
    return _digests;
}

- (void)FillAll {
    // real save part
    DoctorMaxAppDelegate *appDelegate = (DoctorMaxAppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate application:[NSApplication sharedApplication] saveFile:tvarFilename];
    
}


#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    // how many rows do we have here?
    return self.names.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // populate each row of our table view with data
    // display a different value depending on each column (as identified in XIB)
    
    if ([tableColumn.identifier isEqualToString:@"names"]) {
        return [self.names objectAtIndex:row];
    } else if ([tableColumn.identifier isEqualToString:@"realnames"]) {
            return [self.realnames objectAtIndex:row];
    } else if ([tableColumn.identifier isEqualToString:@"csources"]) {
        return [self.csources objectAtIndex:row];
    } else if ([tableColumn.identifier isEqualToString:@"types"]) {
        return [self.types objectAtIndex:row];
    } else {
        return [self.digests objectAtIndex:row];
    }
}

#pragma mark - Table View Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
    NSTableView *tableView = notification.object;
    NSLog(@"User has selected row %ld", (long)tableView.selectedRow);
}


@end
