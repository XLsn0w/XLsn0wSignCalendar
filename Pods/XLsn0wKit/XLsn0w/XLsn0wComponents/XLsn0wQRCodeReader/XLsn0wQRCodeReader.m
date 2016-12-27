/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "XLsn0wQRCodeReader.h"

@interface XLsn0wQRCodeReader ()

@property (strong, nonatomic) QRCameraSwitchButton *switchCameraButton;
@property (strong, nonatomic) QRCodeReaderView     *cameraView;
@property (strong, nonatomic) UIButton             *cancelButton;
@property (strong, nonatomic) QRCodeReaderSupport         *codeReader;
@property (assign, nonatomic) BOOL                 startScanningAtLoad;

@property (copy, nonatomic) void (^completionBlock) (NSString * __nullable);

@end

@implementation XLsn0wQRCodeReader

- (void)dealloc
{
    [self stopScanning];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    return [self initWithCancelButtonTitle:nil];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle
{
    return [self initWithCancelButtonTitle:cancelTitle metadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
}

- (id)initWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [self initWithCancelButtonTitle:nil metadataObjectTypes:metadataObjectTypes];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
    QRCodeReaderSupport *reader = [QRCodeReaderSupport readerWithMetadataObjectTypes:metadataObjectTypes];
    
    return [self initWithCancelButtonTitle:cancelTitle codeReader:reader];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReaderSupport *)codeReader
{
    return [self initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:true];
}

- (id)initWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReaderSupport *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
    if ((self = [super init])) {
        self.view.backgroundColor = [UIColor blackColor];
        self.codeReader           = codeReader;
        self.startScanningAtLoad  = startScanningAtLoad;
        
        if (cancelTitle == nil) {
            cancelTitle = NSLocalizedString(@"取消扫描", @"取消扫描");
        }
        
        [self setupUIComponentsWithCancelButtonTitle:cancelTitle];
        [self setupAutoLayoutConstraints];
        
        [_cameraView.layer insertSublayer:_codeReader.previewLayer atIndex:0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        
        __weak typeof(self) weakSelf = self;
        
        [codeReader setCompletionWithBlock:^(NSString *resultAsString) {
            if (weakSelf.completionBlock != nil) {
                weakSelf.completionBlock(resultAsString);
            }
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(reader:didScanResult:)]) {
                [weakSelf.delegate reader:weakSelf didScanResult:resultAsString];
            }
        }];
    }
    return self;
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle];
}

+ (instancetype)readerWithMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [[self alloc] initWithMetadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle metadataObjectTypes:(NSArray *)metadataObjectTypes
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle metadataObjectTypes:metadataObjectTypes];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReaderSupport *)codeReader
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader];
}

+ (instancetype)readerWithCancelButtonTitle:(NSString *)cancelTitle codeReader:(QRCodeReaderSupport *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad
{
    return [[self alloc] initWithCancelButtonTitle:cancelTitle codeReader:codeReader startScanningAtLoad:startScanningAtLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_startScanningAtLoad) {
        [self startScanning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopScanning];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    _codeReader.previewLayer.frame = self.view.bounds;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - Controlling the Reader

- (void)startScanning {
    [_codeReader startScanning];
    
    [_cameraView startScanning];
}

- (void)stopScanning {
    [_codeReader stopScanning];
    
    [_cameraView stopScanning];
}

#pragma mark - Managing the Orientation

- (void)orientationChanged:(NSNotification *)notification
{
    [_cameraView setNeedsDisplay];
    
    if (_codeReader.previewLayer.connection.isVideoOrientationSupported) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        _codeReader.previewLayer.connection.videoOrientation = [QRCodeReaderSupport videoOrientationFromInterfaceOrientation:
                                                                orientation];
    }
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
    self.cameraView                                       = [[QRCodeReaderView alloc] init];
    _cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    _cameraView.clipsToBounds                             = YES;
    [self.view addSubview:_cameraView];
    
    [_codeReader.previewLayer setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    if ([_codeReader.previewLayer.connection isVideoOrientationSupported]) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        _codeReader.previewLayer.connection.videoOrientation = [QRCodeReaderSupport videoOrientationFromInterfaceOrientation:orientation];
    }
    
    self.cancelButton                                       = [[UIButton alloc] init];
    _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
}

- (void)setupAutoLayoutConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_cameraView, _cancelButton);
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_cameraView][_cancelButton(40)]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_cameraView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_cancelButton]-|" options:0 metrics:nil views:views]];
    
    if (_switchCameraButton) {
        NSDictionary *switchViews = NSDictionaryOfVariableBindings(_switchCameraButton);
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_switchCameraButton(50)]" options:0 metrics:nil views:switchViews]];
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:[_switchCameraButton(70)]|" options:0 metrics:nil views:switchViews]];
    }
}

- (void)switchDeviceInput
{
    [_codeReader switchDeviceInput];
}

#pragma mark - Catching Button Events

- (void)cancelAction:(UIButton *)button
{
    [_codeReader stopScanning];
    
    if (_completionBlock) {
        _completionBlock(nil);
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(readerDidCancel:)]) {
        [_delegate readerDidCancel:self];
    }
}

- (void)switchCameraAction:(UIButton *)button
{
    [self switchDeviceInput];
}

@end

/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

@implementation QRCameraSwitchButton

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _edgeColor            = [UIColor whiteColor];
        _fillColor            = [UIColor darkGrayColor];
        _edgeHighlightedColor = [UIColor whiteColor];
        _fillHighlightedColor = [UIColor blackColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat width  = rect.size.width;
    CGFloat height = rect.size.height;
    CGFloat center = width / 2;
    CGFloat middle = height / 2;
    
    CGFloat strokeLineWidth = 2;
    
    // Colors
    
    UIColor *paintColor  = (self.state != UIControlStateHighlighted) ? _fillColor : _fillHighlightedColor;
    UIColor *strokeColor = (self.state != UIControlStateHighlighted) ? _edgeColor : _edgeHighlightedColor;
    
    // Camera box
    
    CGFloat cameraWidth  = width * 0.4;
    CGFloat cameraHeight = cameraWidth * 0.6;
    CGFloat cameraX      = center - cameraWidth / 2;
    CGFloat cameraY      = middle - cameraHeight / 2;
    CGFloat cameraRadius = cameraWidth / 80;
    
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(cameraX, cameraY, cameraWidth, cameraHeight) cornerRadius:cameraRadius];
    
    // Camera lens
    
    CGFloat outerLensSize = cameraHeight * 0.8;
    CGFloat outerLensX    = center - outerLensSize / 2;
    CGFloat outerLensY    = middle - outerLensSize / 2;
    
    CGFloat innerLensSize = outerLensSize * 0.7;
    CGFloat innerLensX    = center - innerLensSize / 2;
    CGFloat innerLensY    = middle - innerLensSize / 2;
    
    UIBezierPath *outerLensPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(outerLensX, outerLensY, outerLensSize, outerLensSize)];
    UIBezierPath *innerLensPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(innerLensX, innerLensY, innerLensSize, innerLensSize)];
    
    // Draw flash box
    
    CGFloat flashBoxWidth      = cameraWidth * 0.8;
    CGFloat flashBoxHeight     = cameraHeight * 0.17;
    CGFloat flashBoxDeltaWidth = flashBoxWidth * 0.14;
    CGFloat flashLeftMostX     = cameraX + (cameraWidth - flashBoxWidth) * 0.5;
    CGFloat flashBottomMostY   = cameraY;
    
    UIBezierPath *flashPath = [UIBezierPath bezierPath];
    [flashPath moveToPoint:CGPointMake(flashLeftMostX, flashBottomMostY)];
    [flashPath addLineToPoint:CGPointMake(flashLeftMostX + flashBoxWidth, flashBottomMostY)];
    [flashPath addLineToPoint:CGPointMake(flashLeftMostX + flashBoxWidth - flashBoxDeltaWidth, flashBottomMostY - flashBoxHeight)];
    [flashPath addLineToPoint:CGPointMake(flashLeftMostX + flashBoxDeltaWidth, flashBottomMostY - flashBoxHeight)];
    [flashPath closePath];
    
    flashPath.lineCapStyle = kCGLineCapRound;
    flashPath.lineJoinStyle = kCGLineJoinRound;
    
    // Arrows
    
    CGFloat arrowHeadHeigth = cameraHeight * 0.5;
    CGFloat arrowHeadWidth  = ((width - cameraWidth) / 2) * 0.3;
    CGFloat arrowTailHeigth = arrowHeadHeigth * 0.6;
    CGFloat arrowTailWidth  = ((width - cameraWidth) / 2) * 0.7;
    
    // Draw left arrow
    
    CGFloat arrowLeftX = center - cameraWidth * 0.2;
    CGFloat arrowLeftY = middle + cameraHeight * 0.45;
    
    UIBezierPath *leftArrowPath = [UIBezierPath bezierPath];
    [leftArrowPath moveToPoint:CGPointMake(arrowLeftX, arrowLeftY)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY - arrowHeadHeigth / 2)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY - arrowTailHeigth / 2)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth - arrowTailWidth, arrowLeftY - arrowTailHeigth / 2)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth - arrowTailWidth, arrowLeftY + arrowTailHeigth / 2)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY + arrowTailHeigth / 2)];
    [leftArrowPath addLineToPoint:CGPointMake(arrowLeftX - arrowHeadWidth, arrowLeftY + arrowHeadHeigth / 2)];
    [leftArrowPath closePath];
    
    // Right arrow
    
    CGFloat arrowRightX = center + cameraWidth * 0.2;
    CGFloat arrowRightY = middle + cameraHeight * 0.60;
    
    UIBezierPath *rigthArrowPath = [UIBezierPath bezierPath];
    [rigthArrowPath moveToPoint:CGPointMake(arrowRightX, arrowRightY)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY - arrowHeadHeigth / 2)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY - arrowTailHeigth / 2)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth + arrowTailWidth, arrowRightY - arrowTailHeigth / 2)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth + arrowTailWidth, arrowRightY + arrowTailHeigth / 2)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY + arrowTailHeigth / 2)];
    [rigthArrowPath addLineToPoint:CGPointMake(arrowRightX + arrowHeadWidth, arrowRightY + arrowHeadHeigth / 2)];
    [rigthArrowPath closePath];
    
    // Drawing
    
    [paintColor setFill];
    [rigthArrowPath fill];
    [strokeColor setStroke];
    rigthArrowPath.lineWidth = strokeLineWidth;
    [rigthArrowPath stroke];
    
    [paintColor setFill];
    [boxPath fill];
    [strokeColor setStroke];
    boxPath.lineWidth = strokeLineWidth;
    [boxPath stroke];
    
    [strokeColor setFill];
    [outerLensPath fill];
    
    [paintColor setFill];
    [innerLensPath fill];
    
    [paintColor setFill];
    [flashPath fill];
    [strokeColor setStroke];
    flashPath.lineWidth = strokeLineWidth;
    [flashPath stroke];
    
    [paintColor setFill];
    [leftArrowPath fill];
    [strokeColor setStroke];
    leftArrowPath.lineWidth = strokeLineWidth;
    [leftArrowPath stroke];
}

// MARK: - UIResponder Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    [self setNeedsDisplay];
}

@end


/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/


#define DeviceWidth [UIScreen mainScreen].bounds.size.width
#define DeviceHeight [UIScreen mainScreen].bounds.size.height
#define DeviceFrame [UIScreen mainScreen].bounds

static const float CancelButtonHeight = 40;
static const float ReaderViewLengthRatio = 0.72;

@interface QRCodeReaderView ()
@property (nonatomic, strong) QRCodeReaderAanimationLineView *animationLine;
@property (nonatomic, strong) NSTimer *lineTimer;
@property (nonatomic) QRCodeReaderMaskView *maskView;

@property (nonatomic) float animationLineMaxY;
@property (nonatomic) float animationLineMinY;
@property (nonatomic) float readerViewSideLength;
@end

@implementation QRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initSettingValue];
        [self setOverlayPickerView];
    }
    
    return self;
}

- (void)initSettingValue {
    _readerViewSideLength = DeviceWidth * ReaderViewLengthRatio;
    _animationLineMinY = (DeviceHeight - 20  - _readerViewSideLength - CancelButtonHeight) / 2;
    _animationLineMaxY = _animationLineMinY + _readerViewSideLength;
}

- (QRCodeReaderAanimationLineView *)animationLine {
    if(_animationLine == nil) {
        _animationLine = [[QRCodeReaderAanimationLineView alloc] initWithFrame:CGRectMake((DeviceWidth - _readerViewSideLength) / 2, 0, _readerViewSideLength, 12 * self.readerViewSideLength / DeviceWidth) minY:self.animationLineMinY maxY:self.animationLineMaxY];
    }
    return _animationLine;
}

#pragma mark - Private Methods
- (void)setOverlayPickerView
{
    // Add line in the middle.
    [self addSubview:self.animationLine];
    
    // Add mask view
    UIView* maskTopView = [[QRCodeReaderMaskView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, self.animationLineMinY)];
    [self addSubview:maskTopView];
    
    UIView *maskLeftView = [[QRCodeReaderMaskView alloc] initWithFrame:CGRectMake(0, self.animationLineMinY, (DeviceWidth - self.readerViewSideLength) / 2.0, self.readerViewSideLength)];
    [self addSubview:maskLeftView];
    
    UIView *maskRightView = [[QRCodeReaderMaskView alloc] initWithFrame:CGRectMake(DeviceWidth - CGRectGetMaxX(maskLeftView.frame), self.animationLineMinY, CGRectGetMaxX(maskLeftView.frame), self.readerViewSideLength)];
    [self addSubview:maskRightView];
    
    CGFloat space_h = DeviceHeight - self.animationLineMaxY;
    
    UIView *maskBottomView = [[QRCodeReaderMaskView alloc] initWithFrame:CGRectMake(0, self.animationLineMaxY, DeviceWidth, space_h)];
    [self addSubview:maskBottomView];
    
    CGFloat scanCropViewWidth = DeviceWidth - 2 * CGRectGetMaxX(maskLeftView.frame) + 1;
    UIView *scanCropView = [[UIView alloc] initWithFrame:CGRectMake((DeviceWidth - scanCropViewWidth)/2, self.animationLineMinY-1.0, scanCropViewWidth, self.readerViewSideLength + 2)];
    scanCropView.layer.borderColor = [UIColor whiteColor].CGColor;
    scanCropView.layer.borderWidth = 1.0;
    [self addSubview:scanCropView];
    
    // Add cornet Image
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    UIImageView *topLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(maskLeftView.frame) - 1.0, CGRectGetMaxY(maskTopView.frame) - 1.0, cornerImage.size.width, cornerImage.size.height)];
    topLeftImageView.image = cornerImage;
    [self addSubview:topLeftImageView];
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    UIImageView *topRightImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(maskRightView.frame) - cornerImage.size.width + 1.0, CGRectGetMaxY(maskTopView.frame) - 1.0, cornerImage.size.width, cornerImage.size.height)];
    topRightImage.image = cornerImage;
    [self addSubview:topRightImage];
    
    cornerImage = [UIImage imageNamed:@"QRCodeBottomLeft"];
    UIImageView *bottomLeftImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(maskLeftView.frame) - 1.0, CGRectGetMinY(maskBottomView.frame) - cornerImage.size.height + 2.0, cornerImage.size.width, cornerImage.size.height)];
    bottomLeftImage.image = cornerImage;
    [self addSubview:bottomLeftImage];
    
    cornerImage = [UIImage imageNamed:@"QRCodeBottomRight"];
    UIImageView *bottomRightImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(maskRightView.frame) - cornerImage.size.width + 1.0, CGRectGetMinY(maskBottomView.frame) - cornerImage.size.height + 2.0, cornerImage.size.width, cornerImage.size.height)];
    bottomRightImage.image = cornerImage;
    [self addSubview:bottomRightImage];
    
    //说明label
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(maskLeftView.frame), CGRectGetMinY(maskBottomView.frame) + 25, self.readerViewSideLength, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将二维码置于框内, 即可自动扫描";
    [self addSubview:labIntroudction];
    
    
}

- (void)startScanning
{
    _lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 50 target:self selector:@selector(animationForLine) userInfo:nil repeats:YES];
}

- (void)stopScanning
{
    if (_lineTimer)
    {
        [_lineTimer invalidate];
        _lineTimer = nil;
    }
    
}

- (void)animationForLine
{
    [self.animationLine startAnimation];
}

@end

/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

@implementation QRCodeReaderMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return  self;
}

- (void)setup {
    self.alpha = 0.5;
    self.backgroundColor = [UIColor blackColor];
}

@end

/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

@interface QRCodeReaderAanimationLineView ()

@property (nonatomic) float minY;
@property (nonatomic) float maxY;
@end

@implementation QRCodeReaderAanimationLineView

- (instancetype)initWithFrame:(CGRect)frame minY:(float)minY maxY:(float)maxY {
    if (self = [super initWithFrame:frame]) {
        _minY = minY;
        _maxY = maxY;
        [self setup];
    }
    
    return  self;
}

- (void)setup {
    self.image = [UIImage imageNamed:@"QRCodeLine"];
}

- (void)startAnimation
{
    __block CGRect frame = self.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = self.minY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 50 animations:^{
            
            frame.origin.y += 2;
            self.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (self.frame.origin.y >= self.minY)
        {
            if (self.frame.origin.y >= self.maxY - 12)
            {
                frame.origin.y = self.minY;
                self.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 50 animations:^{
                    
                    frame.origin.y += 2;
                    self.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
    
}


@end
