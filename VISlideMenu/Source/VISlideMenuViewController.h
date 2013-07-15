/**
 *  Copyright (c) 2012 Vilea GmbH
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 *  and associated documentation files (the “Software”), to deal in the Software without restriction,
 *  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 *  subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 *  Under no circumstances shall be granted use of this software, source code, documentation or other related material.
 *  Persons dealing in the Software agree not to knowingly distribute these materials or any derivative works to.
 *
 *  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 *  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

extern NSString *const VISlideMenuDidOpenLeft;
extern NSString *const VISlideMenuDidOpenRight;
extern NSString *const VISlideMenuDidShowCenter;

typedef enum {
    VISlideMenuStateDefault,
    VISlideMenuStateLeftOpen,
    VISlideMenuStateRightOpen
} VISlideMenuState;

@interface VISlideMenuViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, assign) VISlideMenuState currentState;

@property (nonatomic, assign, getter = isPanGestureDisabled) BOOL disablePanGesture;
@property (nonatomic, assign, getter = isUsingOnlyIconForBarButton) BOOL useOnlyIconForBarButton;

- (void)showRightView;
- (void)showLeftView;
- (void)showCenterView;
- (void)showRightView:(void(^)())completition;
- (void)showLeftView:(void(^)())completition;
- (void)showCenterView:(void(^)())completition;

- (void)addBarButtonItemToRightSide:(UIBarButtonItem *)buttonItem;

@end
