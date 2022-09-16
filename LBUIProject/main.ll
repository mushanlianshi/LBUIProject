; ModuleID = 'main.m'
source_filename = "main.m"
target datalayout = "e-m:o-i64:64-i128:128-n32:64-S128"
target triple = "arm64-apple-ios15.2.0"

%0 = type opaque
%struct.__NSConstantString_tag = type { i32*, i32, i8*, i64 }
%struct._class_t = type { %struct._class_t*, %struct._class_t*, %struct._objc_cache*, i8* (i8*, i8*)**, %struct._class_ro_t* }
%struct._objc_cache = type opaque
%struct._class_ro_t = type { i32, i32, i32, i8*, i8*, %struct.__method_list_t*, %struct._objc_protocol_list*, %struct._ivar_list_t*, i8*, %struct._prop_list_t* }
%struct.__method_list_t = type { i32, i32, [0 x %struct._objc_method] }
%struct._objc_method = type { i8*, i8*, i8* }
%struct._objc_protocol_list = type { i64, [0 x %struct._protocol_t*] }
%struct._protocol_t = type { i8*, i8*, %struct._objc_protocol_list*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct.__method_list_t*, %struct._prop_list_t*, i32, i32, i8**, i8*, %struct._prop_list_t* }
%struct._ivar_list_t = type { i32, i32, [0 x %struct._ivar_t] }
%struct._ivar_t = type { i32*, i8*, i8*, i32, i32 }
%struct._prop_list_t = type { i32, i32, [0 x %struct._prop_t] }
%struct._prop_t = type { i8*, i8* }

@.str = private unnamed_addr constant [26 x i8] c"LBLog main ==============\00", align 1
@__CFConstantStringClassReference = external global [0 x i32]
@.str.1 = private unnamed_addr constant [10 x i8] c"wewfwfwef\00", section "__TEXT,__cstring,cstring_literals", align 1
@_unnamed_cfstring_ = private global %struct.__NSConstantString_tag { i32* getelementptr inbounds ([0 x i32], [0 x i32]* @__CFConstantStringClassReference, i32 0, i32 0), i32 1992, i8* getelementptr inbounds ([10 x i8], [10 x i8]* @.str.1, i32 0, i32 0), i64 9 }, section "__DATA,__cfstring", align 8 #0
@"OBJC_CLASS_$_AppDelegate" = external global %struct._class_t
@"OBJC_CLASSLIST_REFERENCES_$_" = internal global %struct._class_t* @"OBJC_CLASS_$_AppDelegate", section "__DATA,__objc_classrefs,regular,no_dead_strip", align 8
@llvm.compiler.used = appending global [1 x i8*] [i8* bitcast (%struct._class_t** @"OBJC_CLASSLIST_REFERENCES_$_" to i8*)], section "llvm.metadata"

; Function Attrs: noinline optnone ssp uwtable
define i32 @main(i32 %0, i8** %1) #1 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca %0*, align 8
  %7 = alloca %0*, align 8
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %8 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str, i64 0, i64 0))
  %9 = call i8* @llvm.objc.retain(i8* bitcast (%struct.__NSConstantString_tag* @_unnamed_cfstring_ to i8*)) #3
  %10 = bitcast i8* %9 to %0*
  store %0* %10, %0** %6, align 8
  store %0* null, %0** %7, align 8
  %11 = call i8* @llvm.objc.autoreleasePoolPush() #3
  %12 = load %struct._class_t*, %struct._class_t** @"OBJC_CLASSLIST_REFERENCES_$_", align 8
  %13 = bitcast %struct._class_t* %12 to i8*
  %14 = call i8* @objc_opt_class(i8* %13)
  %15 = call %0* @NSStringFromClass(i8* %14)
  call void asm sideeffect "mov\09fp, fp\09\09// marker for objc_retainAutoreleaseReturnValue", ""()
  %16 = bitcast %0* %15 to i8*
  %17 = call i8* @llvm.objc.retainAutoreleasedReturnValue(i8* %16) #3
  %18 = bitcast i8* %17 to %0*
  %19 = load %0*, %0** %7, align 8
  store %0* %18, %0** %7, align 8
  %20 = bitcast %0* %19 to i8*
  call void @llvm.objc.release(i8* %20) #3, !clang.imprecise_release !13
  call void @llvm.objc.autoreleasePoolPop(i8* %11)
  %21 = load i32, i32* %4, align 4
  %22 = load i8**, i8*** %5, align 8
  %23 = load %0*, %0** %7, align 8
  %24 = call i32 @UIApplicationMain(i32 %21, i8** %22, %0* null, %0* %23)
  store i32 %24, i32* %3, align 4
  %25 = bitcast %0** %7 to i8**
  call void @llvm.objc.storeStrong(i8** %25, i8* null) #3
  %26 = bitcast %0** %6 to i8**
  call void @llvm.objc.storeStrong(i8** %26, i8* null) #3
  %27 = load i32, i32* %3, align 4
  ret i32 %27
}

declare i32 @printf(i8*, ...) #2

; Function Attrs: nounwind
declare i8* @llvm.objc.retain(i8*) #3

; Function Attrs: nounwind
declare i8* @llvm.objc.autoreleasePoolPush() #3

declare %0* @NSStringFromClass(i8*) #2

declare i8* @objc_opt_class(i8*)

; Function Attrs: nounwind
declare i8* @llvm.objc.retainAutoreleasedReturnValue(i8*) #3

; Function Attrs: nounwind
declare void @llvm.objc.release(i8*) #3

; Function Attrs: nounwind
declare void @llvm.objc.autoreleasePoolPop(i8*) #3

declare i32 @UIApplicationMain(i32, i8**, %0*, %0*) #2

; Function Attrs: nounwind
declare void @llvm.objc.storeStrong(i8**, i8*) #3

attributes #0 = { "objc_arc_inert" }
attributes #1 = { noinline optnone ssp uwtable "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-a7" "target-features"="+aes,+crypto,+fp-armv8,+neon,+sha2,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "disable-tail-calls"="false" "frame-pointer"="non-leaf" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "probe-stack"="__chkstk_darwin" "stack-protector-buffer-size"="8" "target-cpu"="apple-a7" "target-features"="+aes,+crypto,+fp-armv8,+neon,+sha2,+zcm,+zcz" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9, !10, !11}
!llvm.ident = !{!12}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 15, i32 2]}
!1 = !{i32 1, !"Objective-C Version", i32 2}
!2 = !{i32 1, !"Objective-C Image Info Version", i32 0}
!3 = !{i32 1, !"Objective-C Image Info Section", !"__DATA,__objc_imageinfo,regular,no_dead_strip"}
!4 = !{i32 1, !"Objective-C Garbage Collection", i8 0}
!5 = !{i32 1, !"Objective-C Class Properties", i32 64}
!6 = !{i32 1, !"wchar_size", i32 4}
!7 = !{i32 1, !"branch-target-enforcement", i32 0}
!8 = !{i32 1, !"sign-return-address", i32 0}
!9 = !{i32 1, !"sign-return-address-all", i32 0}
!10 = !{i32 1, !"sign-return-address-with-bkey", i32 0}
!11 = !{i32 7, !"PIC Level", i32 2}
!12 = !{!"Apple clang version 13.0.0 (clang-1300.0.29.30)"}
!13 = !{}
