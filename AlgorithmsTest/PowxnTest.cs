using System;
using System.Collections.Generic;
using Algorithms;
using Algorithms.Utils;
using Xunit;
namespace AlgorithmsTest
{
    public class PowxnTest
    {
        [Theory]
        [InlineData(8.88023, 3, 700.28148)]
        [InlineData(-1.0, -2147483648, 1.00000)]
        public void TestMethod(double x, int n, double output)
        {
            Assert.Equal(output, Solution050.MyPow2(x, n));
        }
    }
}

