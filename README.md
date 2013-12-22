DPGraphView
===========

A reusable graphing view for iOS to easily plot continuous functions.

## Installation

Use [CocoaPods!](http://beta.cocoapods.org/?q=)
<br />
Add `pod 'DPGraphView'` to your Podfile
<br />
_Note that_ `DPGraphView` _requires iOS 6.0 or later_ (not fully tested :worried:)

Otherwise, feel free to copy-paste the source into your project.

## How To Use

1. Set the `dataSource` property of a `DPGraphView` to be the data source for the plotting (probably `self`).
2. Implement the required methods in the `DPGraphViewDataSource` protocol: `-(CGFloat)graphView:(DPGraphView *)graphView yValueForXValue:(CGFloat)x onPlotWithIndex:(NSUInteger)plotIndex` and `-(NSUInteger)numberOfPlotsInGraphView:(DPGraphView *)graphView`
3. Optionally implement `-(UIColor *)graphView:(DPGraphView *)graphView colorForPlotIndex:(NSUInteger)plotIndex` to color specific plots. If you don't implement this, all plots will simply be black.
4. Optionally implement `-(UIColor *)graphViewColorForGrid:(DPGraphView *)graphView` to color the gridlines. If you don't implement this, the gridlines will simply be black.
5. Optionally implement `-(UIColor *)graphViewColorFor[X][Y]Axis:(DPGraphView *)graphView` to color the X and Y axes. If you don't implement this, the axes will simply be black.
6. Set `minX`, `maxX`, `minY`, and `maxY` properties of the `DPGraphView`.
7. Optionally set `displayGridlines`, `dashGridlines`, and `displayAxes` properties of the `DPGraphView` to enable and configure the display of gridline and axes. If you don't set these properties, no axes or gridlines will be rendered.
8. Add the `DPGraphView`, or do whatever you want with it.

## Example Code

For this example code, I have my `DPGraphView` created in a Storyboard and connected to my Controller via an outlet. I simply override the setter to setup the properties of the `DPGraphView`, and then implement the methods in the protocol.

```objc
#import "ViewController.h"
#import "DPGraphView.h"

@interface ViewController () <DPGraphViewDataSource>
@property (nonatomic, weak) IBOutlet DPGraphView *graphView;
@end

@implementation ViewController

- (void) setGraphView:(DPGraphView *)graphView
{
    _graphView = graphView;
    
    _graphView.dataSource = self;
    _graphView.minX = -3;
    _graphView.maxX = 3;
    _graphView.minY = -4;
    _graphView.maxY = 4;
    _graphView.displayGridlines = YES;
    _graphView.displayAxes = YES;
    _graphView.dashGridlines = YES;
}


- (NSUInteger) numberOfPlotsInGraphView:(DPGraphView *)graphView
{
    return 3;
}

- (CGFloat) graphView:(DPGraphView *)graphView yValueForXValue:(CGFloat)x onPlotWithIndex:(NSUInteger)plotIndex
{
    switch (plotIndex) {
        case 0:
            return powf(x, 2);
            
        case 1:
            return expf(-x*x)*4;
            
        case 2:
            return powf(x, 3);
            
        default:
            return 0;
    }
}

- (UIColor *) graphView:(DPGraphView *)graphView colorForPlotIndex:(NSUInteger)plotIndex
{
    switch (plotIndex) {
        case 0:
            return [UIColor redColor];
            
        case 1:
            return [UIColor blueColor];
            
        case 2:
            return [UIColor yellowColor];
            
        default:
            return [UIColor blackColor];
    }
}

- (UIColor *) graphViewColorForGrid:(DPGraphView *)graphView
{
    return [UIColor colorWithRed:0.000 green:0.502 blue:0.251 alpha:1.000];
}

- (UIColor *) graphViewColorForXAxis:(DPGraphView *)graphView
{
    return [UIColor greenColor];
}

- (UIColor *) graphViewColorForYAxis:(DPGraphView *)graphView
{
    return [UIColor greenColor];
}

@end
```

And the result of the above code should look something like:

![Sample Graph](https://raw.github.com/donald-pinckney/DPGraphView/master/sample_graph.png)

## License

DPGraphView is available under the MIT license. See the LICENSE file for more info.
