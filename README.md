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
3. Set `minX`, `maxX`, `minY`, and `maxY` properties of the `DPGraphView`.
4. Add the `DPGraphView`, or do whatever you want with it.

## Example Code

For this example code, I have my `DPGraphView` created in a Storyboard and connected to my Controller via an outlet. I simply override the setter to setup the properties of the `DPGraphView`, and then implement the methods in the protocol.

```objc
#import "ViewController.h"
#import "DPGraphView.h"

@interface ViewController () <DPGraphViewDataSource>
@property (weak, nonatomic) IBOutlet DPGraphView *graphView;
@end

@implementation ViewController

- (void) setGraphView:(DPGraphView *)graphView
{
    _graphView = graphView;
    
    _graphView.dataSource = self;
    _graphView.minX = -4;
    _graphView.maxX = 4;
    _graphView.minY = 0;
    _graphView.maxY = 20;
}

- (NSUInteger) numberOfPlotsInGraphView:(DPGraphView *)graphView
{
    return 2;
}

- (CGFloat) graphView:(DPGraphView *)graphView yValueForXValue:(CGFloat)x onPlotWithIndex:(NSUInteger)plotIndex
{
    switch (plotIndex) {
        case 0:
            return powf(x, 2);
        
        case 1:
            return expf(-x*x)*15;
            
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
            
        default:
            return [UIColor blackColor];
    }
}
```

## License

DPGraphView is available under the MIT license. See the LICENSE file for more info.
