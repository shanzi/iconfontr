//
//  NSBezierPath+SVGPathString.m
//  iconfontr
//
//  Created by Chase Zhang on 4/26/14.
//  Copyright (c) 2014 io-meter. All rights reserved.
//

#import "NSBezierPath+SVGPathString.h"

static const NSString *SVGPathTemplate =
@"<?xml version=\"1.0\" standalone=\"no\"?>\n\
<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n\
<svg style=\"%@\" width=\"%@\" height=\"%@\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n\
  <path d=\"%@\" style=\"%@\"/>\n\
</svg>";


@implementation NSBezierPath (SVGPathString)

- (NSString *)SVGPathString
{
  NSMutableArray *pathStringComponents = [[NSMutableArray alloc] init];
  NSInteger elementCount = [self elementCount];
  NSPointArray pointArray = malloc(sizeof(NSPoint)*3);
  NSBezierPathElement element = -1;
  NSString *pathComponet = nil;
  CGFloat tx = -self.bounds.origin.x;
  CGFloat ty = -self.bounds.origin.y - self.bounds.size.height;
  for (NSInteger i=0; i<elementCount; i++) {
    element = [self elementAtIndex:i associatedPoints:pointArray];
    for (NSInteger j=0; j<3; j++){
      pointArray[j].x += tx;
      pointArray[j].y += ty;
      pointArray[j].y *= -1;
    }
    switch (element) {
      case NSMoveToBezierPathElement:
        pathComponet = [NSString stringWithFormat:@"M%f %f", pointArray[0].x, pointArray[0].y];
        break;
      case NSLineToBezierPathElement:
        pathComponet = [NSString stringWithFormat:@"L%f %f", pointArray[0].x, pointArray[0].y];
        break;
      case NSCurveToBezierPathElement:
        pathComponet = [NSString stringWithFormat:@"C%f %f %f %f %f %f",
                        pointArray[0].x, pointArray[0].y,
                        pointArray[1].x, pointArray[1].y,
                        pointArray[2].x, pointArray[2].y];
        break;
      case NSClosePathBezierPathElement:
        pathComponet = @"Z";
        break;
      default:
        pathComponet = nil;
        break;
    }
    if(pathComponet) [pathStringComponents addObject:pathComponet];
  }
  free(pointArray);
  if ([pathStringComponents count]) {
    return [pathStringComponents componentsJoinedByString:@" "];
  }
  return nil;
}

- (NSString *)SVGText
{
  return [self SVGTextWithWidth:nil height:nil canvasStyle:nil pathStyle:nil];
}

- (NSString *)SVGTextWithWidth:(NSString *)width height:(NSString *)height canvasStyle:(NSString *)cstyle pathStyle:(NSString *)style
{
  NSString *theSVGPathString = [self SVGPathString];
  if (theSVGPathString) {
    style = style ? style : @"fill:black";
    width = width ? width : @"100%";
    height = height ? height : @"100%";
    cstyle = cstyle ? cstyle : @"";
    return [NSString stringWithFormat:(NSString *)SVGPathTemplate, cstyle, width, height, theSVGPathString, style];
  }
  return nil;
}

+ (NSString *)SVGColorStringWithColor:(NSColor *)color
{
  color = [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
  NSString *colorString =
  [NSString stringWithFormat:@"rgba(%.0f, %.0f, %.0f, %.2f)",
   color.redComponent * 255,
   color.greenComponent * 255,
   color.blueComponent * 255,
   color.alphaComponent];
  return colorString;
}

@end
