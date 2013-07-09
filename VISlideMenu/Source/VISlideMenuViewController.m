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

#import "VISlideMenuViewController.h"

#define kLeftMaxMenuWidth 320.0f
#define kRightMaxMenuWidth 320.0f

NSString *const VISlideMenuDidOpenLeft = @"VISlideMenuDidOpenLeft";
NSString *const VISlideMenuDidOpenRight = @"VISlideMenuDidOpenRight";
NSString *const VISlideMenuDidShowCenter = @"VISlideMenuDidShowCenter";

const CGFloat kMaxAnimationDuration = 0.44f;

typedef enum {
    VISlideMenuPanDirectionNone,
    VISlideMenuPanDirectionLeft,
    VISlideMenuPanDirectionRight
} VISlideMenuPanDirection;

@interface VISlideMenuViewController ()
@property (nonatomic, assign, getter = isInitialized) BOOL initialized;
@property (nonatomic, assign) CGPoint panGestureOrigin;
@property (nonatomic, assign) CGFloat panGestureVelocity;
@property (nonatomic, assign) VISlideMenuPanDirection panDirection;
@property (nonatomic, strong) UITapGestureRecognizer *centerTapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *centerPanRecognizer;
@property (nonatomic, strong) UIBarButtonItem *leftButtonBarItem;
@property (nonatomic, strong) UIBarButtonItem *rightButtonBarItem;


- (void)showCenterViewWithDuration:(CGFloat)duration completition:(void(^)())completition;
- (void)showLeftViewWithDuration:(CGFloat)duration completition:(void(^)())completition;
- (void)showRightViewWithDuration:(CGFloat)duration completition:(void(^)())completition;

- (void)_removeContentController:(UIViewController *)content;
- (void)_eventuallyShowLeftButtonBarItem;
- (void)_eventuallyShowRightButtonBarItem;

- (void)_handlePan:(UIPanGestureRecognizer *)recognizer;
- (void)_centerViewControllerTapped:(UIPanGestureRecognizer *)recognizer;

@end

@implementation VISlideMenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.initialized = NO;
        self.view.backgroundColor = [UIColor blackColor];
        self.currentState = VISlideMenuStateDefault;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

- (void)viewWillLayoutSubviews {
    if (![self isInitialized]) {
        CGRect leftFrame = self.leftViewController.view.frame;
        leftFrame.size.height = self.view.bounds.size.height;
        leftFrame.size.width = 320.0f;
        self.leftViewController.view.frame = leftFrame;
        
        self.centerViewController.view.frame = self.view.bounds;
        self.initialized = YES;
    }
}


-(NSUInteger)supportedInterfaceOrientations {
    if (self.centerViewController)
    {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]])
        {
            [((UINavigationController *)self.centerViewController).topViewController supportedInterfaceOrientations];
        }
        return [self.centerViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotate {
    if (self.centerViewController)
    {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]])
        {
            return [((UINavigationController *)self.centerViewController).topViewController shouldAutorotate];
        }
        return [self.centerViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if (self.centerViewController)
    {
        if ([self.centerViewController isKindOfClass:[UINavigationController class]])
        {
            return [((UINavigationController *)self.centerViewController).topViewController preferredInterfaceOrientationForPresentation];
        }
        return [self.centerViewController preferredInterfaceOrientationForPresentation];
    }
    return UIInterfaceOrientationPortrait;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.centerViewController view].layer.shadowPath = nil;
    [self.centerViewController view].layer.shouldRasterize = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    //[self drawCenterControllerShadowPath];
    [self.centerViewController view].layer.shouldRasterize = NO;
}

#pragma mark - Getters & Setters

- (void)setDisablePanGesture:(BOOL)disablePanGesture
{
    _disablePanGesture = disablePanGesture;
    
    [self _removeCenterGestureRecognizers];
    [self _addCenterGestureRecognizers];
    
    if (_disablePanGesture) {
        if (self.leftViewController) {
            [self _eventuallyShowLeftButtonBarItem];
        }
        
        if (self.rightViewController) {
            [self _eventuallyShowRightButtonBarItem];
        }
    }
}

- (void)setCenterViewController:(UIViewController *)centerViewController {
    [self _removeCenterGestureRecognizers];
    CGPoint origin = ((UIViewController *)_centerViewController).view.frame.origin;
    [[_centerViewController view] removeFromSuperview];
    
    _centerViewController = centerViewController;
    if(!_centerViewController) return;
    
    [self addChildViewController:_centerViewController];
    [self.view addSubview:[_centerViewController view]];
    [((UIViewController *)_centerViewController) view].frame = (CGRect){.origin = origin, .size=centerViewController.view.frame.size};
    [_centerViewController didMoveToParentViewController:self];
    [self _addCenterGestureRecognizers];
    [self _eventuallyShowLeftButtonBarItem];
    [self _eventuallyShowRightButtonBarItem];
    
    _centerViewController.view.layer.shadowRadius = 5.0f;
    _centerViewController.view.layer.shadowOffset = CGSizeZero;
    _centerViewController.view.layer.shadowOpacity = 0.6f;
    _centerViewController.view.layer.shouldRasterize = YES;
    _centerViewController.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    [self _removeContentController:_leftViewController];
    _leftViewController = leftViewController;
    [self _eventuallyShowLeftButtonBarItem];
    if (_leftViewController == nil){ [self showCenterViewWithDuration:0.0f completition:nil]; return;}
    
    CGRect frame = _leftViewController.view.frame;
    if (frame.size.width > kLeftMaxMenuWidth)
        frame.size.width = kLeftMaxMenuWidth;
    frame.origin.x = 0;
    _leftViewController.view.frame = frame;
    [self addChildViewController:_leftViewController];
    [self.view insertSubview:[_leftViewController view] atIndex:0];
    if (self.currentState == VISlideMenuStateLeftOpen)
        [self showLeftView];
}

- (void)setRightViewController:(UIViewController *)rightViewController
{
    [self _removeContentController:_rightViewController];
    _rightViewController = rightViewController;
    [self _eventuallyShowRightButtonBarItem];
    if (_rightViewController == nil){ [self showCenterViewWithDuration:0.0f completition:nil]; return;}
    
    CGRect frame = _rightViewController.view.frame;
    if (frame.size.width > kRightMaxMenuWidth)
        frame.size.width = kRightMaxMenuWidth;
    frame.origin.x = self.view.bounds.size.width - frame.size.width;
    _rightViewController.view.frame = frame;
    [self addChildViewController:_rightViewController];
    [self.view insertSubview:[_rightViewController view] atIndex:0];
    if (self.currentState == VISlideMenuStateRightOpen)
        [self showRightView];
}

- (UITapGestureRecognizer *)centerTapRecognizer
{
    if (!_centerTapRecognizer)
    {
        [self setCenterTapRecognizer:[[UITapGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(_centerViewControllerTapped:)]];
        [_centerTapRecognizer setDelegate:self];
    }
    return _centerTapRecognizer;
}

#pragma mark - Content management

- (void)_removeContentController:(UIViewController *)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)_eventuallyShowLeftButtonBarItem
{
    if (![self.centerViewController isKindOfClass:[UINavigationController class]] || ![self isPanGestureDisabled]) return;
    UINavigationController *navVC = (UINavigationController *)self.centerViewController;
    if (_leftViewController == nil) {
        [navVC topViewController].navigationItem.leftBarButtonItem = nil;
        return;
    }
    
    _leftButtonBarItem = [[UIBarButtonItem alloc] initWithTitle:self.leftViewController.title
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(showLeftView)];
    [navVC topViewController].navigationItem.leftBarButtonItem = _leftButtonBarItem;
}

- (void)_eventuallyShowRightButtonBarItem
{
    if (![self.centerViewController isKindOfClass:[UINavigationController class]] || ![self isPanGestureDisabled]) return;
    UINavigationController *navVC = (UINavigationController *)self.centerViewController;
    if (_rightViewController == nil) {
        [navVC topViewController].navigationItem.rightBarButtonItem = nil;
        return;
    }
    
    _rightButtonBarItem = [[UIBarButtonItem alloc] initWithTitle:self.rightViewController.title
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(showRightView)];
    [navVC topViewController].navigationItem.rightBarButtonItem = _rightButtonBarItem;
}

#pragma mark - Shows

- (void)showCenterView
{
    [self showCenterViewWithDuration:kMaxAnimationDuration completition:nil];
}

- (void)showCenterView:(void (^)())completition
{
    [self showCenterViewWithDuration:kMaxAnimationDuration completition:completition];
}

- (void)showCenterViewWithDuration:(CGFloat)duration completition:(void(^)())completition
{
    __block typeof(self) blockSelf = self;
    [UIView animateWithDuration:duration
                     animations:^{
                         blockSelf.centerViewController.view.transform = CGAffineTransformIdentity;
                         blockSelf.currentState = VISlideMenuStateDefault;
                         [blockSelf.centerViewController.view removeGestureRecognizer:blockSelf.centerTapRecognizer];
                     } completion:^(BOOL finished){
                         if (finished) {
                             blockSelf.currentState = VISlideMenuStateDefault;
                             [[NSNotificationCenter defaultCenter] postNotificationName:VISlideMenuDidShowCenter object:self];
                             if(completition) completition();
                         }
                     }];
}

- (void)showLeftView
{
    [self showLeftViewWithDuration:kMaxAnimationDuration completition:nil];
}

- (void)showLeftView:(void (^)())completition
{
    [self showLeftViewWithDuration:kMaxAnimationDuration completition:completition];
}

- (void)showLeftViewWithDuration:(CGFloat)duration completition:(void(^)())completition
{
    __block typeof(self) blockSelf = self;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         blockSelf.centerViewController.view.transform = CGAffineTransformMakeTranslation(blockSelf.leftViewController.view.frame.size.width, 0);
                     } completion:^(BOOL finished){
                         if (finished) {
                             blockSelf.currentState = VISlideMenuStateLeftOpen;
                             [blockSelf.centerViewController.view addGestureRecognizer:blockSelf.centerTapRecognizer];
                             [[NSNotificationCenter defaultCenter] postNotificationName:VISlideMenuDidOpenLeft object:self];
                             if(completition) completition();
                         }
                     }];
    
}

- (void)showRightView
{
    [self showRightViewWithDuration:kMaxAnimationDuration completition:nil];
}

- (void)showRightView:(void (^)())completition
{
    [self showRightViewWithDuration:kMaxAnimationDuration completition:completition];
}

- (void)showRightViewWithDuration:(CGFloat)duration completition:(void(^)())completition
{
    __block typeof(self) blockSelf = self;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         blockSelf.centerViewController.view.transform = CGAffineTransformMakeTranslation(-blockSelf.rightViewController.view.frame.size.width, 0);
                     } completion:^(BOOL finished){
                         if (finished) {
                             blockSelf.currentState = VISlideMenuStateRightOpen;
                             [blockSelf.centerViewController.view addGestureRecognizer:blockSelf.centerTapRecognizer];
                             [[NSNotificationCenter defaultCenter] postNotificationName:VISlideMenuDidOpenRight object:self];
                             if(completition) completition();
                         }
                     }];
}

#pragma mark - UIGestureRecognizer Helpers

- (UIPanGestureRecognizer *)_panGestureRecognizer {
    if (!_centerPanRecognizer) {
        _centerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(_handlePan:)];
        [_centerPanRecognizer setMaximumNumberOfTouches:1];
        [_centerPanRecognizer setDelegate:self];
        
    }
    return _centerPanRecognizer;
}


- (void)_addGestureRecognizers {
    [self _addCenterGestureRecognizers];
}

- (void)_removeCenterGestureRecognizers
{
    if (self.centerViewController)
    {
        [[self.centerViewController view] removeGestureRecognizer:self.centerTapRecognizer];
        [[self.centerViewController view] removeGestureRecognizer:[self _panGestureRecognizer]];
    }
}

- (void)_addCenterGestureRecognizers
{
    if (self.centerViewController)
    {
        [[self.centerViewController view] addGestureRecognizer:self.centerTapRecognizer];
        if (![self isPanGestureDisabled])
            [[self.centerViewController view] addGestureRecognizer:[self _panGestureRecognizer]];
    }
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // skip recognition of table view reordering gesture:
    if([touch.view isKindOfClass:NSClassFromString(@"UITableViewCellReorderControl")]) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}

- (void)_handlePan:(UIPanGestureRecognizer *)recognizer {
    static CGPoint lastTranslation;
    
	if(recognizer.state == UIGestureRecognizerStateBegan) {
        _panGestureOrigin = _centerViewController.view.frame.origin;
        self.panDirection = VISlideMenuPanDirectionNone;
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:_centerViewController.view];
        self.panDirection = (translation.x < lastTranslation.x) ? VISlideMenuPanDirectionLeft : VISlideMenuPanDirectionRight;
        
        CGFloat xTranslation = _panGestureOrigin.x + translation.x;
        if (xTranslation > self.view.frame.size.width)
            xTranslation = self.view.frame.size.width;
        else if(xTranslation < -self.view.frame.size.width)
            xTranslation = -self.view.frame.size.width;
        
        if (_leftViewController == nil && xTranslation > 0)
            xTranslation = 0;
        else if (_rightViewController == nil && xTranslation < 0)
            xTranslation = 0;
        else if (xTranslation > _leftViewController.view.frame.size.width)
            xTranslation = _leftViewController.view.frame.size.width;
        else if (xTranslation < -_rightViewController.view.frame.size.width)
            xTranslation = -(_rightViewController.view.frame.size.width);
        
        self.centerViewController.view.transform = CGAffineTransformMakeTranslation(xTranslation, 0);
        lastTranslation = translation;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:_centerViewController.view];
        
        CGPoint translation = [recognizer translationInView:_centerViewController.view];
        CGFloat span = translation.x + _panGestureOrigin.x;
        
        CGFloat duration = fabs(span / ((velocity.x>0)?velocity.x:600));
        if (duration > kMaxAnimationDuration) duration = kMaxAnimationDuration;
        
        CGFloat targetWidth = (span < 0)?_rightViewController.view.frame.size.width:_leftViewController.view.frame.size.width;
        BOOL slide = ((span > 0) && span > targetWidth / 3.0) || ((span < 0) && span < -(targetWidth / 3.0));
        slide = ((span < 0 && _rightViewController == nil) || (span > 0 && _leftViewController == nil))? NO : slide;
        
        
        if (slide == NO) {
            [self showCenterViewWithDuration:duration  completition:nil];
        } else if (span > 0) {
            [self showLeftViewWithDuration:duration  completition:nil];
        } else {
            [self showRightViewWithDuration:duration  completition:nil];
        }
    }
    
}

- (void)_centerViewControllerTapped:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self showCenterViewWithDuration:kMaxAnimationDuration completition:nil];
}

@end
