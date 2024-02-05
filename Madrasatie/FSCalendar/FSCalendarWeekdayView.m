//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarWeekdayView.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.backgroundColor = [UIColor whiteColor];
        weekdayLabel.clipsToBounds = YES;
        //        weekdayLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        //        weekdayLabel.layer.shadowRadius = 3;
        //        weekdayLabel.layer.shadowOffset = CGSizeMake(1, 1);
        //        weekdayLabel.layer.shadowOpacity = 0.2;
        
        UIView * view = [[UIView alloc] initWithFrame:CGRectZero];
        
        [view addSubview:weekdayLabel];
        [self.contentView addSubview:view];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(weekdayLabel)];
        
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    // Position Calculation
    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat)*count;
    CGFloat *widths = malloc(size);
    CGFloat contentWidth = self.contentView.fs_width;
    FSCalendarSliceCake(contentWidth, count, widths);
    
    CGFloat x = 0;
    for (NSInteger i = 0; i < count; i++) {
        CGFloat width = widths[i];
        UILabel *label = [self.weekdayPointers pointerAtIndex:i];
        CGFloat padding = 8;
        label.superview.frame = CGRectMake(x, 0, width, self.contentView.fs_height + 8);
        label.frame = CGRectMake(padding / 2, 0, width - padding, width - padding);
        label.layer.cornerRadius = (width - padding) / 2;
        x += width;
        
    }
    free(widths);
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (NSArray<UILabel *> *)weekdayLabels
{
    return self.weekdayPointers.allObjects;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    for (NSInteger i = 0; i < self.weekdayPointers.count; i++) {
        NSInteger index = (i + self.calendar.firstWeekday-1) % 7;
        UILabel *label = [self.weekdayPointers pointerAtIndex:i];
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
        
        NSCalendar* cal = [NSCalendar currentCalendar];
        NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        if ([comp weekday] == i + 2) {
            label.backgroundColor = [UIColor whiteColor];
            label.superview.layer.masksToBounds = false;
            label.superview.layer.shadowColor = UIColor.blackColor.CGColor;
            label.superview.layer.shadowOpacity = 0.2;
            label.superview.layer.shadowOffset = CGSizeMake(1, 2);
            label.superview.layer.shadowRadius = 1;
        }
        else {
            label.backgroundColor = [UIColor clearColor];
        }
    }
    
}

@end

