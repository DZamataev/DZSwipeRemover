//
//  SwipeRemoverView.h
//
//  Created by Denis Zamataev on 10/17/13.
//

#import <UIKit/UIKit.h>
#import "DirectionPanGestureRecognizer.h"

#define SwipeRemoverDefaultNormalizedCompletionAmountPassingWithoutRotation 0.3f
#define SwipeRemoverDefaultNormalizedCompletionAmountPassingWithoutFading 0.4f
#define SwipeRemoverDefaultRotationCoefficient 0.7f
#define SwipeRemoverDefaultFadingCoefficient 1.4f
#define SwipeRemoverDefaultAnimationTimeCoefficient 0.5f
#define SwipeRemoverDefaultOutPositionMultiplier 1.2f
#define SwipeRemoverDefaultVelocityEnoughForRemoving 1000.0f

@interface SwipeRemoverView : UIView <UIGestureRecognizerDelegate>
{
    UIView *_target;
    CGFloat _moveX;
    CGFloat _moveY;
    CGFloat _targetInitialAlpha;
}
@property (nonatomic, assign) IBOutlet UIView *target;
@property (nonatomic, assign) IBOutlet UIView *rotateTarget;
@property (nonatomic, retain) IBOutlet DirectionPanGestureRecognizer *recognizer;

@property (nonatomic, copy) BOOL (^shouldFinishCallback)(UIView *targetView);
@property (nonatomic, copy) BOOL (^shouldMoveCallback)(UIView *targetView);
@property (nonatomic, copy) void (^willBeginCallback)(UIView *targetView);
@property (nonatomic, copy) void (^didFinishCallback)(UIView *targetView, BOOL isReturn);

@property (nonatomic, assign) float normalizedCompletionAmountPassingWithoutRotation;
@property (nonatomic, assign) float normalizedCompletionAmountPassingWithoutFading;
@property (nonatomic, assign) float rotationCoefficient;
@property (nonatomic, assign) float fadingCoefficient;
@property (nonatomic, assign) float animationTimeCoefficient;
@property (nonatomic, assign) float outPositionMultiplier;

@end
