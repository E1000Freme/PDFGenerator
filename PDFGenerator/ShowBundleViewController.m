//
//  ShowBundleViewController.m
//  PDFGenerator
//
//  Created by Pedro Freme on 11/13/14.
//  Copyright (c) 2014 Pedro Freme. All rights reserved.
//

#import "ShowBundleViewController.h"

@interface ShowBundleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ShowBundleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES];
    
    NSLog(@"%@", self.tableView);
    
    self.fileManager = [NSFileManager defaultManager];
    //[[NSBundle mainBundle] bundlePath];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *URLPath = [NSURL fileURLWithPath:path];
    
    NSError *error;
    
    self.contents = [self.fileManager contentsOfDirectoryAtURL:URLPath includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];


}

-(void)viewWillAppear:(BOOL)animated{
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contents.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"wololo" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.fileManager displayNameAtPath:[self.contents objectAtIndex:indexPath.row]];
    return cell;
    
}

- (IBAction)concatenate:(id)sender {
    
//    NSArray *selected = [self.tableView indexPathsForSelectedRows];
//    
//    for (int i=0; i<selected.count; i++) {
//        NSLog(@"%d", i%2);
//        
//    }
    [self.imageView setBackgroundColor:[UIColor colorWithRed:arc4random() green:arc4random() blue:arc4random() alpha:arc4random()]];
    
    [self.imageView setImage:[UIImage imageWithContentsOfFile:[self.fileManager displayNameAtPath:[self.contents firstObject]]]];

    
}


@end
