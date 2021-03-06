using System;
using System.Collections.Generic;
using Algorithms;
using Algorithms.Utils;
using Xunit;
namespace AlgorithmsTest
{
    public class SearchforaRangeTest
    {
        [Theory]
        [InlineData(new []{5, 7, 7, 8, 8, 10}, 8, new[]{3, 4})]
        public void TestMethod(int[] nums, int target, int[] output)
        {
            Assert.Equal(output, Solution034.SearchRange(nums, target));
        }
    }
}

