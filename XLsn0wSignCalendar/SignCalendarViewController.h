
#import "XLNavViewController.h"

@interface SignCalendarViewController : XLNavViewController

@property (strong, nonatomic) NSDate *date;

@end

@interface CalendarCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *dayLabel;

@end

@interface SignInTimeModel : NSObject

@property (nonatomic,copy) NSNumber *SignInStatus;

@end

@interface lastModel : NSObject

@property (nonatomic,copy) NSNumber *SignInStatus;

@end

@interface nextModel : NSObject

@property (nonatomic,copy) NSNumber *SignInStatus;

@end