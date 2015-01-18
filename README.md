# base2e15

binary-to-text encoding schemes that represent binary data in an unicode string format, each unicode character represent 15 bits of binary data

#### Example ####

Plain Text (20chars):
 Base2e15 is awesome!
Base2e15 (11chars):
 噺둽宖衝幍嬖瘌켉漁닽奪
Base64 (27+1chars):
 QmFzZTJlMTUgaXMgYXdlc29tZSE=
 
## mapping table
``15 bits mapping``
0x0000 ~ 0x18B5 -> U+3500 ~ U+4DB5   CJK Unified Ideographs Extension A
0x18B6 ~ 0x545B -> U+4E00 ~ U+89A5   CJK Unified Ideographs
0x545C ~ 0x7FFF -> U+AC00 ~ U+D7A3   Hangul Syllables

`` 8 bits mapping`` when the last character needs no more than 8 bits of data
0x00   ~ 0xFF   -> U+3400 ~ U+34FF   CJK Unified Ideographs Extension A


## Usage

A simple usage example in dart:
    import 'dart:convert';
    import 'package:base2e15/base2e15.dart';

    main() {
      String msg = 'Base2e15 is awesome!';
      String encoded = Base2e15.encode(UTF8.encode(msg));
      String decoded = UTF8.decode(Base2e15.decode(encoded));
    }

## Compare

| Compare | Base2e15 |  Base64 |
|:-:|:-:|:-:|
| bits per character | **15** | 6 |
| bits per char width | **7.5 (15/2)** | 6 (6/1) |
| bits per UTF8 byte | 5 (15/3) | **6 (6/1)** |
| bits per UTF16 byte | **7.5 (15/2)** | 3 (6/2) |

## Why not base2e16 ?
Unicode range CJK Unified Ideographs Extension B contains 42711 characters (U+20000 ~ U+2A6D6), together with the characters used by base2e15, it is possible to encode 16 bits in each character.
But the font support for CJK Unified Ideographs Extension B is missing in most mobile devices and using this code range will also readue the bits capacity in UTF8 and UTF16 encoding, since those characters require one more byte in UTF8 and 2 more bytes in UTF16.
