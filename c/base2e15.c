// Copyright (c) 2015, Rick Zhou. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

#include "base2e15.h"

/**
 * @param data is input data
 * @param len is data length in bytes
 * @param out is output memory
 * @param outlen is output size
 * @return output lenth used, -1 if output length is not enough
 */
int base2e15_encode(const void* data, int len, wchar_t* out, int outlen) {
    const unsigned char* input = (const unsigned char*)data;
    int outlenNeeded = (len * 8 + 14) / 15;
    if (outlen < outlenNeeded) {
        return -1;
    }
    if (outlen > outlenNeeded){
        out[outlenNeeded] = 0;
    }
    int bn = 15; // bit needed
    wchar_t bv = 0; // bit value

    const unsigned char* pEnd = input + len;
    wchar_t *pOut = out;
    const unsigned char* p;
    for (p = input; p < pEnd; ++p) {
      if (bn > 8) {
        bv = (bv << 8) | *p;
        bn -= 8;
      } else {
        bv = ((bv << bn) | (*p >> (8 - bn))) & 0x7FFF;
        if (bv < 0x1936) {
          *(pOut++) = bv + 0x3480;
        } else if (bv < 0x545C) {
          *(pOut++) = bv + 0x34CA;
        } else {
          *(pOut++) = bv + 0x57A4;
        }
        bv = *p;
        bn += 7;
      }
    }
    if (bn != 15) {
      if (bn > 7) {
        *(pOut++) = ((bv << (bn - 8)) & 0xFF) + 0x3400;
      } else {
        bv = (bv << bn) & 0x7FFF;
        if (bv < 0x1936) {
          *(pOut++) = bv + 0x3480;
        } else if (bv < 0x545C) {
          *(pOut++) = bv + 0x34CA;
        } else {
          *(pOut++) = bv + 0x57A4;
        }
      }
    }
    return outlenNeeded;
}

/**
 * @param length is the length in bytes for the data
 * @return length of the base2e15 needed, not including the trailing \0
 */
int base2e15_encode_length(int len) {
    return (len * 8 + 14) / 15;
}


/**
 * @param data is input data
 * @param len is data length, -1: auto detect
 * @return output lenth needed
 */
int base2e15_decode_length(const wchar_t* data, int len) {
    int count = 0;
    int bn = 8; // bit needed
    const wchar_t* dataEnd = data + len;
    const wchar_t* code;
    for (code = data; len == -1 || code < dataEnd; ++code) {
      if (*code == 0) {
        break;
      }
      if (*code > 0x33FF && *code < 0xD7A4) {
        if (*code > 0xABFF) {
        } else if (*code > 0x8925) {
          continue; // invalid range
        } else if (*code > 0x4DFF) {
        } else if (*code > 0x4DB5) {
          continue; // invalid range
        } else if (*code > 0x347F) {
        } else {
          ++count;
          break; // last 7 bit data received, break
        }
        ++count;

        bn -= 7;
        if (bn < 1) {
          ++count;
          bn += 8;
        }
      }
    }
    return count;
}

/**
 * @param data is input data
 * @param len is data length, -1: auto detect
 * @param out is output memory
 * @param outlen is output size in bytes
 * @return output lenth used, -1 if output length is not enough
 */
int base2e15_decode(const wchar_t* data, int len, void* out, int outlen) {
    unsigned char* output = (unsigned char*)out;
    unsigned char* outputEnd = output + outlen;

    int bn = 8; // bit needed
    wchar_t bv = 0; // bit value
    wchar_t cv;
    const wchar_t* dataEnd = data + len;
    const wchar_t* code;
    for (code = data; len == -1 || code < dataEnd; ++code) {
      if (*code == 0) {
        break;
      }
      if (*code > 0x33FF && *code < 0xD7A4) {
        if (*code > 0xABFF) {
          cv = *code - 0x57A4;
        } else if (*code > 0x8925) {
          continue; // invalid range
        } else if (*code > 0x4DFF) {
          cv = *code - 0x34CA;
        } else if (*code > 0x4DB5) {
          continue; // invalid range
        } else if (*code > 0x347F) {
          cv = *code - 0x3480;
        } else {
          cv = *code - 0x3400;
          *(output++) = (bv << bn) | (cv >> (7 - bn));
          break; // last 7 bit data received, break
        }
        if (output >= outputEnd) {
            return -1;
        }
        *(output++) = (bv << bn) | (cv >> (15 - bn));
        bv = cv;
        bn -= 7;
        if (bn < 1) {
          if (output >= outputEnd) {
            return -1;
          }
          *(output++) = bv >> -bn;
          bn += 8;
        }
      }
    }
    return output - (unsigned char*)out;
}

