//
//  MLFancyDots.h
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


#import <UIKit/UIKit.h>

@protocol MLFancyDotsDelegate;

@interface MLFancyDots : UIView

@property (nonatomic, unsafe_unretained) id<MLFancyDotsDelegate> delegate;
@property (readonly, getter=selected) NSInteger selectedDot;

- (void) reloadData; // reloads all data from delegate
- (void) updateDots; // only updates dots' image
- (void) selectDotAtIndex:(NSInteger)index;

@end

@protocol MLFancyDotsDelegate <NSObject>
@required
- (NSInteger) numberOfDotsInFancyDots:(MLFancyDots *)fancyDots;
- (CGSize) imageSizeForFancyDots:(MLFancyDots *)fancyDots;
- (NSString *) fancyDots:(MLFancyDots *)fancyDots imageNameForSelectedDotAtIndex:(NSInteger)index;
- (NSString *) fancyDots:(MLFancyDots *)fancyDots imageNameForDefaultDotAtIndex:(NSInteger)index;

@optional
- (NSString *) fancyDots:(MLFancyDots *)fancyDots specialImageNameForDotAtIndex:(NSInteger)index
                                                  selected:(BOOL)selected;
- (NSString *) fancyDots:(MLFancyDots *)fancyDots textForDotAtIndex:(NSInteger)index;
- (void) fancyDots:(MLFancyDots *)fancyDots didSelectDotAtIndex:(NSInteger)index;

@end
