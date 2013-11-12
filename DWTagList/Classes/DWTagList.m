//
//  DWTagList.m
//
//  Created by Dominic Wroblewski on 07/07/2012.
//  Copyright (c) 2012 Terracoding LTD. All rights reserved.
//

#import "DWTagList.h"
#import <QuartzCore/QuartzCore.h>

#define CORNER_RADIUS 5.0f
#define LABEL_MARGIN_DEFAULT 8.0f
#define BOTTOM_MARGIN_DEFAULT 12.0f
#define FONT_SIZE_DEFAULT 15.0f
#define HORIZONTAL_PADDING_DEFAULT 10.0f
#define VERTICAL_PADDING_DEFAULT 8.0f
#define BACKGROUND_COLOR [UIColor colorWithRed:1 green:1 blue:1 alpha:1.00]
#define TEXT_COLOR [UIColor colorWithRed:254.0/255.0 green:211.0/255.0 blue:48.0/255.0 alpha:1.0]
#define TEXT_SHADOW_COLOR [UIColor whiteColor]
#define TEXT_SHADOW_OFFSET CGSizeMake(0.0f, 1.0f)
#define BORDER_COLOR [UIColor colorWithRed:254.0/255.0 green:211.0/255.0 blue:48.0/255.0 alpha:1.0].CGColor
#define BORDER_WIDTH 1.8f
#define HIGHLIGHTED_BACKGROUND_COLOR [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.5]
#define DEFAULT_AUTOMATIC_RESIZE NO
#define DEFAULT_HORIZONTALLY_CENTERED NO

@interface DWTagList()

- (void)touchedTag:(id)sender;

@end

@implementation DWTagList

@synthesize view, textArray, automaticResize, horizontallyCentered;
@synthesize tagDelegate = _tagDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.automaticResize = DEFAULT_AUTOMATIC_RESIZE;
        self.horizontallyCentered = DEFAULT_HORIZONTALLY_CENTERED;
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:view];
        [self setClipsToBounds:YES];
        self.highlightedBackgroundColor = HIGHLIGHTED_BACKGROUND_COLOR;
        self.font = [UIFont systemFontOfSize:FONT_SIZE_DEFAULT];
        self.labelMargin = LABEL_MARGIN_DEFAULT;
        self.bottomMargin = BOTTOM_MARGIN_DEFAULT;
        self.horizontalPadding = HORIZONTAL_PADDING_DEFAULT;
        self.verticalPadding = VERTICAL_PADDING_DEFAULT;
    }
    return self;
}

- (void)setTags:(NSArray *)array
{
    textArray = [[NSArray alloc] initWithArray:array];
    sizeFit = CGSizeZero;
    if (automaticResize) {
        [self display];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sizeFit.width, sizeFit.height);
    }
    else {
        [self setNeedsLayout];
    }
}

- (void)setTagBackgroundColor:(UIColor *)color
{
    lblBackgroundColor = color;
    [self setNeedsLayout];
}

- (void)setTagHighlightColor:(UIColor *)color
{
    self.highlightedBackgroundColor = color;
    [self setNeedsLayout];
}

- (void)setViewOnly:(BOOL)viewOnly
{
    if (_viewOnly != viewOnly) {
        _viewOnly = viewOnly;
        [self setNeedsLayout];
    }
}

- (void)touchedTag:(id)sender
{
    UITapGestureRecognizer *t = (UITapGestureRecognizer *)sender;
    DWTagView *tagView = (DWTagView *)t.view;
    if(tagView && self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(selectedTag:)])
        [self.tagDelegate selectedTag:tagView.label.text];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self display];
}

- (void)display
{
    NSMutableArray *tagViews = [NSMutableArray array];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[DWTagView class]]) {
            DWTagView *tagView = (DWTagView*)subview;
            for (UIGestureRecognizer *gesture in [subview gestureRecognizers]) {
                [subview removeGestureRecognizer:gesture];
            }
            
            [tagView.button removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            
            [tagViews addObject:subview];
        }
        [subview removeFromSuperview];
    }
    
    CGRect previousFrame = CGRectZero;
    BOOL gotPreviousFrame = NO;
    
    NSMutableArray *allButtonsByLine = [[NSMutableArray alloc] init];
    NSMutableArray *buttonsInLine = [[NSMutableArray alloc] init];
    BOOL isOnNewLine = YES;
    
    for (NSString *text in textArray) {
        DWTagView *tagView;
        if (tagViews.count > 0) {
            tagView = [tagViews lastObject];
            [tagViews removeLastObject];
        }
        else {
            tagView = [[DWTagView alloc] init];
        }
        
        [tagView updateWithString:text
                             font:self.font
               constrainedToWidth:self.frame.size.width - (self.horizontalPadding * 2)
                          padding:CGSizeMake(self.horizontalPadding, self.verticalPadding)
                     minimumWidth:self.minimumWidth
         ];
        
        if (gotPreviousFrame) {
            CGRect newRect = CGRectZero;
            if (previousFrame.origin.x + previousFrame.size.width + tagView.frame.size.width + self.labelMargin > self.frame.size.width) {
                isOnNewLine = YES;
                newRect.origin = CGPointMake(0, previousFrame.origin.y + tagView.frame.size.height + self.bottomMargin);
            } else {
                newRect.origin = CGPointMake(previousFrame.origin.x + previousFrame.size.width + self.labelMargin, previousFrame.origin.y);
            }
            newRect.size = tagView.frame.size;
            [tagView setFrame:newRect];
        }
        
        previousFrame = tagView.frame;
        gotPreviousFrame = YES;
        
        [tagView setBackgroundColor:[self getBackgroundColor]];
        
        // Davide Cenzi, added gesture recognizer to label
        UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchedTag:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [tagView setUserInteractionEnabled:YES];
        [tagView addGestureRecognizer:gesture];
        [self addSubview:tagView];
        
        if (!_viewOnly) {
            [tagView.button addTarget:self action:@selector(touchDownInside:) forControlEvents:UIControlEventTouchDown];
            [tagView.button addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [tagView.button addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
            [tagView.button addTarget:self action:@selector(touchDragInside:) forControlEvents:UIControlEventTouchDragInside];
        }
        
        if (self.horizontallyCentered) {
            if (isOnNewLine) {
                [allButtonsByLine addObject:buttonsInLine];
                buttonsInLine = [[NSMutableArray alloc] initWithObjects:tagView, nil];
                isOnNewLine = NO;
            } else {
                [buttonsInLine addObject:tagView];
            }
        }
    }
    
    if (self.horizontallyCentered) {
        [allButtonsByLine addObject:buttonsInLine];
        
        for (int iterLine = 0; iterLine < allButtonsByLine.count; iterLine++) {
            NSArray *buttons = allButtonsByLine[iterLine];
            for (int i = 0; i < buttons.count; i++) {
                CGFloat leftmostOriginPointX = [buttons[0] frame].origin.x;
                CGFloat rightmostOriginPointX = [buttons[buttons.count - 1] frame].origin.x + [buttons[buttons.count - 1] frame].size.width;
                CGFloat adjustedOffset = leftmostOriginPointX - (self.contentSize.width - (rightmostOriginPointX - leftmostOriginPointX)) / 2;
                for (UIButton *b in buttons) {
                    [b setFrame:CGRectMake(b.frame.origin.x - adjustedOffset, b.frame.origin.y, b.frame.size.width, b.frame.size.height)];
                }
            }
        }
    }
    
    sizeFit = CGSizeMake(self.frame.size.width, previousFrame.origin.y + previousFrame.size.height + self.bottomMargin + 1.0f);
    self.contentSize = sizeFit;
}

- (CGSize)fittedSize
{
    return sizeFit;
}

- (void)touchDownInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:self.highlightedBackgroundColor];
}

- (void)touchUpInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
    if(button && self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(selectedTag:)])
        [self.tagDelegate selectedTag:button.accessibilityLabel];
}

- (void)touchDragExit:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (void)touchDragInside:(id)sender
{
    UIButton *button = (UIButton*)sender;
    [[button superview] setBackgroundColor:[self getBackgroundColor]];
}

- (UIColor *)getBackgroundColor
{
    if (!lblBackgroundColor) {
        return BACKGROUND_COLOR;
    } else {
        return lblBackgroundColor;
    }
}

- (void)dealloc
{
    view = nil;
    textArray = nil;
    lblBackgroundColor = nil;
}

@end


@implementation DWTagView

- (id)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_label setTextColor:TEXT_COLOR];
        [_label setShadowColor:TEXT_SHADOW_COLOR];
        [_label setShadowOffset:TEXT_SHADOW_OFFSET];
        [_label setBackgroundColor:[UIColor clearColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_button setFrame:self.frame];
        [self addSubview:_button];
        
        [_button.layer setMasksToBounds:YES];
        [_button.layer setCornerRadius:CORNER_RADIUS];
        [_button.layer setBorderColor:BORDER_COLOR];
        [_button.layer setBorderWidth: BORDER_WIDTH];
//        [_button.layer setShouldRasterize:YES];
    }
    return self;
}

- (void)updateWithString:(NSString*)text font:(UIFont*)font constrainedToWidth:(CGFloat)maxWidth padding:(CGSize)padding minimumWidth:(CGFloat)minimumWidth
{
    CGSize textSize;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        textSize = [text sizeWithAttributes:@{NSFontAttributeName: font,
                                              NSParagraphStyleAttributeName: paragraphStyle}];
        textSize.width = (textSize.width > maxWidth) ? maxWidth : textSize.width;
    } else {
        textSize = [text sizeWithFont:font forWidth:maxWidth lineBreakMode:NSLineBreakByTruncatingTail];
    }
    
    textSize.width = MAX(textSize.width, minimumWidth);
    textSize.height += padding.height*2;
    
    self.frame = CGRectMake(0, 0, textSize.width+padding.width*2, textSize.height);
    _label.frame = CGRectMake(padding.width, 0, MIN(textSize.width, self.frame.size.width), textSize.height);
    _label.font = font;
    _label.text = text;
    
    [_button setAccessibilityLabel:self.label.text];
}

- (void)setLabelText:(NSString*)text
{
    [_label setText:text];
}

- (void)dealloc
{
    _label = nil;
    _button = nil;
}

@end
