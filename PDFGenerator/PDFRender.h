//
//  PDFRender.h
//  PDFGenerator
//
//  Created by Pedro Freme on 11/11/14.
//  Copyright (c) 2014 Pedro Freme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface PDFRender : NSObject
/**
 * Cria o nome de arquivo a partir da data de hoje
 * @return nome do arquivo com o path
 */
+(NSString *)createPDFFileName;

/**
 * Inicializa o contexto de desenho do pdf
 */
+(void)initPDFContext;

/**
 * Encerra o contexto de desenho do pdf
 */
+(void)closePDFContext;

/**
 * Insere o texto no lugar indicado
 * @param text texto a ser inserido
 * @param frame frame onde o texto será inserido
 */
+(void)drawText:(NSString *)text inFrame:(CGRect)frame;

/**
 * Desenha todas as labels que foram inseridas na XIB
 */
+(void)drawStaticLabels;

/**
 * Desenha a celula dinamica cujo com conteudo específico alterando o texto
 * @param content conteudo da label na XIB
 * @param text texto a ser desenhado
 */
+(void)drawDynamicLabelWithContent:(NSString*)content theText:(NSString *)text;

+(void)drawTableForObjets:(NSArray*)objects;

+(void)drawImages;

@end
