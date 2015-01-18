// Copyright (c) 2015, Rick Zhou. All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


/// The base2e15 library.
/// Map 15 bits to unicode
/// 0x0000 ~ 0x18B5 -> U+3500 ~ U+4DB5   CJK Unified Ideographs Extension A
/// 0x18B6 ~ 0x545B -> U+4E00 ~ U+89A5   CJK Unified Ideographs
/// 0x545C ~ 0x7FFF -> U+AC00 ~ U+D7A3   Hangul Syllables
/// 8 bits special case, only used by last character
///  0x00  ~  0xFF  -> U+3400 ~ U+34FF   CJK Unified Ideographs Extension A
library base2e15;
import 'dart:typed_data';
class Base2e15 {

  static String encode(List<int> bytes, [int lineSize = 0, String linePadding]) {
    List<int> charCodes = encodeToCharCode(bytes);
    if (lineSize <= 0) {
      return new String.fromCharCodes(charCodes);
    }
    List rslt = [];
    int len = charCodes.length;
    for (int i = 0; i < len; i += lineSize) {
      int j = i + lineSize;
      if (j < len) {
        j = len;
      }
      if (linePadding != null) {
        rslt.add('$linePadding${new String.fromCharCodes(charCodes.sublist(i, j))}');
      } else {
        rslt.add(new String.fromCharCodes(charCodes.sublist(i, j)));
      }
    }
    return rslt.join('\n');
  }

  static List<int> encodeToCharCode(List<int> bytes) {
    int bn = 15; // bit needed
    int bv = 0; // bit value
    int outLen = (bytes.length * 8 + 14) ~/ 15;
    List<int> out = new List<int>(outLen);
    int pos = 0;
    for (int byte in bytes) {
      if (bn > 8) {
        bv = (bv << 8) | byte;
        bn -= 8;
      } else {
        bv = ((bv << bn) | (byte >> (8 - bn))) & 0x7FFF;
        if (bv < 0x18B6) {
          out[pos++] = bv + 0x3500;
        } else if (bv < 0x545C) {
          out[pos++] = bv + 0x354A;
        } else {
          out[pos++] = bv + 0x57A4;
        }
        bv = byte;
        bn += 7;
      }
    }
    if (bn != 15) {
      if (bn > 6) { // 8 bits or less is needed
        out[pos++] = ((bv << (bn - 7)) & 0xFF) + 0x3400;
      } else {
        bv = (bv << bn) & 0x7FFF;
        if (bv < 0x18B6) {
          out[pos++] = bv + 0x3500;
        } else if (bv < 0x545C) {
          out[pos++] = bv + 0x354A;
        } else {
          out[pos++] = bv + 0x57A4;
        }
      }
    }
    return out;
  }

  static Uint8List decode(String input) {
    int bn = 8; // bit needed
    int bv = 0; // bit value
    int maxLen = (input.length * 15 + 7) ~/ 8;
    Uint8List out = new Uint8List(maxLen);
    int pos = 0;
    int cv;
    for (int code in input.codeUnits) {
      if (code > 0x33FF && code < 0xD7A4) {
        if (code > 0xABFF) {
          cv = code - 0x57A4;
        } else if (code > 0x89A5) {
          continue; // invalid range
        } else if (code > 0x4DFF) {
          cv = code - 0x354A;
        } else if (code > 0x4DB5) {
          continue; // invalid range
        } else if (code > 0x34FF) {
          cv = code - 0x3500;
        } else {
          cv = code - 0x3400;
          out[pos++] = (bv << bn) | (cv >> (8 - bn));
          break; // last 8 bit data received, break
        }
        out[pos++] = (bv << bn) | (cv >> (15 - bn));
        bv = cv;
        bn -= 7;
        if (bn < 1) {
          out[pos++] = bv >> -bn;
          bn += 8;
        }
      }
    }
    return out.sublist(0, pos);
  }
}
