// Copyright (c) 2015, Rick Zhou. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
package com.base2e15;

import java.util.Arrays;

class Base2e15 {
  public static String encode(byte[] byts) {
    int bn = 15; // bit needed
    int bv = 0; // bit value
    int outLen = (byts.length * 8 + 14) / 15;
    int[] out = new int[outLen];
    int pos = 0;
    for (int i = 0; i < byts.length; ++i) {
        byte byt = byts[i];
      if (bn > 8) {
        bv = (bv << 8) | byt;
        bn -= 8;
      } else {
        bv = ((bv << bn) | (byt >> (8 - bn))) & 0x7FFF;
        if (bv < 0x1936) {
          out[pos++] = bv + 0x3480;
        } else if (bv < 0x545C) {
          out[pos++] = bv + 0x34CA;
        } else {
          out[pos++] = bv + 0x57A4;
        }
        bv = byt;
        bn += 7;
      }
    }
    if (bn != 15) {
      if (bn > 7) { // need 8 bits or more, so has 7 bits or less
        out[pos++] = ((bv << (bn - 8)) & 0x7F) + 0x3400;
      } else {
        bv = (bv << bn) & 0x7FFF;
        if (bv < 0x1936) {
          out[pos++] = bv + 0x3480;
        } else if (bv < 0x545C) {
          out[pos++] = bv + 0x34CA;
        } else {
          out[pos++] = bv + 0x57A4;
        }
      }
    }
    return new String(out, 0, outLen);
  }

  public static byte[] decode(String input) {
    int bn = 8; // bit needed
    int bv = 0; // bit value
    int inputLen = input.length();
    int maxLen = (inputLen * 15 + 7) / 8;
    byte[] out = new byte[maxLen];
    int pos = 0;
    int cv;
    for (int i = 0; i < inputLen; ++i) {
      char code = input.charAt(i);
      if (code > 0x33FF && code < 0xD7A4) {
        if (code > 0xABFF) {
          cv = code - 0x57A4;
        } else if (code > 0x8925) {
          continue; // invalid range
        } else if (code > 0x4DFF) {
          cv = code - 0x34CA;
        } else if (code > 0x4DB5) {
          continue; // invalid range
        } else if (code > 0x347F) {
          cv = code - 0x3480;
        } else {
          cv = code - 0x3400;
          out[pos++] = (byte)((bv << bn) | (cv >> (7 - bn)));
          break; // last 8 bit data received, break
        }
        out[pos++] =(byte)((bv << bn) | (cv >> (15 - bn)));
        bv = cv;
        bn -= 7;
        if (bn < 1) {
          out[pos++] = (byte)(bv >> -bn);
          bn += 8;
        }
      }
    }
    return Arrays.copyOfRange(out, 0, pos);
  }
}