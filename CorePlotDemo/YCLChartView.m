//
//  YCLChartView.m
//  CorePlotDemo
//
//  Created by YCLZONE on 2/1/16.
//  Copyright © 2016 YCLZONE. All rights reserved.
//

#import "YCLChartView.h"
#import <CorePlot/ios/CorePlot-CocoaTouch.h>
#import <Masonry.h>
#import <HYDateTools.h>

static NSInteger const MINUTES_ONE_HOUR         = 60;
static NSInteger const MINUTES_ONE_HALF_HOUR    = MINUTES_ONE_HOUR*0.5;
static NSInteger const MINUTES_ONE_DAY          = MINUTES_ONE_HOUR*24;
static NSInteger const MINUTES_ONE_QUARTER      = 15;

static NSString * const CPDTickerSymbolAAPL = @"Plot";

@interface YCLChartView ()<CPTPlotDataSource, CPTPlotSpaceDelegate, CPTAxisDelegate>
/** hostingView */
@property (nonatomic, strong) CPTGraphHostingView *hostingView;
@end

@implementation YCLChartView

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    [self confgitChartView];
//}


- (void)awakeFromNib {
    [self confgitChartView];
}


- (void)confgitChartView {
    [self configureHostingView];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHostingView {
    self.backgroundColor = [UIColor blackColor];
    
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] init];
    hostingView.allowPinchScaling = YES;
    hostingView.backgroundColor = [UIColor blueColor];
    self.hostingView = hostingView;
    [self addSubview:self.hostingView];
    [self.hostingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
}

-(void)configureGraph {
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostingView.bounds];
//    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostingView.hostedGraph = graph;
    
    // 2 - Set graph title
    graph.title = @"This is title";
    
    // 3 - Create and set text style
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 0.0f);
    graph.fill = [CPTFill fillWithColor:[[CPTColor grayColor] colorWithAlphaComponent:1]];
    
    graph.paddingTop    = 10;
    graph.paddingLeft   = 20;
    graph.paddingBottom = 30;
    graph.paddingRight  = 40;
    
    // 4 - Set padding for plot area
    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;
    plotAreaFrame.paddingTop    = 30;
    plotAreaFrame.paddingLeft   = 50;
    plotAreaFrame.paddingBottom = 50;
    plotAreaFrame.paddingRight  = 30;
    plotAreaFrame.fill = [CPTFill fillWithColor:[[CPTColor blackColor] colorWithAlphaComponent:0.5]];
    
    
    CPTPlotArea *plotArea = plotAreaFrame.plotArea;
    plotArea.fill = [CPTFill fillWithColor:[[CPTColor redColor] colorWithAlphaComponent:0.2]];
    
    // 5 - Enable user interactions for plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
}

-(void)configurePlots {
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostingView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the plot
    CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
    aaplPlot.dataSource = self;
    aaplPlot.identifier = CPDTickerSymbolAAPL;
    CPTColor *aaplColor = [CPTColor blackColor];
    
    aaplPlot.interpolation = CPTScatterPlotInterpolationCurved;
    [graph addPlot:aaplPlot toPlotSpace:plotSpace];

    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:@[aaplPlot]];
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(MINUTES_ONE_DAY)];
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(MINUTES_ONE_DAY)];
    
    [plotSpace scaleToFitPlots:@[aaplPlot]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];

    [xRange expandRangeByFactor:@1.3];

    plotSpace.xRange = xRange;

    
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:@32.0 length:@10];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@32.0 length:@10];
    
    // 4 - Create styles and symbols
    CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
    aaplLineStyle.lineWidth = 1.0;
    aaplLineStyle.lineColor = aaplColor;
    aaplPlot.dataLineStyle = aaplLineStyle;
    
//    CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    aaplSymbolLineStyle.lineColor = aaplColor;
//    CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
//    aaplSymbol.lineStyle = aaplSymbolLineStyle;
//    aaplSymbol.size = CGSizeMake(6.0f, 6.0f);
//    aaplPlot.plotSymbol = aaplSymbol;
}

-(void)configureAxes {
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    gridLineStyle.lineColor = [CPTColor blackColor];
    gridLineStyle.lineWidth = 1.0f;
    
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostingView.hostedGraph.axisSet;
    
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.labelTextStyle = axisTextStyle;
    x.orthogonalPosition = @32;
    
    x.tickDirection = CPTSignNegative;
    
    x.majorTickLineStyle = tickLineStyle;
    x.majorTickLength = 4.0f;
    x.majorIntervalLength = @(MINUTES_ONE_HOUR*3);
    
//    x.majorGridLineStyle = gridLineStyle;
    
    x.minorTicksPerInterval = 0;
    x.minorTickLength = 2;
    x.minorTickLineStyle = tickLineStyle;
//    x.minorGridLineStyle = gridLineStyle;
    x.identifier = @"x";
    x.delegate = self;
    
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];//固定坐标轴
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"HH:mm";
    
//    NSNumberFormatter *xLabelFormater = [[NSNumberFormatter alloc] init];
//    xLabelFormater.maximumFractionDigits = 0;
    
//    x.labelFormatter = dateFormater;
    
//    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
//    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
//    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
//    NSInteger i = 0;
//    for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
//        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
//        CGFloat location = i++;
//        label.tickLocation = @(location);
//        label.offset = x.majorTickLength;
//        if (label) {
//            [xLabels addObject:label];
//            [xLocations addObject:[NSNumber numberWithFloat:location]];
//        }
//    }
//    x.axisLabels = xLabels;
//    x.majorTickLocations = xLocations;
    
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;
    y.title = @"Price";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = 30.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 5;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignNegative;
    y.orthogonalPosition = @0;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:0];
    
    NSNumberFormatter *yLabelFormater = [[NSNumberFormatter alloc] init];
    yLabelFormater.maximumFractionDigits = 0;
    
    y.labelFormatter = yLabelFormater;
    
//    NSInteger majorIncrement = 100;
//    NSInteger minorIncrement = 50;
//    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
//    NSMutableSet *yLabels = [NSMutableSet set];
//    NSMutableSet *yMajorLocations = [NSMutableSet set];
//    NSMutableSet *yMinorLocations = [NSMutableSet set];
//    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
//        NSUInteger mod = j % majorIncrement;
//        if (mod == 0) {
//            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
//            NSDecimal location = CPTDecimalFromInteger(j);
//            label.tickLocation = location;
//            label.offset = -y.majorTickLength - y.labelOffset;
//            if (label) {
//                [yLabels addObject:label];
//            }
//            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
//        } else {
//            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
//        }
//    }
//    y.axisLabels = yLabels;    
//    y.majorTickLocations = yMajorLocations;
//    y.minorTickLocations = yMinorLocations; 
}

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    NSMutableSet * newLabels        = [NSMutableSet set];
    for (NSDecimalNumber * tickLocation in locations) {
        
        NSString * labelString;
        if([axis.identifier isEqual:@"x"]){
            NSDate *date = [NSDate date];
            NSInteger time = [NSDate hy_timeintervalFromDate:date type:HYTimeintervalTypeUpToDay];
            NSInteger aTime = tickLocation.integerValue*60 + time;
            labelString = [NSString hy_stringFromTimeinterval:aTime withFormat:@"HH:mm"];
        }
        
        CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:[axis.labelTextStyle mutableCopy]];
        CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
        newLabel.tickLocation       = @(tickLocation.floatValue) ;
        newLabel.offset             = axis.labelOffset;
        
        [newLabels addObject:newLabel];
    }
    
    axis.axisLabels = newLabels;
    
    return NO;
}

#pragma mark - CPTPlotDataSource
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return 100;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSNumber *num = nil;
    
    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index);
            break;
            
        case CPTScatterPlotFieldY:
            num = @(arc4random()%10+32);
            break;
            
        default:
            break;
    }
    
    return num;
}

#pragma mark - CPTPlotSpaceDelegate
- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate {
    if (coordinate == CPTCoordinateY) {
        return [CPTPlotRange plotRangeWithLocation:@(32) length:@(10)];;
    } else {
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)space.graph.axisSet;
        CPTXYAxis *xAxis = axisSet.xAxis;
        
        if (newRange.lengthDouble >= MINUTES_ONE_HOUR*24) { // 24个点，间隔1小时
            xAxis.majorIntervalLength = @(MINUTES_ONE_HOUR*3);
            xAxis.minorTicksPerInterval = 0;
        } else if (newRange.lengthDouble >= MINUTES_ONE_HOUR*12) { //24个点，间隔半小时
            xAxis.majorIntervalLength = @(MINUTES_ONE_HALF_HOUR*3);
            xAxis.minorTicksPerInterval = 1;
        } else if (newRange.lengthDouble >= MINUTES_ONE_HOUR*6) { // 24个点，间隔1刻钟
            xAxis.majorIntervalLength = @(MINUTES_ONE_QUARTER*3);
            xAxis.minorTicksPerInterval = 0;
        } else if (newRange.lengthDouble > MINUTES_ONE_HOUR*4) {  // 24个点，间隔10分钟
            xAxis.majorIntervalLength = @(10*3);
            xAxis.minorTicksPerInterval = 0;
        } else if (newRange.lengthDouble > MINUTES_ONE_HOUR*2) { // 24个点，间隔5分钟
            xAxis.majorIntervalLength = @(5*3);
            xAxis.minorTicksPerInterval = 0;
        } else if (newRange.lengthDouble > MINUTES_ONE_HOUR*1) { // 20个点，间隔3分钟
            xAxis.majorIntervalLength = @(3*3);
            xAxis.minorTicksPerInterval = 2;
        } else if (newRange.lengthDouble > MINUTES_ONE_QUARTER*2) {// 15个点，间隔1分钟
            xAxis.majorIntervalLength = @(1*3);
            xAxis.minorTicksPerInterval = 2;
        }
        
//        NSLog(@"%@ - %@", newRange.location, newRange.length);
        
        return newRange;
    }
}

@end
