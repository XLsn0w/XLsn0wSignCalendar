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

#import <UIKit/UIKit.h>

#import "QRCodeReaderSupport.h"

@class XLsn0wQRCodeReader;

/**
 * This protocol defines delegate methods for objects that implements the
 * `QRCodeReaderDelegate`. The methods of the protocol allow the delegate to be
 * notified when the reader did scan result and or when the user wants to stop
 * to read some QRCodes.
 */
@protocol QRCodeReaderDelegate <NSObject>

@optional

#pragma mark - Listening for Reader Status
/** @name Listening for Reader Status */

/**
 * @abstract Tells the delegate that the reader did scan a QRCode.
 * @param reader The reader view controller that scanned a QRCode.
 * @param result The content of the QRCode as a string.
 * @since 1.0.0
 */
- (void)reader:(XLsn0wQRCodeReader * _Nullable)reader didScanResult:(NSString * _Nullable)result;

/**
 * @abstract Tells the delegate that the user wants to stop scanning QRCodes.
 * @param reader The reader view controller that the user wants to stop.
 * @since 1.0.0
 */
- (void)readerDidCancel:(XLsn0wQRCodeReader * _Nullable)reader;

@end

/**
 * Convenient controller to display a view to scan/read 1D or 2D bar codes like
 * the QRCodes. It is based on the `AVFoundation` framework from Apple. It aims
 * to replace ZXing or ZBar for iOS 7 and over.
 */
@interface XLsn0wQRCodeReader : UIViewController

#pragma mark - Creating and Inializing QRCodeReader Controllers
/** @name Creating and Inializing QRCode Reader Controllers */

/**
 * @abstract Initializes a view controller to read QRCodes from a displayed
 * video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 * @discussion This convenient method is used to instanciate a reader with
 * only one supported metadata object types: the QRCode.
 * @see initWithCancelButtonTitle:metadataObjectTypes:
 * @since 1.0.0
 */
- (nonnull id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle;

/**
 * @abstract Creates a view controller to read QRCodes from a displayed
 * video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 * @see initWithCancelButtonTitle:
 * @since 1.0.0
 */
+ (nonnull instancetype)readerWithCancelButtonTitle:(nullable NSString *)cancelTitle;

/**
 * @abstract Initializes a reader view controller with a list of metadata
 * object types.
 * @param metadataObjectTypes An array of strings identifying the types of
 * metadata objects to process.
 * @see initWithCancelButtonTitle:metadataObjectTypes:
 * @since 3.0.0
 */
- (nonnull id)initWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;

/**
 * @abstract Creates a reader view controller with a list of metadata object
 * types.
 * @param metadataObjectTypes An array of strings identifying the types of
 * metadata objects to process.
 * @see initWithMetadataObjectTypes:
 * @since 3.0.0
 */
+ (nonnull instancetype)readerWithMetadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;

/**
 * @abstract Initializes a view controller to read wanted metadata object
 * types from a displayed video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 * @param metadataObjectTypes The type (“symbology”) of barcode to scan.
 * @see initWithCancelButtonTitle:codeReader:
 * @since 2.0.0
 */
- (nonnull id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle metadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;

/**
 * @abstract Creates a view controller to read wanted metadata object types
 * from a displayed video preview and a cancel button to be go back.
 * @param cancelTitle The title of the cancel button.
 * @param metadataObjectTypes The type (“symbology”) of barcode to scan.
 * @see initWithCancelButtonTitle:metadataObjectTypes:
 * @since 2.0.0
 */
+ (nonnull instancetype)readerWithCancelButtonTitle:(nullable NSString *)cancelTitle metadataObjectTypes:(nonnull NSArray *)metadataObjectTypes;

/**
 * @abstract Initializes a view controller using a cancel button title and
 * a code reader.
 * @param cancelTitle The title of the cancel button.
 * @param codeReader The reader to decode the codes.
 * @see initWithCancelButtonTitle:codeReader:startScanningAtLoad:
 * @since 3.0.0
 */
- (nonnull id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReaderSupport *)codeReader;

/**
 * @abstract Initializes a view controller using a cancel button title and
 * a code reader.
 * @param cancelTitle The title of the cancel button.
 * @param codeReader The reader to decode the codes.
 * @see initWithCancelButtonTitle:codeReader:
 * @since 3.0.0
 */
+ (nonnull instancetype)readerWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReaderSupport *)codeReader;

/**
 * @abstract Initializes a view controller using a cancel button title and
 * a code reader.
 * @param cancelTitle The title of the cancel button.
 * @param codeReader The reader to decode the codes.
 * @param startScanningAtLoad Flag to know whether the view controller start scanning the codes when the view will appear.
 * @since 3.0.0
 */
- (nonnull id)initWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReaderSupport *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad;

/**
 * @abstract Initializes a view controller using a cancel button title and
 * a code reader.
 * @param cancelTitle The title of the cancel button.
 * @param codeReader The reader to decode the codes.
 * @param startScanningAtLoad Flag to know whether the view controller start scanning the codes when the view will appear.
 * @see initWithCancelButtonTitle:codeReader:startScanningAtLoad:
 * @since 3.0.0
 */
+ (nonnull instancetype)readerWithCancelButtonTitle:(nullable NSString *)cancelTitle codeReader:(nonnull QRCodeReaderSupport *)codeReader startScanningAtLoad:(BOOL)startScanningAtLoad;

#pragma mark - Controlling the Reader
/** @name Controlling the Reader */

/**
 * @abstract Starts scanning the codes.
 * @since 3.0.0
 */
- (void)startScanning;

/**
 * @abstract Stops scanning the codes.
 * @since 3.0.0
 */
- (void)stopScanning;

#pragma mark - Managing the Delegate
/** @name Managing the Delegate */

/**
 * @abstract The object that acts as the delegate of the receiving QRCode
 * reader.
 * @since 1.0.0
 */
@property (nonatomic, weak) id<QRCodeReaderDelegate> __nullable delegate;

/**
 * @abstract Sets the completion with a block that executes when a QRCode
 * or when the user did stopped the scan.
 * @param completionBlock The block to be executed. This block has no
 * return value and takes one argument: the `resultAsString`. If the user
 * stop the scan and that there is no response the `resultAsString` argument
 * is nil.
 * @since 1.0.1
 */
- (void)setCompletionWithBlock:(nullable void (^) (NSString * __nullable resultAsString))completionBlock;

#pragma mark - Managing the Reader
/** @name Managing the Reader */

/**
 * @abstract The default code reader created with the controller.
 * @since 3.0.0
 */
@property (strong, nonatomic, readonly) QRCodeReaderSupport * __nonnull codeReader;

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

/**
 * The camera switch button.
 * @since 2.0.0
 */
@interface QRCameraSwitchButton : UIButton

#pragma mark - Managing Properties
/** @name Managing Properties */

/**
 * @abstract The edge color of the drawing.
 * @discussion The default color is the white.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor * _Nullable edgeColor;

/**
 * @abstract The fill color of the drawing.
 * @discussion The default color is the darkgray.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor * _Nullable fillColor;

/**
 * @abstract The edge color of the drawing when the button is touched.
 * @discussion The default color is the white.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor * _Nullable edgeHighlightedColor;

/**
 * @abstract The fill color of the drawing when the button is touched.
 * @discussion The default color is the black.
 * @since 2.0.0
 */
@property (nonatomic, strong) UIColor * _Nullable fillHighlightedColor;

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

#import <UIKit/UIKit.h>

/**
 * Overlay over the camera view to display the area (a square) where to scan the
 * code.
 * @since 2.0.0
 */
@interface QRCodeReaderView : UIView

- (void)startScanning;
- (void)stopScanning;
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

@interface QRCodeReaderMaskView : UIView

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

@interface QRCodeReaderAanimationLineView : UIImageView

- (instancetype _Nullable)initWithFrame:(CGRect)frame minY:(float)minY maxY:(float)maxY;
- (void)startAnimation;

@end


