using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UnitTest
{
    [TestClass]
    public class Test
    {
        [TestMethod]
        public void RunTest()
        {
            string test = "Base2e15 is awesome!";
            byte[] testBytes = System.Text.ASCIIEncoding.ASCII.GetBytes(test);
            string testEncoded = Base2e15.Base2e15.Encode(testBytes);
            Assert.AreEqual(testEncoded, "嗺둽嬖蟝巍媖疌켉溁닽壪");
            byte[] testDecodedBytes = Base2e15.Base2e15.Decode(testEncoded);
            string testDecoded = System.Text.ASCIIEncoding.ASCII.GetString(testDecodedBytes);
            Assert.AreEqual(test, testDecoded);
        }
    }
}
