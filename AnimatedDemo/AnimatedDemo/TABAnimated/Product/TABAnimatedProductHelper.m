//
//  TABAnimatedProductHelper.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2020/4/5.
//  Copyright © 2020 tigerAndBull. All rights reserved.
//

#import "TABAnimatedProductHelper.h"
#import "TABComponentLayer.h"
#import "TABAnimatedProduction.h"
#import "UIView+TABAnimatedProduction.h"

static NSString * const kShortDataString = @"tab_testtesttest";
static NSString * const kLongDataString = @"tab_testtesttesttesttesttesttesttesttesttesttest";
static NSString * const kTagDefaultFontName = @"HiraKakuProN-W3";

static const CGFloat kTagDefaultFontSize = 12.f;
static const CGFloat kTagLabelHeight = 20.f;

@implementation TABAnimatedProductHelper

+ (void)fullData:(UIView *)view {
    
    if ([view isKindOfClass:[UITableView class]] ||
        [view isKindOfClass:[UICollectionView class]]) {
        return;
    }
    
    NSArray *subViews = [view subviews];
    if ([subViews count] == 0) {
        return;
    }
    
    for (int i = 0; i < subViews.count;i++) {
        
        UIView *subV = subViews[i];
        [self fullData:subV];
        
        if ([subV isKindOfClass:[UITableView class]] ||
            [subV isKindOfClass:[UICollectionView class]]) {
            continue;
        }
        
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)subV;
            if (lab.text == nil || [lab.text isEqualToString:@""]) {
                if (lab.numberOfLines == 1) {
                    lab.text = kShortDataString;
                }else {
                    lab.text = kLongDataString;
                }
            }
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subV;
            if (btn.titleLabel.text == nil && btn.imageView.image == nil) {
                [btn setTitle:kShortDataString forState:UIControlStateNormal];
            }
        }
    }
}

+ (void)fullDataAndStartNestAnimation:(UIView *)view {
    
    if ([view isKindOfClass:[UITableView class]] ||
        [view isKindOfClass:[UICollectionView class]]) {
        return;
    }
    
    NSArray *subViews = [view subviews];
    if ([subViews count] == 0) {
        return;
    }
    
    for (int i = 0; i < subViews.count;i++) {
        
        UIView *subV = subViews[i];
        [self fullDataAndStartNestAnimation:subV];
        
        if ([subV isKindOfClass:[UITableView class]] ||
            [subV isKindOfClass:[UICollectionView class]]) {
            continue;
        }
        
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)subV;
            if (lab.text == nil || [lab.text isEqualToString:@""]) {
                if (lab.numberOfLines == 1) {
                    lab.text = kShortDataString;
                }else {
                    lab.text = kLongDataString;
                }
            }
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subV;
            if (btn.titleLabel.text == nil && btn.imageView.image == nil) {
                [btn setTitle:kShortDataString forState:UIControlStateNormal];
            }
        }
    }
}

+ (void)resetData:(UIView *)view {
    
    if ([view isKindOfClass:[UITableView class]] ||
        [view isKindOfClass:[UICollectionView class]]) {
        return;
    }
    
    NSArray *subViews = [view subviews];
    for (int i = 0; i < subViews.count;i++) {
        
        UIView *subV = subViews[i];
        [self resetData:subV];
        
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *lab = (UILabel *)subV;
            if ([lab.text isEqualToString:kLongDataString] ||
                [lab.text isEqualToString:kShortDataString]) {
                lab.text = @"";
            }
        }else if ([subV isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subV;
            if ([btn.titleLabel.text isEqualToString:kLongDataString] ||
                [btn.titleLabel.text isEqualToString:kShortDataString]) {
                [btn setTitle:@"" forState:UIControlStateNormal];
            }
        }
    }
}

+ (void)hiddenSubViews:(UIView *)view {
    if ([view isKindOfClass:[UITableView class]] ||
        [view isKindOfClass:[UICollectionView class]]) {
        return;
    }
    NSArray *subViews = [view subviews];
    for (int i = 0; i < subViews.count;i++) {
        UIView *subV = subViews[i];
        [self resetData:subV];
        subV.hidden = YES;
    }
}

+ (BOOL)canProduct:(UIView *)view {
    
    if ([view isKindOfClass:[UICollectionView class]] || [view isKindOfClass:[UITableView class]]) {
        // 判断view为tableview/collectionview时，若有设置骨架动画，则返回NO；否则返回YES，允许设置绘制骨架图
        if (view.tabAnimated) {
            return NO;
        }else {
            return YES;
        }
    }
    
    // 将UIButton中的UILabel移除动画队列
    if ([view.superview isKindOfClass:[UIButton class]]) {
        return NO;
    }
    
    if ([view isKindOfClass:[UIButton class]]) {
        // UIButtonLabel has one subLayer.
        if (view.layer.sublayers.count >= 1) {
            return YES;
        }else {
            return NO;
        }
    }else if (view.layer.sublayers.count == 0) {
        return YES;
    }else if ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIImageView class]]) {
        return YES;
    }
    return NO;
}

+ (void)bindView:(UIView *)view production:(TABAnimatedProduction *)production {
    if (production.backgroundLayer.frame.size.height == 0. &&
        view.layer.bounds.size.height > 0.) {
        production.backgroundLayer.frame = view.layer.bounds;
    }
    [view.layer addSublayer:production.backgroundLayer];
    for (NSInteger i = 0; i < production.layers.count; i++) {
        TABComponentLayer *layer = production.layers[i];
        [production.backgroundLayer addLayer:layer viewWidth:view.frame.size.width];
    }
    production.state = TABAnimatedProductionBind;
    view.tabAnimatedProduction = production;
}

+ (TABComponentLayer *)getBackgroundLayerWithView:(UIView *)view
                                      controlView:(UIView *)controlView {
    TABViewAnimated *tabAnimated = controlView.tabAnimated;
    UIColor *animatedBackgroundColor = [tabAnimated getCurrentAnimatedBackgroundColorWithCollection:controlView.traitCollection];

    TABComponentLayer *backgroundLayer = TABComponentLayer.new;
    if (tabAnimated.animatedBackViewCornerRadius > 0) {
        backgroundLayer.cornerRadius = tabAnimated.animatedBackViewCornerRadius;
    }else if (view.layer.cornerRadius > 0.) {
        backgroundLayer.cornerRadius = view.layer.cornerRadius;
    }else if ([view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *cell = (UITableViewCell *)view;
        if (cell.contentView.layer.cornerRadius > 0.) {
            backgroundLayer.cornerRadius = cell.contentView.layer.cornerRadius;
        }
    }else if ([view isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)view;
        if (cell.contentView.layer.cornerRadius > 0.) {
            backgroundLayer.cornerRadius = cell.contentView.layer.cornerRadius;
        }
    }
    
    if ([view isKindOfClass:[UITableViewCell class]]) {
        
        UITableViewCell *cell = (UITableViewCell *)view;
        TABComponentLayer *layer;
        if ((layer = [TABAnimatedProductHelper getShadowLayer:cell]) != nil) {
            [backgroundLayer addSublayer:layer];
        }else if ((layer = [TABAnimatedProductHelper getShadowLayer:cell.contentView]) != nil) {
            [backgroundLayer addSublayer:layer];
        }
        
        UITableView *tableView = (UITableView *)controlView;
        if (view.frame.size.width != [UIScreen mainScreen].bounds.size.width) {
            backgroundLayer.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, tableView.rowHeight);
        }else {
            backgroundLayer.frame = view.bounds;
        }
        
    }else if ([view isKindOfClass:[UICollectionViewCell class]]) {
        UICollectionViewCell *cell = (UICollectionViewCell *)view;
        TABComponentLayer *layer;
        if ((layer = [TABAnimatedProductHelper getShadowLayer:cell]) != nil) {
            [backgroundLayer addSublayer:layer];
        }else if ((layer = [TABAnimatedProductHelper getShadowLayer:cell.contentView]) != nil) {
            [backgroundLayer addSublayer:layer];
        }
        backgroundLayer.frame = view.bounds;
    }else {
        TABComponentLayer *layer;
        if ((layer = [TABAnimatedProductHelper getShadowLayer:view]) != nil) {
            layer.opacity = 1.;
            [backgroundLayer addSublayer:layer];
        }
        backgroundLayer.frame = view.bounds;
    }
    
    if (view.frame.size.width == 0.) {
        backgroundLayer.frame = CGRectMake(view.bounds.origin.x, view.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, view.bounds.size.height);
    }
    
    backgroundLayer.backgroundColor = animatedBackgroundColor.CGColor;
    return backgroundLayer;
}

+ (TABComponentLayer *)getShadowLayer:(UIView *)view {
    if (view.layer.shadowOpacity != 0.) {
        TABComponentLayer *layer = TABComponentLayer.new;
        layer.frame = view.layer.frame;
        layer.cornerRadius = view.layer.cornerRadius;
        layer.backgroundColor = view.layer.backgroundColor;
        layer.shadowColor = view.layer.shadowColor;
        layer.shadowOffset = view.layer.shadowOffset;
        layer.shadowRadius = view.layer.shadowRadius;
        layer.shadowPath = view.layer.shadowPath;
        layer.shadowOpacity = view.layer.shadowOpacity;
        layer.opacity = 0.;
        return layer;
    }
    return nil;
}

+ (void)addTagWithComponentLayer:(TABComponentLayer *)layer isLines:(BOOL)isLines {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = [NSString stringWithFormat:@"%ld",(long)layer.tagIndex];
    if (isLines) {
        textLayer.frame = CGRectMake(0, 0, layer.frame.size.width, kTagLabelHeight);
    }else if (layer.origin != TABComponentLayerOriginImageView) {
        textLayer.bounds = CGRectMake(layer.bounds.origin.x, layer.bounds.origin.y, layer.bounds.size.width, kTagLabelHeight);
    }else {
        textLayer.frame = CGRectMake(0, layer.frame.size.height/2.0, layer.frame.size.width, kTagLabelHeight);
    }
    textLayer.contentsScale = ([[UIScreen mainScreen] scale] > 3.0) ? [[UIScreen mainScreen] scale]:3.0;
    textLayer.font = (__bridge CFTypeRef)(kTagDefaultFontName);
    textLayer.fontSize = kTagDefaultFontSize;
    textLayer.alignmentMode = kCAAlignmentRight;
    textLayer.foregroundColor = [UIColor redColor].CGColor;
    [layer addSublayer:textLayer];
}

+ (NSString *)getKeyWithControllerName:(NSString *)controllerName targetClass:(Class)targetClass {
    NSString *classString = NSStringFromClass(targetClass);
    if ([classString containsString:@"."]) {
        NSRange range = [classString rangeOfString:@"."];
        classString = [classString substringFromIndex:range.location+1];
    }
    return [NSString stringWithFormat:@"%@_%@",controllerName, classString];
}

+ (NSString *)getClassNameWithTargetClass:(Class)targetClass {
    NSString *className = NSStringFromClass(targetClass.class);
    if ([className containsString:@"."]) {
        NSRange range = [className rangeOfString:@"."];
        className = [className substringFromIndex:range.location+1];
    }
    return className;
}

@end
