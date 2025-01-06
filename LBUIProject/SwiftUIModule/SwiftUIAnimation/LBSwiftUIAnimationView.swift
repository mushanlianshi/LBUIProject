//
//  LBSwiftUIAnimationView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/9/18.
//

import SwiftUI

///SwiftUI动画三种方式
///1.通过将状态改变包裹在全局函数 withAnimation(_:_:) 的调用中，可以为状态变化引起的所有视觉变化添加动画效果。
///2.通过在 View 上使用 animation(_:value:) 修饰符，在特定值改变时为该视图添加动画效果。
///3.使用绑定变量的 animation(_:) 方法，对绑定变量的变化进行动画处理。
struct LBSwiftUIAnimationView: View {
    var body: some View {
        VStack(spacing: 10) {
            LBSwiftUIAnimationByWithAnimationView();
            LBSwiftUIAnimationByViewAnimationView();
            LBSwiftUIAnimationByBindVariableView()
        }.padding(EdgeInsets(top: 100, leading: 0, bottom: 100, trailing: 0))
    }
}


///第一种使用全局函数withAnimation来实现的
fileprivate struct LBSwiftUIAnimationByWithAnimationView: View {
    @State private var x1: CGFloat = 0
    
    var body: some View {
        Circle()
            .frame(width: 64, height: 64)
            .foregroundColor(.red)
            .position(x: x1, y: 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5)){
                    x1 = 200
                }
            }
    }
}

///第二种使用View的Animation方法
fileprivate struct LBSwiftUIAnimationByViewAnimationView: View {
    @State private var x2: CGFloat = 0
    
    var body: some View {
        Circle()
            .frame(width: 64, height: 64)
            .foregroundColor(.red)
            .position(x: x2, y: 0)
            .animation(.easeInOut(duration: 1), value: x2)
            .onAppear {
                x2 = 200
            }
    }
}

///第三种使用绑定变量的方法
fileprivate struct LBSwiftUIAnimationByBindVariableView: View {
  @State private var x3: CGFloat = 0.0

  var body: some View {
      SubCircleView(x3: $x3.animation(.easeInOut(duration: 1.5)))
  }
}

fileprivate struct SubCircleView: View {
  @Binding var x3: CGFloat
  var body: some View {
    Circle()
      .frame(width: 64, height: 64)
      .foregroundColor(.red)
      .position(x: x3, y: 0)
      .onAppear {
        x3 = 200
      }
  }
}

struct LBSwiftUIAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        LBSwiftUIAnimationView()
    }
}
