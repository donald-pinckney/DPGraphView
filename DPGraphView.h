//
//  GraphView.h
//  Puff
//
//  Created by Donald Pinckney on 12/21/13.
//  Copyright (c) 2013 Davis App Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPGraphView;
@protocol DPGraphViewDataSource <NSObject>

- (CGFloat) graphView:(DPGraphView *)graphView yValueForXValue:(CGFloat)x onPlotWithIndex:(NSUInteger)plotIndex;
- (NSUInteger) numberOfPlotsInGraphView:(DPGraphView *)graphView;

@optional

- (UIColor *) graphView:(DPGraphView *)graphView colorForPlotIndex:(NSUInteger)plotIndex;

@end

@interface DPGraphView : UIView

@property (nonatomic, weak) id<DPGraphViewDataSource> dataSource;

@property (nonatomic) double minX;
@property (nonatomic) double maxX;

@property (nonatomic) double minY;
@property (nonatomic) double maxY;


@end
