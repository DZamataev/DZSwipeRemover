//
//  BaseTableViewCell.m
//
//  Created by Denis Zamataev on 10/17/13.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSMutableArray*)getAllSubviewsForObject:(id)obj
{
    NSMutableArray *result = [NSMutableArray new];
    if (obj && [obj respondsToSelector:@selector(subviews)])
    {
        NSArray *subviews = ((UIView*)obj).subviews;
        for (int i = 0; i < subviews.count ; i++)
        {
            id subObj = [subviews objectAtIndex:i];
            [result addObject:subObj];
            NSArray *deeper = [BaseTableViewCell getAllSubviewsForObject:subObj];
            if (deeper && deeper.count > 0) {
                [result addObjectsFromArray:deeper];
            }
        }
    }
    return result;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    NSArray *allSubviews = [BaseTableViewCell getAllSubviewsForObject:self];
    for (id view in allSubviews) {
        if ([view respondsToSelector:@selector(setSelected:animated:)]) {
            [view setSelected:selected animated:animated];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    NSArray *allSubviews = [BaseTableViewCell getAllSubviewsForObject:self];
    for (id view in allSubviews) {
        if ([view respondsToSelector:@selector(setHighlighted:animated:)]) {
            [view setHighlighted:highlighted animated:animated];
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    NSArray *allSubviews = [BaseTableViewCell getAllSubviewsForObject:self];
    for (id view in allSubviews) {
        if ([view respondsToSelector:@selector(prepareForReuse)]) {
            [view prepareForReuse];
        }
    }
}

@end
