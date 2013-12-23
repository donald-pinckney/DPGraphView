
#import "DPGraphView.h"

@interface DPGraphView ()
@property (nonatomic) CGFloat leftGraphInset;
@property (nonatomic) CGFloat rightGraphInset;
@property (nonatomic) CGFloat topGraphInset;
@property (nonatomic) CGFloat bottomGraphInset;
@end

@implementation DPGraphView

#pragma mark - Helper Methods
- (NSDictionary *) axesLabelsAttributes
{
    UIColor *labelColor = [UIColor blackColor];
    if([self.dataSource respondsToSelector:@selector(colorForAxesLabelsInGraphView:)]) labelColor = [self.dataSource colorForAxesLabelsInGraphView:self];
    UIFont *labelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : labelColor};
}

#pragma mark -
#pragma mark Coordinate System Conversion
- (CGPoint) viewSpaceCoordinateForCartesianCoordinate:(CGPoint) cartesianCoordinate
{
    CGFloat xPercent = (cartesianCoordinate.x - self.minX) / [self cartesianWidth];
    CGFloat yPercent = (cartesianCoordinate.y - self.minY) / [self cartesianHeight];
    return CGPointMake([self graphBounds].origin.x + [self graphBounds].size.width * xPercent, [self graphBounds].origin.y + [self graphBounds].size.height*(1-yPercent));
}

- (CGFloat) viewSpaceWidthForCatesianWidth:(CGFloat)cartesianWidth
{
    return ([self graphBounds].size.width / [self cartesianWidth]) * cartesianWidth;
}

- (CGFloat) viewSpaceHeightForCatesianHeight:(CGFloat)cartesianHeight
{
    return ([self graphBounds].size.height / [self cartesianHeight]) * cartesianHeight;
}

- (CGFloat) cartesianWidthForViewSpaceWidth:(CGFloat)viewSpaceWidth
{
    return ([self cartesianWidth] / [self graphBounds].size.width) * viewSpaceWidth;
}

- (CGFloat) cartesianHeightForViewSpaceHeight:(CGFloat)viewSpaceHeight
{
    return ([self cartesianHeight] / [self graphBounds].size.height) * viewSpaceHeight;
}

- (CGFloat) cartesianWidth
{
    return self.maxX - self.minX;
}

- (CGFloat) cartesianHeight
{
    return self.maxY - self.minY;
}

- (CGRect) graphBounds
{
    return CGRectMake(self.leftGraphInset, self.topGraphInset, self.bounds.size.width - self.leftGraphInset - self.rightGraphInset, self.bounds.size.height - self.topGraphInset - self.bottomGraphInset);
}

#define OPTIMAL_GRID_SIZE 80.0f // Optimal gridsize in pixels
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
        
        float price = fabs(cartesianOptimalGridHeight - cartesianGridHeight) + difference;
        
        NSDictionary *gridlineChoice = @{@"cartesianHeight": @(cartesianGridHeight), @"viewHeight": @([self viewSpaceHeightForCatesianHeight:cartesianGridHeight]), @"price" : @(price)};
        [gridlineChoices addObject:gridlineChoice];
    }
    
    [gridlineChoices sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1[@"price"] compare:obj2[@"price"]];
    }];
    
    return [[gridlineChoices firstObject][@"cartesianHeight"] floatValue];
}

#pragma mark -
#pragma mark DRAWING CONFIGURATION OPTIONS
#define GRAPH_RESOLUTION 1.0f // pixels / data point -- UPDATE THIS AT WILL
#define AXIS_LABEL_TO_BORDER_SPACE 5.0f
#define Y_BORDER_EXTRA_INSET 20.0f // Provide extra "saftey" padding on the Y border for varying text sizes

#pragma mark -
#pragma mark Draw Rect
- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Calculate insets based on labels
    if(self.displayAsBoxedPlot) {
        CGSize xlabelSize = [[self.dataSource XAxisLabelInGraphView:self] sizeWithAttributes:[self axesLabelsAttributes]];
        self.bottomGraphInset = xlabelSize.height + AXIS_LABEL_TO_BORDER_SPACE;
        
        CGSize ylabelSize = [[self.dataSource YAxisLabelInGraphView:self] sizeWithAttributes:[self axesLabelsAttributes]];
        self.leftGraphInset = ylabelSize.width + AXIS_LABEL_TO_BORDER_SPACE + Y_BORDER_EXTRA_INSET;
    }
    
    // Draw gridlines
    if(self.displayGridlines) {
        UIColor *gridColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(colorForGridInGraphView:)]) gridColor = [self.dataSource colorForGridInGraphView:self];
        [gridColor setStroke];
        
        [self drawGridlines];
    }
    
    // Draw axes
    if(self.displayAxes && !self.displayAsBoxedPlot) {
        // Draw X axis
        UIColor *axisColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(colorForXAxisInGraphView:)]) axisColor = [self.dataSource colorForXAxisInGraphView:self];
        [axisColor setStroke];
        [self drawXAxis];
        
        // Draw Y axis
        axisColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(colorForYAxisInGraphView:)]) axisColor = [self.dataSource colorForYAxisInGraphView:self];
        [axisColor setStroke];
        
        [self drawYAxis];
    }
    
    // Draw box
    if(self.displayAsBoxedPlot) {
        UIColor *axisColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(colorForXAxisInGraphView:)]) axisColor = [self.dataSource colorForXAxisInGraphView:self];
        [axisColor setStroke];
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:[self graphBounds]];
        path.lineWidth = 2.0;
        [path stroke];
    }
    
    
    // Draw plots
    NSUInteger numPlots = [self.dataSource numberOfPlotsInGraphView:self];
    for(NSUInteger i = 0; i < numPlots; i++) {
        UIColor *plotColor = [UIColor blackColor];
        if([self.dataSource respondsToSelector:@selector(graphView:colorForPlotIndex:)]) plotColor = [self.dataSource graphView:self colorForPlotIndex:i];
        
        [plotColor setStroke];
        [self drawPlotWithIndex:i];
    }
    
    // Draw axes labels
    [self drawAxesLabels];
}



#pragma mark -
#pragma mark Drawing Subroutines
- (void) drawGridlines
{
    CGFloat cartesianGridWidth = [self optimalCartesianGridWidth];
    CGFloat viewGridWidth = [self viewSpaceWidthForCatesianWidth:cartesianGridWidth];
    CGPoint viewSpaceOrigin = [self viewSpaceCoordinateForCartesianCoordinate:CGPointZero];
    CGRect graphBounds = [self graphBounds];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    // Draw x grid (vertical lines)
    if(self.minX <= 0 && 0 <= self.maxX) {
        CGFloat xPos = viewSpaceOrigin.x + (self.displayAxes && !self.displayAsBoxedPlot ? viewGridWidth : 0);
        while(xPos < graphBounds.origin.x + graphBounds.size.width) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, graphBounds.origin.y)];
            [path addLineToPoint:CGPointMake(xDrawPos, graphBounds.origin.y + graphBounds.size.height)];
            
            xPos += viewGridWidth;
        }
        
        xPos = viewSpaceOrigin.x - viewGridWidth;
        while(xPos >= graphBounds.origin.x) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, graphBounds.origin.y)];
            [path addLineToPoint:CGPointMake(xDrawPos, graphBounds.origin.y + graphBounds.size.height)];
            
            xPos -= viewGridWidth;
        }
    } else {
        CGFloat xPos = [self viewSpaceCoordinateForCartesianCoordinate:CGPointMake(self.minX, 0)].x;
        while(xPos < graphBounds.origin.x + graphBounds.size.height) {
            CGFloat xDrawPos = roundf(xPos);
            [path moveToPoint:CGPointMake(xDrawPos, graphBounds.origin.y)];
            [path addLineToPoint:CGPointMake(xDrawPos, graphBounds.origin.y + graphBounds.size.height)];
            
            xPos += viewGridWidth;
        }
    }
    
    
    CGFloat cartesianGridHeight = [self optimalCartesianGridHeight];
    CGFloat viewGridHeight = [self viewSpaceHeightForCatesianHeight:cartesianGridHeight];
    
    // Draw y grid (horizontal lines)
    if(self.minY <= 0 && 0 <= self.maxY) {
        CGFloat yPos = viewSpaceOrigin.y + (self.displayAxes && !self.displayAsBoxedPlot ? viewGridHeight : 0);
        while(yPos < graphBounds.origin.y + graphBounds.size.height) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(graphBounds.origin.x, yDrawPos)];
            [path addLineToPoint:CGPointMake(graphBounds.origin.x + graphBounds.size.width, yDrawPos)];
            
            yPos += viewGridHeight;
        }
        
        yPos = viewSpaceOrigin.y - viewGridHeight;
        while(yPos >= graphBounds.origin.y) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(graphBounds.origin.x, yDrawPos)];
            [path addLineToPoint:CGPointMake(graphBounds.origin.x + graphBounds.size.width, yDrawPos)];
            
            yPos -= viewGridHeight;
        }
    } else {
        CGFloat yPos = [self viewSpaceCoordinateForCartesianCoordinate:CGPointMake(0, self.minY)].y;
        while(yPos >= graphBounds.origin.y) {
            CGFloat yDrawPos = roundf(yPos);
            [path moveToPoint:CGPointMake(graphBounds.origin.x, yDrawPos)];
            [path addLineToPoint:CGPointMake(graphBounds.origin.x + graphBounds.size.width, yDrawPos)];
            
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
        [path moveToPoint:CGPointMake(viewSpaceOrigin.x, [self graphBounds].origin.y)];
        [path addLineToPoint:CGPointMake(viewSpaceOrigin.x, [self graphBounds].origin.y + [self graphBounds].size.height)];
    }
    [path stroke];
}

- (void) drawYAxis
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGPoint viewSpaceOrigin = [self viewSpaceCoordinateForCartesianCoordinate:CGPointZero];
    if(self.minY <= 0 && 0 <= self.maxY) {
        [path moveToPoint:CGPointMake([self graphBounds].origin.x, viewSpaceOrigin.y)];
        [path addLineToPoint:CGPointMake([self graphBounds].origin.x + [self graphBounds].size.width, viewSpaceOrigin.y)];
    }
    [path stroke];
}

- (void) drawPlotWithIndex:(NSUInteger)plotIndex
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGPoint firstPoint = CGPointMake(self.minX, [self.dataSource graphView:self yValueForXValue:self.minX onPlotWithIndex:plotIndex]);
    firstPoint = [self viewSpaceCoordinateForCartesianCoordinate:firstPoint];
    [path moveToPoint:firstPoint];
    
    NSUInteger numIterations = [self graphBounds].size.width / GRAPH_RESOLUTION * [UIScreen mainScreen].scale;
    CGFloat increment = GRAPH_RESOLUTION / [self graphBounds].size.width * (self.maxX - self.minX); // is this right?
    for(NSUInteger i = 1; i <= numIterations; i++) {
        CGFloat x = self.minX + i * increment;
        CGFloat y = [self.dataSource graphView:self yValueForXValue:x onPlotWithIndex:plotIndex];
        
        CGPoint point = CGPointMake(x, y);
        point = [self viewSpaceCoordinateForCartesianCoordinate:point];
        
        [path addLineToPoint:point];
    }
    
    UIBezierPath *graphClipPath = [UIBezierPath bezierPathWithRect:[self graphBounds]];
    CGContextSaveGState(UIGraphicsGetCurrentContext()); {
        [graphClipPath addClip];
        path.lineWidth = 2.0f;
        [path stroke];
    } CGContextRestoreGState(UIGraphicsGetCurrentContext());
    

}

- (void) drawAxesLabels
{
    // Text labels
    NSString *xLabel = [self.dataSource XAxisLabelInGraphView:self];
    NSString *yLabel = [self.dataSource YAxisLabelInGraphView:self];
    CGSize xSize = [xLabel sizeWithAttributes:[self axesLabelsAttributes]];
    CGSize ySize = [yLabel sizeWithAttributes:[self axesLabelsAttributes]];
    CGRect graphBounds = [self graphBounds];
    CGFloat xLabelsYCoord = graphBounds.origin.y + graphBounds.size.height + AXIS_LABEL_TO_BORDER_SPACE;
    
    CGRect xRect = CGRectMake(graphBounds.origin.x + graphBounds.size.width / 2 - xSize.width/2, xLabelsYCoord, xSize.width, xSize.height);
    [xLabel drawInRect:xRect withAttributes:[self axesLabelsAttributes]];
    
    CGRect yRect = CGRectMake(graphBounds.origin.x - AXIS_LABEL_TO_BORDER_SPACE - ySize.width, graphBounds.origin.y + graphBounds.size.height / 2 - ySize.height / 2, ySize.width, ySize.height);
    [yLabel drawInRect:yRect withAttributes:[self axesLabelsAttributes]];
    
    
    // Numeric labels
    // Left x
    NSString *numericLabel = [NSString stringWithFormat:@"%.4g", self.minX];
    CGSize size = [numericLabel sizeWithAttributes:[self axesLabelsAttributes]];
    CGRect rect = CGRectMake(graphBounds.origin.x, xLabelsYCoord, size.width, size.height);
    [numericLabel drawInRect:rect withAttributes:[self axesLabelsAttributes]];
    
    // Right x
    numericLabel = [NSString stringWithFormat:@"%.4g", self.maxX];
    size = [numericLabel sizeWithAttributes:[self axesLabelsAttributes]];
    rect = CGRectMake(graphBounds.origin.x + graphBounds.size.width - size.width, xLabelsYCoord, size.width, size.height);
    [numericLabel drawInRect:rect withAttributes:[self axesLabelsAttributes]];
    
    // Bottom y
    numericLabel = [NSString stringWithFormat:@"%.3g", self.minY];
    size = [numericLabel sizeWithAttributes:[self axesLabelsAttributes]];
    rect = CGRectMake(graphBounds.origin.x - AXIS_LABEL_TO_BORDER_SPACE - size.width, graphBounds.origin.y + graphBounds.size.height - size.height, size.width, size.height);
    [numericLabel drawInRect:rect withAttributes:[self axesLabelsAttributes]];
    
    // Top y
    numericLabel = [NSString stringWithFormat:@"%.3g", self.maxY];
    size = [numericLabel sizeWithAttributes:[self axesLabelsAttributes]];
    rect = CGRectMake(graphBounds.origin.x - AXIS_LABEL_TO_BORDER_SPACE - size.width, graphBounds.origin.y, size.width, size.height);
    [numericLabel drawInRect:rect withAttributes:[self axesLabelsAttributes]];

    
}



@end
