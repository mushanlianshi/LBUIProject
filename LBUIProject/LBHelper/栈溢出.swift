//
//  栈溢出.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import Foundation
//
//一般对于递归，解决栈溢出的一个好方法是采用尾递归的写法。顾名思义，尾递归就是让函数里 的最后一个动作是一个函数调用的形式，这个调用的返回值将直接被当前函数返回，从而避免在 栈上保存状态。这样一来程序就可以更新最后的栈帧，而不是新建一个，来避免栈溢出的发生。
////   n比较大的时候 栈溢出
func sum(_ n: UInt) -> UInt {
   if n == 0 {
       return 0
   }
   return n + sum(n - 1)
}

//    解决栈溢出
func tailSum(_ n: UInt) -> UInt {
   func sumInternal(_ n: UInt, current: UInt) -> UInt {
       if n == 0 {
           return current
       } else {
           return sumInternal(n - 1, current: current + n)
} }
   return sumInternal(n, current: 0)
}

//    解决栈溢出
func tailSum2(_ n: UInt) -> UInt {
   func sumInternal(_ n: UInt) -> UInt {
       if n == 0 {
           return 0
       } else {
           return n + sumInternal(n - 1)
} }
   return sumInternal(n)
}
