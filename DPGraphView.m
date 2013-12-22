
#import "DPGraphView.h"

@implementation DPGraphView

#pragma mark -
#pragma mark Coordinate System Conversion
- (CGPoint) viewSpaceCoordinateForCartesianCoordinate:(CGPoint) cartesianCoordinate
{
    CGFloat xPercent = (cartesianCoordinate.x - self.minX) / (self.maxX - self.minX);
    CGFloat yPercent = (cartesianCoordinate.y - self.minY) / (self.maxY - self.minY);
    return CGPointMake(self.bounds.origin.x + self.bounds.size.width * xPercent, self.bounds.size.height*(1-yPercent));
}

#pragma mark -
#pragma mark Draw Rect
- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSUInteger numPlots = [self.dataSource numberOfPlotsInGraphView:self];
    for(NSUInteger i = 0; i < numPlots; i++) {
        UIColor *plotColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphView:colorForPlotIndex:)]) plotColor = [self.dataSource graphView:self colorForPlotIndex:i];
        
        [plotColor setStroke];
        [self drawPlotWithIndex:i];
    }
}


#define GRAPH_RESOLUTION 0.5f // pixels / data point

#pragma mark -
#pragma mark Drawing Subroutines
- (void) drawPlotWithIndex:(NSUInteger)plotIndex
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGPoint firstPoint = CGPointMake(self.minX, [self.dataSource graphView:self yValueForXValue:self.minX onPlotWithIndex:plotIndex]);
    firstPoint = [self viewSpaceCoordinateForCartesianCoordinate:firstPoint];
    [path moveToPoint:firstPoint];
    
    NSUInteger numIterations = self.bounds.size.width / GRAPH_RESOLUTION * [UIScreen mainScreen].scale;
    NSLog(@"Rendering with numIterations = %d", numIterations);
    CGFloat increment = GRAPH_RESOLUTION / self.bounds.size.width * (self.maxX - self.minX);
    for(NSUInteger i = 1; i <= numIterations; i++) {
        CGFloat x = self.minX + i * increment;
        CGFloat y = [self.dataSource graphView:self yValueForXValue:x onPlotWithIndex:plotIndex];
        
        CGPoint point = CGPointMake(x, y);
        point = [self viewSpaceCoordinateForCartesianCoordinate:point];
        
        [path addLineToPoint:point];
    }
    
    [path stroke];
}



@end
