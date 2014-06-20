// RUN: rm -rf %t/clang-module-cache
// RUN: %swift -emit-silgen -module-cache-path %t/clang-module-cache -target x86_64-apple-darwin13 -sdk %S/Inputs -I %S/Inputs -enable-source-import %s | FileCheck %s

import Foundation

class BridgedObjC : NSObject { }

func == (x: BridgedObjC, y: BridgedObjC) -> Bool { return true }

struct BridgedSwift : Hashable, _BridgedToObjectiveC {
  var hashValue: Int { return 0 }

  static func getObjectiveCType() -> Any.Type {
    return BridgedObjC.self
  }
  
  func bridgeToObjectiveC() -> BridgedObjC {
    return BridgedObjC()
  }

  static func bridgeFromObjectiveC(x: BridgedObjC) -> BridgedSwift {
    return BridgedSwift()
  }
}

func == (x: BridgedSwift, y: BridgedSwift) -> Bool { return true }

// CHECK-LABEL: sil @_TF19collection_downcast17testArrayDowncast
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>):
func testArrayDowncast(array: AnyObject[]) -> BridgedObjC[] {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs14_arrayDownCastU___FGSaQ__GSaQ0__ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Array<τ_0_1>
  // CHECK: apply [[DOWNCAST_FN]]<AnyObject, BridgedObjC>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Array<τ_0_1>
  return array as BridgedObjC[]
}

// CHECK-LABEL: sil @_TF19collection_downcast28testArrayDowncastConditional
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>):
func testArrayDowncastConditional(array: AnyObject[]) -> BridgedObjC[]? {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs25_arrayDownCastConditionalU___FGSaQ__GSqGSaQ0___ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  // CHECK-NEXT:  apply [[DOWNCAST_FN]]<AnyObject, BridgedObjC>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  return array as? BridgedObjC[]
}

// CHECK-LABEL: sil @_TF19collection_downcast12testArrayIsa
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>)
func testArrayIsa(array: AnyObject[]) -> Bool {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs25_arrayDownCastConditionalU___FGSaQ__GSqGSaQ0___ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  // CHECK-NEXT: apply [[DOWNCAST_FN]]<AnyObject, BridgedObjC>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  return array is BridgedObjC[] ? true : false
}

// CHECK-LABEL: sil @_TF19collection_downcast24testArrayDowncastBridged
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>):
func testArrayDowncastBridged(array: AnyObject[]) -> BridgedSwift[] {
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs26_arrayBridgeFromObjectiveCU___FGSaQ__GSaQ0__ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Array<τ_0_1>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<AnyObject, BridgedSwift>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Array<τ_0_1>
  return array as BridgedSwift[]
}

// CHECK-LABEL: sil @_TF19collection_downcast35testArrayDowncastBridgedConditional
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>):
func testArrayDowncastBridgedConditional(array: AnyObject[]) -> BridgedSwift[]?{
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs37_arrayBridgeFromObjectiveCConditionalU___FGSaQ__GSqGSaQ0___ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<AnyObject, BridgedSwift>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  return array as? BridgedSwift[]
}

// CHECK-LABEL: sil @_TF19collection_downcast19testArrayIsaBridged
// CHECK: bb0([[ARRAY:%[0-9]+]] : $Array<AnyObject>)
func testArrayIsaBridged(array: AnyObject[]) -> Bool {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs37_arrayBridgeFromObjectiveCConditionalU___FGSaQ__GSqGSaQ0___ : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  // CHECK: apply [[DOWNCAST_FN]]<AnyObject, BridgedSwift>([[ARRAY]]) : $@thin <τ_0_0, τ_0_1> (@owned Array<τ_0_0>) -> @owned Optional<Array<τ_0_1>>
  return array is BridgedSwift[] ? true : false
}

// CHECK-LABEL: sil @_TF19collection_downcast22testDictionaryDowncast
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncast(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedObjC, BridgedObjC> {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs19_dictionaryDownCastUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GS0_Q1_Q2__ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Dictionary<τ_0_2, τ_0_3>
  // CHECK-NEXT: apply [[DOWNCAST_FN]]<NSObject, AnyObject, BridgedObjC, BridgedObjC>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Dictionary<τ_0_2, τ_0_3>
  return dict as Dictionary<BridgedObjC, BridgedObjC>
}

// CHECK-LABEL: sil @_TF19collection_downcast33testDictionaryDowncastConditional
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncastConditional(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedObjC, BridgedObjC>? {
  // CHECK: [[DOWNCAST_FN:%[0-9]+]] = function_ref @_TFSs30_dictionaryDownCastConditionalUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GSqGS0_Q1_Q2___ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  // CHECK-NEXT: apply [[DOWNCAST_FN]]<NSObject, AnyObject, BridgedObjC, BridgedObjC>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  return dict as? Dictionary<BridgedObjC, BridgedObjC>
}

// CHECK-LABEL: sil @_TF19collection_downcast41testDictionaryDowncastBridgedVConditional
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncastBridgedVConditional(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedObjC, BridgedSwift>? {
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs42_dictionaryBridgeFromObjectiveCConditionalUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GSqGS0_Q1_Q2___ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<NSObject, AnyObject, BridgedObjC, BridgedSwift>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>> // user: %6
  return dict as? Dictionary<BridgedObjC, BridgedSwift>
}

// CHECK-LABEL: sil @_TF19collection_downcast41testDictionaryDowncastBridgedKConditional
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncastBridgedKConditional(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedSwift, BridgedObjC>? {
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs42_dictionaryBridgeFromObjectiveCConditionalUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GSqGS0_Q1_Q2___ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<NSObject, AnyObject, BridgedSwift, BridgedObjC>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  return dict as? Dictionary<BridgedSwift, BridgedObjC>
}

// CHECK-LABEL: sil @_TF19collection_downcast31testDictionaryDowncastBridgedKV
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncastBridgedKV(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedSwift, BridgedSwift> {
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs31_dictionaryBridgeFromObjectiveCUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GS0_Q1_Q2__ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Dictionary<τ_0_2, τ_0_3>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<NSObject, AnyObject, BridgedSwift, BridgedSwift>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Dictionary<τ_0_2, τ_0_3>
  return dict as Dictionary<BridgedSwift, BridgedSwift>
}

// CHECK-LABEL: sil @_TF19collection_downcast42testDictionaryDowncastBridgedKVConditional
// CHECK: bb0([[DICT:%[0-9]+]] : $Dictionary<NSObject, AnyObject>)
func testDictionaryDowncastBridgedKVConditional(dict: Dictionary<NSObject, AnyObject>) 
       -> Dictionary<BridgedSwift, BridgedSwift>? {
  // CHECK: [[BRIDGE_FN:%[0-9]+]] = function_ref @_TFSs42_dictionaryBridgeFromObjectiveCConditionalUSs8Hashable__S____FGVSs10DictionaryQ_Q0__GSqGS0_Q1_Q2___ : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  // CHECK-NEXT: apply [[BRIDGE_FN]]<NSObject, AnyObject, BridgedSwift, BridgedSwift>([[DICT]]) : $@thin <τ_0_0, τ_0_1, τ_0_2, τ_0_3 where τ_0_0 : Hashable, τ_0_2 : Hashable> (@owned Dictionary<τ_0_0, τ_0_1>) -> @owned Optional<Dictionary<τ_0_2, τ_0_3>>
  return dict as? Dictionary<BridgedSwift, BridgedSwift>
}

