//
//  PDFRender.m
//  PDFGenerator
//
//  Created by Pedro Freme on 11/11/14.
//  Copyright (c) 2014 Pedro Freme. All rights reserved.
//

#import "PDFRender.h"

#define PADDING 10
#define CELL_HEIGHT 30

typedef NS_ENUM(NSInteger, labelType){
    HiddenLabel = 0,
    StaticLabel,
    DynamicLabel,
    TableLabel,
    FirstCollumn
};

@implementation PDFRender

+(NSString *)createPDFFileName{
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormater = [NSDateFormatter new];
    
    [dateFormater setDateFormat:@"dd_MM_YY"];
    
    NSString *fileName = [NSString stringWithFormat:@"Romaneio_%@.pdf",[dateFormater stringFromDate:now]];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];;
    
    NSString *pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    return pdfFileName;
}

+(void)initPDFContext{
    
    NSString *filePath = [self createPDFFileName];
    UIView *pdfView = [[[NSBundle mainBundle]loadNibNamed:@"PDFView" owner:nil options:nil] firstObject];
    
    //Inicio do contexo to PDF
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    //Cria uma pagina com o tamanho da XIB
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pdfView.frame.size.width, pdfView.frame.size.height), nil);
}

+(void)closePDFContext{
    
    UIGraphicsEndPDFContext();
}

+(void)drawText:(NSString *)text inFrame:(CGRect)frame{
    
    CFStringRef stringRef = (__bridge CFStringRef)text;
    
    //Prepara o texto com um CoreText framesetter
    CFAttributedStringRef currentText = CFAttributedStringCreate(nil, stringRef, nil);
    CTFramesetterRef framessetter = CTFramesetterCreateWithAttributedString(currentText);
    
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, nil, frame);
    
    //Acha o frame em que será renderizado
    CFRange currentRange = CFRangeMake(0, 0);
    CTFrameRef frameRef = CTFramesetterCreateFrame(framessetter, currentRange, framePath, nil);
    CGPathRelease(framePath);
    
    //Pega o contexto
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing
    CGContextTranslateCTM(currentContext, 0, frame.origin.y*2);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    CTFrameDraw(frameRef, currentContext);
    
    //Desfas as alteraçoes para que nao tenhamos problemas em renderizar varias linhas
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextTranslateCTM(currentContext, 0, (-1)*frame.origin.y*2);
    
    CFRelease(frameRef);
    CFRelease(stringRef);
    CFRelease(framessetter);
}

+(void)drawStaticLabels{

    UIView *pdfView = [[[NSBundle mainBundle]loadNibNamed:@"PDFView" owner:nil options:nil] firstObject];
    
    for (UILabel *label in [pdfView subviews]) {
        
        if (label.tag == StaticLabel) {
        [self drawText:label.text inFrame:label.frame];
        }
    }
    
}

+(void)drawDynamicLabelWithContent:(NSString*)content theText:(NSString *)text{

    UIView *pdfView = [[[NSBundle mainBundle]loadNibNamed:@"PDFView" owner:nil options:nil] firstObject];
    
    for (UILabel *label in [pdfView subviews]) {
        if (label.tag == DynamicLabel) {
            if ([label.text isEqualToString:content]) {
                [self drawText:text inFrame:label.frame];
            }
        }
    }
    
}

+(void)drawTableForObjets:(NSArray*)objects{

    UIView *pdfView = [[[NSBundle mainBundle]loadNibNamed:@"PDFView" owner:nil options:nil] firstObject];
    
    CGPoint firstLineOrigin = CGPointZero;
    CGPoint tableOrigin;
    CGPoint tableEnd;
    CGPoint endPage = CGPointMake(pdfView.frame.size.width, pdfView.frame.size.height);
    CGPoint linesOrigin;
    
    NSMutableArray *columnsOrigins = [NSMutableArray new];

    for(UILabel *label in [pdfView subviews]){
        
        switch (label.tag) {
            case FirstCollumn:
                tableOrigin = CGPointMake(label.frame.origin.x - PADDING, label.frame.origin.y - label.frame.size.height - PADDING);
                tableEnd = [self draw:objects.count horizontalLinesFromPoint:tableOrigin toEndPage: endPage];
                firstLineOrigin = label.frame.origin;
            
            case TableLabel:
                
                [self drawText:label.text inFrame:label.frame];
                
                [self drawVerticalLineFromPoint:label.frame.origin toEndTable:tableEnd];
                
                [columnsOrigins addObject:[NSValue valueWithCGPoint: label.frame.origin]];
                
                break;
                
            default:
                break;
        }
    }
    linesOrigin = firstLineOrigin;
    firstLineOrigin.x = endPage.x;
    [self drawVerticalLineFromPoint:firstLineOrigin toEndTable:tableEnd];

    [columnsOrigins sortUsingComparator: ^NSComparisonResult(id obj1, id obj2){
        CGPoint firstPoint = [obj1 CGPointValue];
        CGPoint secondPoint = [obj2 CGPointValue];
        if(firstPoint.x > secondPoint.x){
            return (NSComparisonResult)NSOrderedDescending;
        }
        if(firstPoint.x < secondPoint.x){
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    
    int line = 0;
    for(NSArray *object in objects){
        int column = 0;
        for (NSString *text in object) {
            UILabel *label = [[UILabel alloc]init];
            [label setText:text];
            [label sizeToFit];
            
            CGPoint textOrigin = [[columnsOrigins objectAtIndex:column] CGPointValue];
            
            //CGFloat textX = [[columnsOrigins objectAtIndex:column] x];
        
            [label setFrame:CGRectMake(textOrigin.x, linesOrigin.y+CELL_HEIGHT + line*CELL_HEIGHT, label.frame.size.width, label.frame.size.height)];
            
            [self drawText:label.text inFrame:label.frame];
            column++;
        }
        line++;
    }
}

+(void)drawVerticalLineFromPoint: (CGPoint)point toEndTable: (CGPoint)endTable{

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components[] = {0.5, 0.5, 0.5, 0.5};
    
    CGColorRef color = CGColorCreate(colorspace, components);
    
    CGContextSetStrokeColorWithColor(context, color);
    
    CGContextMoveToPoint(context, point.x-PADDING, point.y-CELL_HEIGHT);
    CGContextAddLineToPoint(context, point.x-PADDING, endTable.y);
    
    CGContextStrokePath(context);
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

+(CGPoint)draw: (NSInteger)lines horizontalLinesFromPoint: (CGPoint)point toEndPage: (CGPoint)endPage{
   
    CGPoint endTable;
    
    for (int line=0; line<=lines+1; line++){
    
        CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGContextSetLineWidth(context, 2.0);
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
        CGFloat components[] = {0.5, 0.5, 0.5, 0.5};
    
        CGColorRef color = CGColorCreate(colorspace, components);
    
        CGContextSetStrokeColorWithColor(context, color);
    
        CGContextMoveToPoint(context, point.x, line*CELL_HEIGHT+point.y);
        CGContextAddLineToPoint(context, endPage.x-PADDING, line*CELL_HEIGHT+point.y);
    
        CGContextStrokePath(context);
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);
    
        endTable = CGPointMake(point.x, line*CELL_HEIGHT+point.y);
    }
    
    return endTable;
}
//-(void)showPDFFile{
//    
//    NSString *fileNamePath = [self createPDFFileName];
//    /Users/pedrofreme/Documents/Projects/Apps2/PDFGenerator/PDFGenerator/PDFGenerator/PDFRender.m
//    UIWebView *webView = [[UIWebView alloc]initWithFrame: self.view.frame];
//    
//    NSURL *url = [NSURL fileURLWithPath:fileNamePath];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    [webView setScalesPageToFit:YES];
//    [webView loadRequest:request];
//    
//    [self.view addSubview:webView];
//}

+(void)drawImage:(UIImage *)image inRect: (CGRect) frame{

    [image drawInRect:frame];
    
}

+(void)drawImages{

    UIView *pdfView = [[[NSBundle mainBundle]loadNibNamed:@"PDFView" owner:nil options:nil] firstObject];
    
    for(UIView *imageView in [pdfView subviews]){
        if ([imageView isKindOfClass:[UIImageView class]]) {
        
        [self drawImage:((UIImageView*)imageView).image inRect:imageView.frame];
        }
    }
}


+(void)concatenate{

    NSString *fileName = [NSString stringWithFormat:@"Concatenado"];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];;
    
    NSString *pdfFileName = [path stringByAppendingPathComponent:fileName];
    
    
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    UIGraphicsBeginPDFPage();
    
    
    
    
}

@end
