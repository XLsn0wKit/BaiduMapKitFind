
#import "RectangleAnnotationView.h"

@interface RectangleAnnotationView ()

@property (nonatomic, strong) UIButton *contentView;

@end

@implementation RectangleAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        [self setBounds:CGRectMake(0.f, 0.f, 140, 35)];
        [self setContentView];
    }
    return self;
}

- (void)setContentView {
    self.contentView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.contentView.frame = self.bounds;
    self.contentView.userInteractionEnabled = NO;
    self.contentView.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView setBackgroundImage:[UIImage imageNamed:@"community"] forState:UIControlStateNormal];
    self.alpha = 0.85;
    self.contentView.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    self.contentView.titleLabel.font = font(10);
    [self addSubview:self.contentView];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.contentView setTitle:title forState:UIControlStateNormal];
}
- (void)didSelectedAnnotation:(RectangleAnnotationView *)annotation {
    [annotation setBounds:CGRectMake(0.f, 0.f, 180, 50)];
    annotation.contentView.frame = annotation.bounds;
    annotation.contentView.titleLabel.font = font(13);
    annotation.alpha = 1;
    annotation.contentView.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);

}

-(void)didDeSelectedAnnotation:(RectangleAnnotationView *)annotation {
    [annotation setBounds:CGRectMake(0.f, 0.f, 140, 35)];
    annotation.contentView.frame = annotation.bounds;
    annotation.contentView.titleLabel.font = font(10);
    annotation.alpha = 0.85;
    annotation.contentView.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
}

- (void)setMessageAnnoIsBig:(NSString *)messageAnnoIsBig {
    _messageAnnoIsBig = messageAnnoIsBig;
    if ([messageAnnoIsBig isEqualToString:@"yes"]) {
        [self setBounds:CGRectMake(0.f, 0.f, 180, 50)];
        self.contentView.frame = self.bounds;
        self.contentView.titleLabel.font = font(13);
        self.alpha = 1;
        self.contentView.titleEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    }else {
        [self setBounds:CGRectMake(0.f, 0.f, 140, 35)];
        self.contentView.frame = self.bounds;
        self.contentView.titleLabel.font = font(10);
        self.alpha = 0.85;
        self.contentView.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);

    }
   
}
@end
