//
//  YSFrameLayout.m
//  YSLayout
//
//  Created by apple on 15/6/14.
//  Copyright (c) 2015年 欧阳大哥. All rights reserved.
//

#import "YSFrameLayout.h"
#import "YSLayoutInner.h"
#import <objc/runtime.h>


@implementation UIView(YSFrameLayoutExt)


-(YSMarignGravity)marginGravity
{
    return self.ysLayoutSizeClass.marginGravity;
}


-(void)setMarginGravity:(YSMarignGravity)marginGravity
{

    self.ysLayoutSizeClass.marginGravity = marginGravity;
    if (self.superview != nil)
        [self.superview setNeedsLayout];    
}

@end

@implementation YSFrameLayout

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)calcSubView:(UIView*)sbv pRect:(CGRect*)pRect inSize:(CGSize)selfSize
{
    
    YSMarignGravity gravity = sbv.marginGravity;
    YSMarignGravity vert = gravity & YSMarignGravity_Horz_Mask;
    YSMarignGravity horz = gravity & YSMarignGravity_Vert_Mask;
    
     
    //优先用设定的宽度尺寸。
    if (sbv.widthDime.dimeNumVal != nil)
        pRect->size.width = sbv.widthDime.measure;
    
    if (sbv.heightDime.dimeNumVal != nil)
        pRect->size.height = sbv.heightDime.measure;
    
    if (sbv.widthDime.dimeRelaVal != nil && sbv.widthDime.dimeRelaVal.view != sbv)
    {
        if (sbv.widthDime.dimeRelaVal.view == self)
            pRect->size.width = (selfSize.width - self.leftPadding - self.rightPadding) * sbv.widthDime.mutilVal + sbv.widthDime.addVal;
        else
            pRect->size.width = sbv.widthDime.dimeRelaVal.view.estimatedRect.size.width * sbv.widthDime.mutilVal + sbv.widthDime.addVal;
        pRect->size.width = [sbv.widthDime validMeasure:pRect->size.width];
    }
    
    if (sbv.heightDime.dimeRelaVal != nil && sbv.heightDime.dimeRelaVal.view != sbv)
    {
        if (sbv.heightDime.dimeRelaVal.view == self)
            pRect->size.height = (selfSize.height - self.topPadding - self.bottomPadding) * sbv.heightDime.mutilVal + sbv.heightDime.addVal;
        else
            pRect->size.height = sbv.heightDime.dimeRelaVal.view.estimatedRect.size.height * sbv.heightDime.mutilVal + sbv.heightDime.addVal;
        
        pRect->size.height = [sbv.heightDime validMeasure:pRect->size.height];
    }
    
   
    [self horzGravity:horz selfWidth:selfSize.width sbv:sbv rect:pRect];
   
    
    
    if (sbv.isFlexedHeight)
    {
        CGSize sz = [sbv sizeThatFits:CGSizeMake(pRect->size.width, 0)];
        pRect->size.height = [sbv.heightDime validMeasure:sz.height];
    }
    
    [self vertGravity:vert selfHeight:selfSize.height sbv:sbv rect:pRect];
    
    
    if (sbv.widthDime.dimeRelaVal != nil && sbv.widthDime.dimeRelaVal.view == sbv)
    {
        pRect->size.width =  pRect->size.height * sbv.widthDime.mutilVal + sbv.widthDime.addVal;
        pRect->size.width = [sbv.widthDime validMeasure:pRect->size.width];
    }
    
    if (sbv.heightDime.dimeRelaVal != nil && sbv.heightDime.dimeRelaVal.view == sbv)
    {
        pRect->size.height = pRect->size.width * sbv.heightDime.mutilVal + sbv.heightDime.addVal;
        pRect->size.height = [sbv.heightDime validMeasure:pRect->size.height];
        
        if (sbv.isFlexedHeight)
        {
            CGSize sz = [sbv sizeThatFits:CGSizeMake(pRect->size.width, 0)];
            pRect->size.height = [sbv.heightDime validMeasure:sz.height];
        }
    }

    
 
    
}

-(CGRect)calcLayoutRect:(CGSize)size isEstimate:(BOOL)isEstimate pHasSubLayout:(BOOL*)pHasSubLayout
{
    
    CGRect selfRect = [super calcLayoutRect:size isEstimate:isEstimate pHasSubLayout:pHasSubLayout];
    CGSize selfSize = selfRect.size;
    NSArray *sbs = self.subviews;
    for (UIView *sbv in sbs)
    {
        
        if (sbv.useFrame)
            continue;
        
        CGRect rect;
    
        if (!isEstimate)
            rect  = sbv.frame;
        else
        {
            if ([sbv isKindOfClass:[YSLayoutBase class]])
            {
                if (pHasSubLayout != nil)
                    *pHasSubLayout = YES;
                
                YSLayoutBase *sbvl = (YSLayoutBase*)sbv;
                rect = [sbvl estimateLayoutRect:sbvl.absPos.frame.size];
            }
            else
                rect = sbv.absPos.frame;
        }
        
        rect.size.height = [sbv.heightDime validMeasure:rect.size.height];
        rect.size.width  = [sbv.widthDime validMeasure:rect.size.width];
        
        //计算自己的位置和高宽
        [self calcSubView:sbv pRect:&rect inSize:selfSize];
        sbv.absPos.frame = rect;
        
    }
    
    selfRect.size.height = [self.heightDime validMeasure:selfRect.size.height];
    selfRect.size.width = [self.widthDime validMeasure:selfRect.size.width];
    
    
    return selfRect;

}

@end