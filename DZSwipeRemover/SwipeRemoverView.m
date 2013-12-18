//
//  SwipeRemoverView.m
//
//  Created by Denis Zamataev on 10/17/13.
//

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#import "SwipeRemoverView.h"

@implementation SwipeRemoverView

-(void)setTarget:(UIView *)target
{
    _target = target;
    _targetInitialAlpha = target.alpha;
}

-(UIView*)target
{
    return _target;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self onInitSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self onInitSetup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self onInitSetup];
}

- (void)onInitSetup
{
    _normalizedCompletionAmountPassingWithoutRotation = _normalizedCompletionAmountPassingWithoutRotation == 0 ? SwipeRemoverDefaultNormalizedCompletionAmountPassingWithoutRotation : _normalizedCompletionAmountPassingWithoutRotation;
    _rotationCoefficient = _rotationCoefficient == 0 ? SwipeRemoverDefaultRotationCoefficient : _rotationCoefficient;
    _normalizedCompletionAmountPassingWithoutFading = _normalizedCompletionAmountPassingWithoutFading == 0 ? SwipeRemoverDefaultNormalizedCompletionAmountPassingWithoutFading : _normalizedCompletionAmountPassingWithoutFading;
    _fadingCoefficient = _fadingCoefficient == 0 ? SwipeRemoverDefaultFadingCoefficient : _fadingCoefficient;
    _animationTimeCoefficient = _animationTimeCoefficient == 0 ? SwipeRemoverDefaultAnimationTimeCoefficient : _animationTimeCoefficient;
    _outPositionMultiplier = _outPositionMultiplier == 0 ? SwipeRemoverDefaultOutPositionMultiplier : _outPositionMultiplier;
    
    if (!_recognizer) {
        _recognizer = [[DirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        _recognizer.direction = DirectionPanGestureRecognizerHorizontal;
        _recognizer.minimumNumberOfTouches = 1;
        _recognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:_recognizer];
    }
}

- (IBAction)move:(id)sender
{
    if ([sender isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
        
        BOOL shouldMove = YES;
        if (self.shouldMoveCallback) {
            shouldMove = self.shouldMoveCallback(_target);
        }
        
        if (shouldMove) {
            CGPoint translatedPoint = [pan translationInView:self];
            CGPoint velocityPoint = [pan velocityInView:self];
            
            float normalizedSignedMovementCompletion = translatedPoint.x / _target.bounds.size.width;
            float normalizedAbsoluteMovementCompletion = fabsf(normalizedSignedMovementCompletion);
            float directionMultiplier = normalizedSignedMovementCompletion < 0 ? -1.0f : 1.0f;
            switch ([pan state]) {
                case UIGestureRecognizerStateBegan:
                {
                    if (self.willBeginCallback) {
                        self.willBeginCallback(_target);
                    }
//                    if (_target.superview) {
//                        [_target.superview bringSubviewToFront:_target];
//                    }
                    
                }
                    break;
                    
                case UIGestureRecognizerStateChanged:
                {
                    CGAffineTransform t = CGAffineTransformMakeTranslation(translatedPoint.x, 0);
                    float rotationAmount = 0;
                    if (normalizedAbsoluteMovementCompletion > _normalizedCompletionAmountPassingWithoutRotation) {
                        rotationAmount = (normalizedSignedMovementCompletion - (_normalizedCompletionAmountPassingWithoutRotation * directionMultiplier)) * _rotationCoefficient;
                        
                    }
                    t = CGAffineTransformRotate(t, rotationAmount);
                    _target.transform = t;
                    
                    if (normalizedAbsoluteMovementCompletion > _normalizedCompletionAmountPassingWithoutFading) {
                        float fadingAmount = ((normalizedAbsoluteMovementCompletion - _normalizedCompletionAmountPassingWithoutFading) * _fadingCoefficient);
                        _target.alpha = _targetInitialAlpha - fadingAmount;
                    }
                }
                    break;
                    
                case UIGestureRecognizerStateCancelled:
                case UIGestureRecognizerStateEnded:
                {
                    BOOL passesWidthCondition = normalizedAbsoluteMovementCompletion > 0.6f;
                    BOOL passesVelocityCondition = fabsf(velocityPoint.x) > SwipeRemoverDefaultVelocityEnoughForRemoving;
                    BOOL passesReturnDirectionCondition = (directionMultiplier < 0 && velocityPoint.x < 0) || (directionMultiplier > 0 && velocityPoint.x > 0);
                    BOOL passesCallbackCondition = NO;
                    if ((passesWidthCondition || passesVelocityCondition) && passesReturnDirectionCondition) {
                        passesCallbackCondition = (self.shouldFinishCallback != Nil) ? self.shouldFinishCallback(_target) : YES;
                    }
                    
                    BOOL shouldNotReturn = passesCallbackCondition;
                    
                    if (shouldNotReturn) {
                        float time = ((_outPositionMultiplier-normalizedAbsoluteMovementCompletion) * _animationTimeCoefficient);
                        CGAffineTransform t = CGAffineTransformMakeTranslation(directionMultiplier * _target.bounds.size.width * _outPositionMultiplier, 0);
                        t = CGAffineTransformRotate(t, (_outPositionMultiplier * directionMultiplier - (_normalizedCompletionAmountPassingWithoutRotation * directionMultiplier)) * _rotationCoefficient);
                        float fadingAmount = ((_outPositionMultiplier - _normalizedCompletionAmountPassingWithoutFading) * _fadingCoefficient);
                        
                        [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^{
                            _target.alpha = _targetInitialAlpha - fadingAmount;
                            _target.transform = t;
                        } completion:^(BOOL finished) {
                            _target.hidden = YES;
                            if (self.didFinishCallback) {
                                self.didFinishCallback(_target, NO);
                            }
                        }];
                    }
                    else {
                        float time = normalizedAbsoluteMovementCompletion * _animationTimeCoefficient;
                        
                        [UIView animateWithDuration:time delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^{
                            _target.alpha = _targetInitialAlpha;
                            _target.transform = CGAffineTransformIdentity;
                            _rotateTarget.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished) {
                            if (self.didFinishCallback) {
                                self.didFinishCallback(_target, YES);
                            }
                        }];
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            
            _moveX = translatedPoint.x;
            _moveY = translatedPoint.y;
        }
    }
}


- (void)prepareForReuse
{
    _target.hidden = NO;
    _target.alpha = _targetInitialAlpha;
    _target.transform = CGAffineTransformIdentity;
    _rotateTarget.transform = CGAffineTransformIdentity;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
