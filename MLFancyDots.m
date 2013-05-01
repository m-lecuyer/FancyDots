//
//  MLFancyDots.m
//  Mathias Lecuyer
//
//  Created by Mathias on 4/12/13.
//  Copyright (c) 2013 Mathias Lecuyer. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright (c) 2013 Mathias Lecuyer
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "MLFancyDots.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_DISTANCE_BETWEEN_DOTS 100.0f // the default maxium distance between 2 dots
#define MAX_LENGTH_TO_FRAME_OFFSET 27.0f // offset between first dot and the top of the view
                                         // same as last dot and bottom of the view
#define BAR_WIDTH 3.0f                   // the width of the line between dots
#define OFFSET_AFTER_LABEL 10            // the space after the hoover label when a dot is touched

@interface MLFancyDots ()
{
    int _dotsNumber;
    float _distanceBetweenDots;
    float _fullLength;
}

@property (nonatomic, retain) UIView *linkingBar;
@property (nonatomic, retain) NSArray *dotsImages;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UIView *nameLabelView;

@end

@implementation MLFancyDots

@synthesize selectedDot = _selectedDot;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self reloadData];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self reloadData];
    }
    return self;
}

#pragma mark - interations

/*
 * reloads all data
 * to only update dots images , use [self updateDots];
 */
- (void) reloadData
{
    [self updateDotsNumber];
    [self updateFullLength];
    [self updateDistanceBetweenDots];
    [self drawFancyDots];
}

- (void) selectDotAtIndex:(NSInteger)index
{
    _selectedDot = index;
    [self updateDots];
}

#pragma mark - update characteristics

- (void) updateDotsNumber
{
    _dotsNumber = [_delegate numberOfDotsInFancyDots:self];
}

- (void) updateFullLength
{
    _fullLength = MIN(MAX(_dotsNumber-1,0) * MAX_DISTANCE_BETWEEN_DOTS,
                      self.bounds.size.height - 2 * MAX_LENGTH_TO_FRAME_OFFSET);
}

- (void) updateDistanceBetweenDots
{
    if ((_dotsNumber-1) <= 0)
        _distanceBetweenDots = 0;
    else
        _distanceBetweenDots = _fullLength / (_dotsNumber-1);
}

#pragma mark - (re)draw views

- (void) drawFancyDots
{
    self.linkingBar.frame =
            CGRectMake(self.bounds.size.width/2 - BAR_WIDTH/2, MAX_LENGTH_TO_FRAME_OFFSET, BAR_WIDTH, _fullLength);
    [self updateDots];
}

- (UIView *) linkingBar
{
    if (_linkingBar)
        return _linkingBar;

    _linkingBar = [[UIView alloc] init];
    _linkingBar.backgroundColor = [UIColor colorWithRed:193.0/255.0
                                                  green:193.0/255.0
                                                   blue:193.0/255.0
                                                  alpha:1];
    [self addSubview:_linkingBar];
    return _linkingBar;
}

- (NSArray *) dotsImages {
    if (_dotsImages && [_dotsImages count] == _dotsNumber)
        return _dotsImages;

    // TODO : do it better and reuse old images
    for (UIImageView *img in _dotsImages) {
        [img removeFromSuperview];
    }
    _dotsImages = nil;

    NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:_dotsNumber];
    CGSize dotsSize = [_delegate imageSizeForFancyDots:self];

    for (int i = 0; i < _dotsNumber; i++) {
        UIImageView *imgVdot = [[UIImageView alloc] initWithFrame:
                                CGRectMake(self.bounds.size.width/2 - dotsSize.width/2,
                                           MAX_LENGTH_TO_FRAME_OFFSET + i * _distanceBetweenDots - dotsSize.height/2,
                                           dotsSize.width,
                                           dotsSize.height)];
        [self addSubview:imgVdot];
        [tmp addObject:imgVdot];
    }
    _dotsImages = tmp;
    return _dotsImages;
}

- (void) updateDots
{
    for (int i = 0; i < _dotsNumber; i++) {
        UIImageView *imV = [self.dotsImages objectAtIndex:i];
        [imV setImage:[UIImage imageNamed:[self dotImageForIndex:i]]];
    }
}

- (NSString *) dotImageForIndex:(int)i
{
    NSString *specialImage = nil;
    if ([_delegate respondsToSelector:@selector(fancyDots:specialImageNameForDotAtIndex:selected:)])
        specialImage = [_delegate fancyDots:self specialImageNameForDotAtIndex:i selected:(_selectedDot == i)];
    if (specialImage)
        return specialImage;

    if (_selectedDot == i) {
        return [_delegate fancyDots:self imageNameForSelectedDotAtIndex:i];
    } else {
        return [_delegate fancyDots:self imageNameForDefaultDotAtIndex:i];
    }
}

- (UIView *) nameLabelView
{
    if (_nameLabelView)
        return _nameLabelView;
    
    _nameLabelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 600, 30)];
    [_nameLabelView setBackgroundColor:[UIColor blackColor]];
    [_nameLabelView setAlpha:0.8f];

    return _nameLabelView;
}

- (void) setNameLabelViewFrame:(CGRect)frame
{
    self.nameLabelView.frame = frame;

    // Create the path (with only the top-left corner rounded)
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.nameLabelView.bounds
                                                   byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(15.0, 15.0)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.nameLabelView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the image view's layer
    self.nameLabelView.layer.mask = maskLayer;
    CGRect labelFrame = CGRectMake(self.bounds.size.width, 0, frame.size.width - self.bounds.size.width, 30);
    [self.nameLabel setFrame:labelFrame];
}

- (UILabel *) nameLabel
{
    if (_nameLabel)
        return _nameLabel;

    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width, 300, 60, 30)];
    [_nameLabel setText:@"Name"];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_nameLabel setBackgroundColor:[UIColor clearColor]];
    [_nameLabel setAlpha:1.0f];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];

    [self.nameLabelView addSubview:_nameLabel];
    return _nameLabel;
}

#pragma mark - handle touches

- (NSInteger) closestDotFromPosition:(CGPoint)position
{
    int closestDot = 0;
    int delta = self.bounds.size.height;
    for (int i = 0; i < _dotsNumber; i++) {
        int dotPosition = MAX_LENGTH_TO_FRAME_OFFSET + i * _distanceBetweenDots;
        int touchPosition = position.y;
        if (ABS(dotPosition - touchPosition) < delta) {
            closestDot = i;
            delta = ABS(dotPosition - touchPosition);
        }
    }
    return closestDot;
}

- (void) setLabelText:(NSString *)text
{
    NSString *txt = [NSString stringWithFormat:@" %@ ", text];
    [self.nameLabel setText:txt];
    
    CGSize maximumLabelSize = CGSizeMake(30, 400);
    CGSize requiredSize = [self.nameLabel sizeThatFits:maximumLabelSize];
    CGRect r = self.nameLabelView.frame;
    r.size.width = requiredSize.width + self.bounds.size.width + OFFSET_AFTER_LABEL;
    [self setNameLabelViewFrame:r];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_delegate respondsToSelector:@selector(fancyDots:textForDotAtIndex:)])
        return;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    int closestDot = [self closestDotFromPosition:location];
    
    CGRect r = self.nameLabelView.frame;
    r.origin.y = MAX_LENGTH_TO_FRAME_OFFSET + closestDot * _distanceBetweenDots - r.size.height/2;
    [self.nameLabelView setFrame:r];
    
    [self setLabelText:[_delegate fancyDots:self textForDotAtIndex:closestDot]];
    
    [self addSubview:self.nameLabelView];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_delegate respondsToSelector:@selector(fancyDots:textForDotAtIndex:)])
        return;

    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    int closestDot = [self closestDotFromPosition:location];
    
    CGRect r = self.nameLabelView.frame;
    r.origin.y = MAX_LENGTH_TO_FRAME_OFFSET + closestDot * _distanceBetweenDots - r.size.height/2;
    [self.nameLabelView setFrame:r];
    
    [self setLabelText:[_delegate fancyDots:self textForDotAtIndex:closestDot]];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_delegate respondsToSelector:@selector(fancyDots:textForDotAtIndex:)])
        return;
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    int closestDot = [self closestDotFromPosition:location];

    [self selectDotAtIndex:closestDot];
    if ([_delegate respondsToSelector:@selector(fancyDots:didSelectDotAtIndex:)])
        [_delegate fancyDots:self didSelectDotAtIndex:closestDot];
    
    [self.nameLabelView removeFromSuperview];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_delegate respondsToSelector:@selector(fancyDots:textForDotAtIndex:)])
        return;

    [self.nameLabelView removeFromSuperview];
}

@end
