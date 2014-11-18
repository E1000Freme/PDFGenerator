//
//  PDFGenViewController.m
//  PDFGenerator
//
//  Created by Pedro Freme on 11/10/14.
//  Copyright (c) 2014 Pedro Freme. All rights reserved.
//

#import "PDFGenViewController.h"
#import "PDFRender.h"

@interface PDFGenViewController ()

@end

@implementation PDFGenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *objects1 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects2 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects3 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects4 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects5 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects6 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects7 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects8 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects9 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects0 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects11 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *objects12 = @[@"objeto1", @"objeto1", @"objeto1"];
    NSArray *allObjects = @[objects1, objects2, objects3, objects4, objects5, objects6, objects7, objects8, objects9, objects0, objects11, objects12];
    // Do any additional setup after loading the view.
    [PDFRender initPDFContext];
    [PDFRender drawStaticLabels];
    [PDFRender drawDynamicLabelWithContent:@"data" theText:@"Wololo"];
    [PDFRender drawDynamicLabelWithContent:@"nome" theText:@"Wolala"];
    [PDFRender drawImages];
    [PDFRender drawTableForObjets:allObjects];
    [PDFRender closePDFContext];
    [self showPDFFile];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showPDFFile{

    NSString *fileNamePath = [PDFRender createPDFFileName];

    UIWebView *webView = [[UIWebView alloc]initWithFrame: self.view.frame];

    NSURL *url = [NSURL fileURLWithPath:fileNamePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSLog(@"%@", url);

    [webView setScalesPageToFit:YES];
    [webView loadRequest:request];

    [self.view addSubview:webView];
}

@end
