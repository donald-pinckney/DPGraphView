
#import "DPGraphView.h"

@implementation DPGraphView

#pragma mark -
#pragma mark Coordinate System Conversion
- (CGPoint) viewSpaceCoordinateForCartesianCoordinate:(CGPoint) cartesianCoordinate
{
    CGFloat xPercent = (cartesianCoordinate.x - self.minX) / [self cartesianWidth];
    CGFloat yPercent = (cartesianCoordinate.y - self.minY) / [self cartesianHeight];
    return CGPointMake(self.bounds.origin.x + self.bounds.size.width * xPercent, self.bounds.size.height*(1-yPercent));
}

- (CGFloat) viewSpaceWidthForCatesianWidth:(CGFloat)cartesianWidth
{
    return (self.bounds.size.width / [self cartesianWidth]) * cartesianWidth;
}

- (CGFloat) viewSpaceHeightForCatesianHeight:(CGFloat)cartesianHeight
{
    return (self.bounds.size.height / [self cartesianHeight]) * cartesianHeight;
}

- (CGFloat) cartesianWidthForViewSpaceWidth:(CGFloat)viewSpaceWidth
{
    return ([self cartesianWidth] / self.bounds.size.width) * viewSpaceWidth;
}

- (CGFloat) cartesianHeightForViewSpaceHeight:(CGFloat)viewSpaceHeight
{
    return ([self cartesianHeight] / self.bounds.size.height) * viewSpaceHeight;
}

- (CGFloat) cartesianWidth
{
    return self.maxX - self.minX;
}

- (CGFloat) cartesianHeight
{
    return self.maxY - self.minY;
}

#define OPTIMAL_GRID_SIZE 50.0f // Optimal gridsize in pixels
// Calculates the best gridsize to use... TODO: make it consider other grid widths that just integers
- (CGFloat) optimalCartesianGridWidth
{
    CGFloat cartesianOptimalGridWidth = [self cartesianWidthForViewSpaceWidth:OPTIMAL_GRID_SIZE];
    NSMutableArray *gridlineChoices = [[NSMutableArray alloc] init];
    for (int cartesianGridWidth = 1; cartesianGridWidth < [self cartesianWidth]; cartesianGridWidth++) {
        int numbGrids = [self cartesianWidth] / cartesianGridWidth;
        CGFloat difference = [self cartesianWidth] - numbGrids * cartesianGridWidth;
        
        NSDictionary *gridlineChoice = @{@"cartesianWidth": @(cartesianGridWidth), @"viewWidth": @([self viewSpaceWidthForCatesianWidth:cartesianGridWidth]), @"price" : @(fabs(cartesianOptimalGridWidth - cartesianGridWidth) + difference)};
        [gridlineChoices addObject:gridlineChoice];
    }
    
    [gridlineChoices sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"price"] compare:obj2[@"price"]];
    }];
    
    return [[gridlineChoices firstObject][@"cartesianWidth"] floatValue];
}

- (CGFloat) optimalCartesianGridHeight
{
    CGFloat cartesianOptimalGridHeight = [self cartesianHeightForViewSpaceHeight:OPTIMAL_GRID_SIZE];
    NSMutableArray *gridlineChoices = [[NSMutableArray alloc] init];
    for (int cartesianGridHeight = 1; cartesianGridHeight < [self cartesianHeight]; cartesianGridHeight++) {
        int numGrids = [self cartesianHeight] / cartesianGridHeight;
        CGFloat difference = [self cartesianHeight] - numGrids * cartesianGridHeight;
        
        NSDictionary *gridlineChoice = @{@"cartesianHeight": @(cartesianGridHeight), @"viewHeight": @([self viewSpaceHeightForCatesianHeight:cartesianGridHeight]), @"price" : @(fabs(cartesianOptimalGridHeight - cartesianGridHeight) + difference)};
        [gridlineChoices addObject:gridlineChoice];
    }
    
    [gridlineChoices sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"price"] compare:obj2[@"price"]];
    }];
    
    return [[gridlineChoices firstObject][@"cartesianHeight"] floatValue];
}


#pragma mark -
#pragma mark Draw Rect
- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if(self.displayGridlines) {
        UIColor *gridColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphViewColorForGrid:)]) gridColor = [self.dataSource graphViewColorForGrid:self];
        [gridColor setStroke];
        
        [self drawGridlines];
    }
    
    if(self.displayAxes) {
        // Draw X axis
        UIColor *axisColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphViewColorForXAxis:)]) axisColor = [self.dataSource graphViewColorForXAxis:self];
        [axisColor setStroke];
        [self drawXAxis];
        
        // Draw Y axis
        axisColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphViewColorForYAxis:)]) axisColor = [self.dataSource graphViewColorForYAxis:self];
        [axisColor setStroke];
        
        [self drawYAxis];
    }
    
    NSUInteger numPlots = [self.dataSource numberOfPlotsInGraphView:self];
    for(NSUInteger i = 0; i < numPlots; i++) {
        UIColor *plotColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphView:colorForPlotIndex:)]) plotColor = [self.dataSource graphView:self colorForPlotIndex:i];
        
        [plotColor setStroke];
        [self drawPlotWithIndex:i];
    }
}



#pragma mark -
#pragma mark Drawing Subroutines
- (void) drawGridlines
{
    CGFloat cartesianGridWidth = [self optimalCartesianGridWidth];
    NSLog(@"Cartesian grid width = %f", cartesianGridWidth);
    CGFloat viewGridWidth = [self viewSpaceWidthForCatesianWidth:cartesianGridWidth];
    CGPoint viewSpaceOrigin = [self viewSpaceCoordinateForCartesianCoordinate:CGPointZero];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // Draw x grid (vertical lines)
    if(self.minX <= 0 && 0 <= self.maxX) {
        CGFloat xPos = viewSpaceOrigin.x + viewGridWidth;
        while(xPos < self.bounds.size.width) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, 0)];
            [path addLineToPoint:CGPointMake(xDrawPos, self.bounds.size.height)];
            
            xPos += viewGridWidth;
        }
        
        xPos = viewSpaceOrigin.x - viewGridWidth;
        while(xPos >= 0) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, 0)];
            [path addLineToPoint:CGPointMake(xDrawPos, self.bounds.size.height)];
            
            xPos -= viewGridWidth;
        }
    } else {
        CGFloat xPos = [self viewSpaceCoordinateForCartesianCoordinate:CGPointMake(self.minX, 0)].x;
        while(xPos < self.bounds.size.width) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, 0)];
            [path addLineToPoint:CGPointMake(xDrawPos, self.bounds.size.height)];
            
            xPos += viewGridWidth;
        }
    }
    
    
    CGFloat cartesianGridHeight = [self optimalCartesianGridHeight];
    NSLog(@"Cartesian grid height = %f", cartesianGridHeight);
    CGFloat viewGridHeight = [self viewSpaceHeightForCatesianHeight:cartesianGridHeight];
    
    // Draw y grid (horizontal lines)
    if(self.minY <= 0 && 0 <= self.maxY) {
        CGFloat yPos = viewSpaceOrigin.y + viewGridHeight;
        while(yPos < self.bounds.size.height) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(0, yDrawPos)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, yDrawPos)];
            
            yPos += viewGridHeight;
        }
        
        yPos = viewSpaceOrigin.y - viewGridHeight;
        while(yPos >= 0) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(0, yDrawPos)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, yDrawPos)];
            
            yPos -= viewGridHeight;
        }
    } else {
        CGFloat yPos = [self viewSpaceCoordinateForCartesianCoordinate:CGPointMake(0, self.minY)].y;
        while(yPos >= 0) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(0, yDrawPos)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, yDrawPos)];
            
            yPos -= viewGridHeight;
        }
    }
    
    if(self.dashGridlines) {
        const CGFloat dashes[2] = {8, 6};
        [path setLineDash:dashes count:2 phase:0];
    }
    [path stroke];
}

- (void) drawXAxis
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint viewSpaceOrigin = [self viewSpaceCoordinateForCartesianCoordinate:CGPointZero];
    if(self.minX <= 0 && 0 <= self.maxX) {
        [path moveToPoint:CGPointMake(viewSpaceOrigin.x, 0)];
        [path addLineToPoint:CGPointMake(viewSpaceOrigin.x, self.bounds.size.height)];
    }
    [path stroke];
}

- (void) drawYAxis
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint viewSpaceOrigin = [self viewSpaceCoordinateForCartesianCoordinate:CGPointZero];
    if(self.minY <= 0 && 0 <= self.maxY) {
        [path moveToPoint:CGPointMake(0, viewSpaceOrigin.y)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, viewSpaceOrigin.y)];
    }
    [path stroke];
}

#define GRAPH_RESOLUTION 1.0f // pixels / data point -- UPDATE THIS AT WILL
- (void) drawPlotWithIndex:(NSUInteger)plotIndex
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGPoint firstPoint = CGPointMake(self.minX, [self.dataSource graphView:self yValueForXValue:self.minX onPlotWithIndex:plotIndex]);
    firstPoint = [self viewSpaceCoordinateForCartesianCoordinate:firstPoint];
    [path moveToPoint:firstPoint];
    
    NSUInteger numIterations = self.bounds.size.width / GRAPH_RESOLUTION * [UIScreen mainScreen].scale;
    CGFloat increment = GRAPH_RESOLUTION / self.bounds.size.width * (self.maxX - self.minX);
    for(NSUInteger i = 1; i <= numIterations; i++) {
        CGFloat x = self.minX + i * increment;
        CGFloat y = [self.dataSource graphView:self yValueForXValue:x onPlotWithIndex:plotIndex];
        
        CGPoint point = CGPointMake(x, y);
        point = [self viewSpaceCoordinateForCartesianCoordinate:point];
        
        [path addLineToPoint:point];
    }
    
    path.lineWidth = 2.0f;
    [path stroke];
}



@end
