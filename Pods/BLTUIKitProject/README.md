BLT控件库说明：
封装了BLT常用的一些弹框，目前有Alert、NoticeBar，使用demo地址参见：http://liubin@bitbucket.baletoo.com/scm/app/bltuikitproject.git
Alert库依赖详见配置文件：http://bitbucket.baletoo.com/projects/APP/repos/bltuikitproject/browse/BLTUIKitProject.podspec
Alert目前分三种样式，三种样式属性设置alert样式的alert开头，sheet样式的sheet开头，feedAlert样式的feed开头。sheet和feedAlert也会用到一些alert公用的属性。
快速初始化的方法：
+ (instancetype)alertControllerWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style;
/** 快速初始化的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *cancelAction))sureBlock;
/** 快速初始化取消  确定按钮的 */
- (instancetype)initWithTitle:(NSString *)title mesage:(NSString *)message style:(BLTAlertControllerStyle)style cancelTitle:(NSString *)cancelTitle cancelBlock:(void(^)(BLTAlertAction *cancelAction))cancelBlock sureTitle:(NSString *)sureTitle sureBlock:(void(^)(BLTAlertAction *sureAction))sureBlock;
展示的时候不用presentVC的方法，考虑到可能会出现调用的VC.view的方法又没有presentVC的时候走viewDidload就开始布局展现样式的。所以自己提供方法控制。使用showWithAnimated来展示alert。
对于按钮和textField需要自定义的，可以根据暴露出来的方法来自己根据业务处理。间距、外观、富文本、可以根据提供的属性设置。