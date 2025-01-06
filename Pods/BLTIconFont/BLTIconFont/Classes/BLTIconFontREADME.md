# 租客App-iconfont的使用

## 现有字体

1. `BLTGeneralIconfont`,
2. `BLTBusinessIconfont`,
3. 查看地址：https://www.iconfont.cn/manage/index?spm=a313x.7781069.1998910419.11&manage_type=myprojects&projectId=1654382

## 使用方法
    
每个字体都有一个对应的`***Image.h / .m`文件（如：BLTGeneralIconfontImage.h / .m，新增字体类型时需要创建对应该文件），继承自`HQFontImage`类。在父类中提供了对应的一些方法(查看`HQFontImage.h`注释)，子类主要用来设置`IconDictionary`和`fontName`，将`unicode`转换成对应名称，方便设置。

在`BMIconFontDefine`中定义了一些函数，对应各种字体文件转图片的方法，新增字体是需要新增对应字体方法，常用的方法为：

```Objc-C
// 获取图片
BLTMake***Image(NSString *name, CGFloat fontSize, UIColor *color, BOOL defaultAspectRatio);

BLTMake***ImageInset(NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, BOOL defaultAspectRatio)；

// 获取对应的自定义url
BLT***ImageCustomUrlString(NSString *name, CGFloat fontSize, UIColor *color, BOOL defaultAspectRatio);

BLT***ImageCustomUrlStringInset(NSString *name, CGFloat fontSize, UIColor *color, UIEdgeInsets inset, BOOL defaultAspectRatio);

// 当有边距时，高度计算方式为：原始图片高度 - 上下空白边距大小（需要转换成1倍图的大小）
// defaultAspectRatio 字段为YES是，表示使用图片原始比例获取图片，为NO时，得到的图片一定为正方形，推荐直接设置为YES
// *** 为对应字体名称（去掉BLT前缀）
// 自定义url，通过调用`UIImage+BLTIconfontImage`分类中的`+blt_imageWithCodeString:`传入自定义url可转换成图片。（为兼容png图片名称和自定义url混合数组转图片的问题，需要将`+imageWithName:`替换成`+blt_imageWithCodeString:`）
```

# 注意

更新字体时，需要替换`***.ttf`文件，并且替换对应的`***Image.m`文件中的`IconDictionary`。
新增字体类型时，需要创建对应的`***Image.m`文件，并添加`***.ttf`文件。同时在工程的info.plist文件中的`Fonts provided by application`下添加字体文件名称包括`.ttf`后缀(文件名称需和字体fontFamily统一)
