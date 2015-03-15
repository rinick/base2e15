# Base2<img alt="e" height="0" width="0"><sup>15</sup>

binary-to-text encoding scheme that represents binary data in an unicode string format. Each unicode character represents 15 bits of binary data.

#### Example ####

| Encoding | Data | chararacters |
|:-:|:-:|:-:|
| Plain text | Base2e15 is awesome! | 20 |
| **Base2<img alt="e" height="0" width="0"><sup>15</sup>** | **嗺둽嬖蟝巍媖疌켉溁닽壪** | **11** |
| Base64 | QmFzZTJlMTUgaXMgYXdlc29tZSE= | 27+1 |
 
## Mapping table

Every character represents 15 bits of data, except the last character, which is 7 or 15 bits.

| Binary | Unicode | Unicode Range Name |
|:-:|:-:|:-:|
| **15 bits mapping** | | |
| 0x0000 ~ 0x1935 | U+3480 ~ U+4DB5 | CJK Unified Ideographs Extension A |
| 0x1936 ~ 0x545B | U+4E00 ~ U+8925 | CJK Unified Ideographs |
| 0x545C ~ 0x7FFF | U+AC00 ~ U+D7A3 | Hangul Syllables |
| **7 bits mapping** | | |
| 0x00   ~ 0x7F | U+3400 ~ U+347F | CJK Unified Ideographs Extension A |

## Usage

A simple usage example in dart:
```dart
import 'dart:convert';
import 'package:base2e15/base2e15.dart';

main() {
  String msg = 'Base2e15 is awesome!';
  String encoded = Base2e15.encode(UTF8.encode(msg));
  String decoded = UTF8.decode(Base2e15.decode(encoded));
}
```

example in c:
```c
#include <stdio.h>
#include "base2e15.h"
int main(int argc, char *argv[])
{
    char c[] = "Base2e15 is awesome!";
    int len = strlen(c);

    int encodeLen = base2e15_encode_length(len) + 1; \\ one more char for the \0
    wchar_t* encoded = malloc(encodeLen * sizeof(wchar_t));
    base2e15_encode(c, len, encoded, encodeLen);
    
    // int buffLen = base2e15_decode_length(encoded, -1);
    int buffLen = 256; 
    char* decoded = malloc(buffLen * sizeof(char));
    int decodeLen = base2e15_decode(encoded, -1, decoded, buffLen);
    // if buffLen is not big enough, decodeLen will be -1
}
```

## Compare

| Compare | Base2<img alt="e" height="0" width="0"><sup>15</sup> |  Base64 |
|:-:|:-:|:-:|
| bits per character | **15** | 6 |
| bits per char width | **7.5 (15/2)** | 6 (6/1) |
| bits per UTF8 byte | 5 (15/3) | **6 (6/1)** |
| bits per UTF16 byte | **7.5 (15/2)** | 3 (6/2) |

## Why not Base2<img alt="e" height="0" width="0"><sup>16</sup>?

The unicode range `CJK Unified Ideographs Extension B` contains 42711 characters (U+20000 ~ U+2A6D6), together with the characters used by Base2<img alt="e" height="0" width="0"><sup>15</sup>, there are more than 65536 usable characters to encode 16 bits in each character.

However, font support for `CJK Unified Ideographs Extension B` is missing in most mobile devices and using this code range will also reduce the bits capacity in UTF8 and UTF16 encoding, since those characters require one more byte in UTF8 and 2 more bytes in UTF16.
