﻿// Source : https://leetcode.com/problems/text-justification/ 
// Author : codeyu 
// Date : Sunday, January 15, 2017 9:51:02 PM 

/**********************************************************************************
*
* 
* Given an array of words and a length L, format the text such that each line has exactly L characters and is fully (left and right) justified.
*  
* 
* 
* You should pack your words in a greedy approach; that is, pack as many words as you can in each line. Pad extra spaces ' ' when necessary so that each line has exactly L characters.
* 
* 
* 
* Extra spaces between words should be distributed as evenly as possible. If the number of spaces on a line do not divide evenly between words, the empty slots on the left will be assigned more spaces than the slots on the right.
* 
* 
* 
* For the last line of text, it should be left justified and no extra space is inserted between words.
* 
* 
* 
* For example,
* words: ["This", "is", "an", "example", "of", "text", "justification."]
* L: 16.
* 
* 
* 
* Return the formatted lines as:
* 
* [
*    "This    is    an",
*    "example  of text",
*    "justification.  "
* ]
* 
* 
* 
* 
* Note: Each word is guaranteed not to exceed L in length.
* 
* 
* 
* click to show corner cases.
* 
* Corner Cases:
* 
* 
* A line other than the last line might contain only one word. What should you do in this case?
* In this case, that line should be left-justified.
* 
* 
*
**********************************************************************************/

using System;
using System.Collections.Generic;
using Algorithms.Utils;
namespace Algorithms
{
public class Solution068 {
    public IList<string> FullJustify(string[] words, int maxWidth) {
        IList<string> res = new List<string>();
        int i = 0;
        int chLength = 0; //字符所占的长度
        int wordLength = 0; //单词个数
        
        int space = 0;
        
        while(i < words.Length)
        {
            string word = words[i];
            if(wordLength + chLength + word.Length <= maxWidth)
            {
                wordLength++;
                chLength += word.Length;
                i++;      
                continue;
            }
            
            space = maxWidth - chLength;
            if(wordLength == 0) return res;
            if(wordLength == 1)
            {
                res.Add(words[i - 1].PadRight(maxWidth, ' '));    
            }
            else
            {
                int wordSpace = space / (wordLength - 1);
                int extraSpace = space % (wordLength - 1);
                int start = i - wordLength;
                string cur = string.Empty;
                for(int j = start; j < start + extraSpace; j++)
                {
                    cur += words[j];
                    cur += new string(' ', wordSpace + 1);
                }
                for(int j = start + extraSpace; j < i - 1; j++)
                {
                    cur += words[j];
                    cur += new string(' ', wordSpace);
                }
                cur += words[i - 1];
                res.Add(cur);
            }     
            chLength = 0;
            wordLength = 0;
        }
        //加上最后一行
        if(wordLength == 0) return res;
        space = maxWidth - chLength;
        if(wordLength == 1)
        {
            res.Add(words[i - 1].PadRight(maxWidth, ' '));     
        }
        else
        {
            int start = i - wordLength;
            string cur = string.Empty;

            for(int j = start; j < i - 1; j++)
            {
                cur += words[j];
                cur += ' ';
            }
            cur += words[i - 1];
            
            res.Add(cur.PadRight(maxWidth, ' '));
        }     
        return res;
    }
}
