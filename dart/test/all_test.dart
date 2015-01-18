// Copyright (c) 2015, Rick Zhou. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library base2e15.test;

import 'package:base2e15/base2e15.dart';
import 'dart:convert';
//import 'dart:math';

bool testEqual(Object a, Object b, String testName) {
  if (a == b) {
    print('$testName Passed!');
    return true;
  } else {
    print('$testName Failed, "$a" != "$b"');
    return false;
  }
}
main() {
  String msg = 'Base2e15 is awesome!';
  String encoded = Base2e15.encode(UTF8.encode(msg));
  testEqual(encoded, '噺둽宖衝幍嬖瘌켉漁닽奪', 'Encoding Test');
  String decoded = UTF8.decode(Base2e15.decode(encoded));
  testEqual(decoded, msg, 'Decoding Test');
  String encoded2 = '~噺둽 宖衝幍嬖123瘌켉漁닽奪';
  String decoded2 = UTF8.decode(Base2e15.decode(encoded2));
  testEqual(decoded2, msg, 'Malformed Decoding Test');

//  Random rng = new Random();
//  List bytes = new List(100);
//  for (int i = 0; i < 10000; ++i) {
//    for (int j = 0; j < 100; ++j) {
//      bytes[j] = rng.nextInt(256);
//    }
//    String encoded = Base2e15.encode(bytes);
//    List newbytes = Base2e15.decode(encoded);
//    for (int j = 0; j < 100; ++j) {
//      if (bytes[j] != newbytes[j]) {
//        print('Failed:$bytes');
//        break;
//      }
//    }
//  }
}
