using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Base2e15
{
    public class Base2e15
    {
        public static String Encode(byte[] byts)
        {
            int bn = 15; // bit needed
            int bv = 0; // bit value
            int outLen = (byts.Length * 8 + 14) / 15;
            char[] output = new char[outLen];
            int pos = 0;
            for (int i = 0; i < byts.Length; ++i)
            {
                byte byt = byts[i];
                if (bn > 8)
                {
                    bv = (bv << 8) | byt;
                    bn -= 8;
                }
                else
                {
                    bv = ((bv << bn) | (byt >> (8 - bn))) & 0x7FFF;
                    if (bv < 0x1936)
                    {
                        output[pos++] = (char)(bv + 0x3480);
                    }
                    else if (bv < 0x545C)
                    {
                        output[pos++] = (char)(bv + 0x34CA);
                    }
                    else
                    {
                        output[pos++] = (char)(bv + 0x57A4);
                    }
                    bv = byt;
                    bn += 7;
                }
            }
            if (bn != 15)
            {
                if (bn > 7)
                { // need 8 bits or more, so has 7 bits or less
                    output[pos++] = (char)(((bv << (bn - 8)) & 0x7F) + 0x3400);
                }
                else
                {
                    bv = (bv << bn) & 0x7FFF;
                    if (bv < 0x1936)
                    {
                        output[pos++] = (char)(bv + 0x3480);
                    }
                    else if (bv < 0x545C)
                    {
                        output[pos++] = (char)(bv + 0x34CA);
                    }
                    else
                    {
                        output[pos++] = (char)(bv + 0x57A4);
                    }
                }
            }
            return new String(output);
        }

        public static byte[] Decode(String input)
        {
            int bn = 8; // bit needed
            int bv = 0; // bit value
            char[] inputArray = input.ToCharArray();
            int inputLen = inputArray.Length;
            int maxLen = (inputLen * 15 + 7) / 8;
            byte[] output = new byte[maxLen];
            int pos = 0;
            int cv;
            for (int i = 0; i < inputLen; ++i)
            {
                char code = inputArray[i];
                if (code > 0x33FF && code < 0xD7A4)
                {
                    if (code > 0xABFF)
                    {
                        cv = code - 0x57A4;
                    }
                    else if (code > 0x8925)
                    {
                        continue; // invalid range
                    }
                    else if (code > 0x4DFF)
                    {
                        cv = code - 0x34CA;
                    }
                    else if (code > 0x4DB5)
                    {
                        continue; // invalid range
                    }
                    else if (code > 0x347F)
                    {
                        cv = code - 0x3480;
                    }
                    else
                    {
                        cv = code - 0x3400;
                        output[pos++] = (byte)((bv << bn) | (cv >> (7 - bn)));
                        break; // last 8 bit data received, break
                    }
                    output[pos++] = (byte)((bv << bn) | (cv >> (15 - bn)));
                    bv = cv;
                    bn -= 7;
                    if (bn < 1)
                    {
                        output[pos++] = (byte)(bv >> -bn);
                        bn += 8;
                    }
                }
            }

            byte[] rtn = new byte[pos];
            for(int i = 0; i < pos; i++){
                rtn[i] = output[i];
            }
            return rtn;
        }
    }
}
