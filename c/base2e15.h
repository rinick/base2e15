// Copyright (c) 2015, Rick Zhou. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

#ifndef __BASE2E15_H__
#define __BASE2E15_H__
#include <wchar.h>

/**
 * @param data is input data
 * @param len is data length in bytes
 * @param out is output memory
 * @param outlen is output size
 * @return output lenth used, -1 if output length is not enough
 */
int base2e15_encode(const void* data, int len, wchar_t* out, int outlen);

/**
 * @param length is the length in bytes for the data
 * @return length of the base2e15 needed, not including the trailing \0
 */
int base2e15_encode_length(int len);


/**
 * @param data is input data
 * @param len is data length, -1: auto detect
 * @param out is output memory
 * @param outlen is output size in bytes
 * @return output lenth used, -1 if output length is not enough
 */
int base2e15_decode(const wchar_t* data, int len, void* out, int outlen);

/**
 * @param data is input data
 * @param len is data length, -1: auto detect
 * @return output lenth needed
 */
int base2e15_decode_length(const wchar_t* data, int len);

#endif
