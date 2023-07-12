# BLTAlertEventQueueManager使用

### BLTAlertEventQueueManager 和 BLTAlertEventQueueModel 简介
#### 1. BLTAlertEventQueueManager
1. 初始化方法及必须调用方法
> * `-initWithViewController:` : 初始化方法，需要传入当前持有`manager`的控制器。
> * `-controllerViewWillAppear` : 在控制器的`-viewWillAppear:`方法中调用，用于控制弹窗管理队列的各种状态。（比如在弹窗队列未开始前跳转到其他界面时暂停弹出，返回对应页面时继续弹出；点击弹窗内容跳转其他页面暂停弹出，返回时继续弹出其他弹窗等）
> * `-viewWillDisappear:` : 用于判断是否离开页面，当离开`manager`的持有页面时，暂停弹窗的弹出。

2. 弹窗管理方法
> * `-addAlertInfo:` : 添加弹窗到队列。
> * `-startAlert` : 开始弹窗队列。
> * `-continueAlert` : 继续弹窗队列。弹窗队列的继续弹出需要手动控制，当弹出一个弹窗后，想继续弹出下一个弹窗，需要在当前弹窗的`消失回调`中调用该方法。（当暂停弹窗后，继续弹窗也需要调用该方法，但这些逻辑已在`-controllerViewWillAppear`方法中处理，无需手动处理）
> * `-insertAlertInfo:` : 在弹窗队列开始执行后，弹出临时弹窗。
> * `-hiddenCurrentAlert` : 隐藏当前弹窗。当点击弹窗内容，跳转页面时，需要保留该弹窗，又不能让其释放是，可调用该方法临时隐藏，当返回页面时，在`-controllerViewWillAppear`方法中已处理其显示逻辑，无需另外处理。
> * `gotoAlertContentPage` : 当点击弹窗内容跳转页面，并结束弹窗时，调用该方法，无需调用`-continueAlert`，在返回该页面时，`-controllerViewWillAppear`方法中已经处理了弹窗的`-continueAlert`，无需另外处理。

**注意：`-continueAlert`，`-insertAlertInfo:`，`-hiddenCurrentAlert`，`-gotoAlertContentPage`皆为互斥，当调用或者设置其中一个状态时，不能再修改其他的状态**

3. 队列
> 1. `group_t`: group队列，用于控制弹窗队列的开始的时机，和确保多弹窗已添加到队列。

#### 2. BLTAlertEventQueueModel
> `alertPriority`: `BLTAlertQueuePriority`枚举，表示弹窗优先级。业务弹窗优先级最低，依次为活动优先级，和最高优先级，优先级低的后弹出。
> `alertLevel` : 弹窗等级，用于控制同一优先级弹窗中，某些弹窗优先级更高的处理。默认为`INT_MAX`，`alertLevel`值越小，等级越高，越先展示。
> `alert` : 弹窗，分为`UIView` 和 `UIViewController` 两类
> `alertSelString` : 弹窗的显示方法，如果属性有值，则调用传入的方法显示弹窗，如果该属性无值，`alert`为`UIView`时，直接显示下一个弹窗，为`UIViewController`时。调用`presentViewController`方法显示弹窗。
