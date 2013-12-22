//
//  GraphView.h
//

#import <UIKit/UIKit.h>

@class DPGraphView;
@protocol DPGraphViewDataSource <NSObject>

- (CGFloat) graphView:(DPGraphView *)graphView yValueForXValue:(CGFloat)x onPlotWithIndex:(NSUInteger)plotIndex;
- (NSUInteger) numberOfPlotsInGraphView:(DPGraphView *)graphView;

@optional

- (UIColor *) graphView:(DPGraphView *)graphView colorForPlotIndex:(NSUInteger)plotIndex;
- (UIColor *) graphViewColorForGrid:(DPGraphView *)graphView;
- (UIColor *) graphViewColorForXAxis:(DPGraphView *)graphView;
- (UIColor *) graphViewColorForYAxis:(DPGraphView *)graphView;

@end

@interface DPGraphView : UIView

@property (nonatomic, weak) id<DPGraphViewDataSource> dataSource;

// Graphing properties
@property (nonatomic) double minX;
@property (nonatomic) double maxX;

@property (nonatomic) double minY;
@property (nonatomic) double maxY;

@property (nonatomic) BOOL displayGridlines;
@property (nonatomic) BOOL dashGridlines;
@property (nonatomic) BOOL displayAxes;


@end
