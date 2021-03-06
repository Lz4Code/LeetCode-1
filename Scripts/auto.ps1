﻿$URL = $args[0]
$gitArgs = @("config", "--get", "user.name")
$command = &"git" $gitArgs
$COMMENT_TAG = '//'
$COMMENT = ""
try {
    $Runtime = [System.Runtime.InteropServices.RuntimeInformation]
    $OSPlatform = [System.Runtime.InteropServices.OSPlatform]

    $IsCoreCLR = $true
    $IsLinux = $Runtime::IsOSPlatform($OSPlatform::Linux)
    $IsOSX = $Runtime::IsOSPlatform($OSPlatform::OSX)
    $IsWindows = $Runtime::IsOSPlatform($OSPlatform::Windows)
} catch {
    # If these are already set, then they're read-only and we're done
    try {
        $IsCoreCLR = $false
        $IsLinux = $false
        $IsOSX = $false
        $IsWindows = $true
    }
    catch { }
}
$HTML = Invoke-WebRequest -Uri $URL
if ($IsWindows)
{
    $QuestionContent = ($HTML.ParsedHtml.getElementsByTagName(‘meta’) | where {$_.getAttributeNode('name').Value -eq 'description'} ).content.Split("`n")
    $QuestionTitle = (($HTML.ParsedHtml.getElementsByTagName(‘div’) | Where{ $_.className -eq ‘question-title clearfix’ })).innerText.Split("`n")[0]
    $DIFFCULT = ($HTML.ParsedHtml.getElementsByTagName(‘div’) | Where{ $_.className -eq ‘question-info text-info’ } ).innerText.Split("`n")[2].Split(":")[1].Trim()
    $NG =  ($HTML.ParsedHtml.body.getElementsByTagName(‘div’) | where {$_.getAttributeNode('ng-controller').Value -eq 'AceCtrl as aceCtrl'} )
    $JSON = $NG.getAttributeNode('ng-init').Value
}
else{
    $QuestionContent = ($HTML.Content | pup -p 'head meta[name=\"description\"] attr{content}').Split("`n")
    $QuestionTitle = ($HTML.Content | pup -p 'div[class=\"question-title clearfix\"] h3 text{}').Trim().Split("`n")[1]
    $DIFFCULT = ($HTML.Content | pup 'div#desktop-side-bar ul li span text{}').Split(":")[2].Trim()
    $JSON = ($HTML.Content | pup -p 'body script:contains(\"codeDefinition\") text{}') | Out-String
    $JSONSTART = $JSON.IndexOf("=") + 1
    $JSONLENGTH = $JSON.LastIndexOf(";") - $JSONSTART
    $JSON = $JSON.Substring($JSONSTART,$JSONLENGTH).Trim().Replace("\u003D","=").Replace("\u003B",";").Replace("\u003C","<").Replace("\u003E",">").Replace("\u000A","`n").Replace("\u000D","`n").Replace("\u000D\u000A","`n").Replace("\u0022","""")
}
$AUTHOR = $command
$CURRENT_DATE = Get-Date -format F
$NUM = $QuestionTitle.Split(".")[0].Trim().PadLeft(3).Replace(" ", "0") 
$TITLE = $QuestionTitle.Split(".")[1].Trim().Replace("(", "").Replace(")", "").Replace(",", "").Replace("'", "").Replace("-", "")
$FILE = $TITLE.Replace(" ", "") + ".cs"
$TESTFILE = $TITLE.Replace(" ", "") + "Test.cs"
if ($IsWindows)
{
    $START = $JSON.IndexOf("[{")
    $END = $JSON.IndexOf("},],")
    $JSON = $JSON.Remove($END).Trim() + "}]"
    $CODE = $JSON.Substring($START)
}
else {
    $pattern = "(?s)\[\{'.*\},\]"
    $CODE = $JSON -match $pattern
    $CODE = $matches[0]
}

$CSHARP = $CODE | ConvertFrom-Json 
$CLASS = ($CSHARP | where { $_.value -eq 'csharp' }).defaultCode
$regex = [regex]"(?s)\bSolution\b\s\{(.*?)\{"
$FuncInfo = $regex.Matches($CLASS).Groups[1].Value
$ReturnType = $FuncInfo.Trim().Split(' ')[1]
$FunName = $FuncInfo.Trim().Split(' ')[2].Substring(0,$FuncInfo.Trim().Split(' ')[2].IndexOf('('))
$Params = $FuncInfo.Trim().Substring($FuncInfo.Trim().IndexOf('(')).Replace("(","").Replace(")","")
$CLASS = $CLASS.Insert($CLASS.IndexOf("Solution") + 8, $NUM)
$CLASS = $CLASS.Insert($CLASS.LastIndexOf("public") + 7, "static ")
$CLASS = $CLASS.Insert($CLASS.IndexOf(") {") + 4, "throw new NotImplementedException(`"TODO`");")
$COMMENT += "$COMMENT_TAG Source : $URL `n"
$COMMENT += "$COMMENT_TAG Author : $AUTHOR `n"
$COMMENT += "$COMMENT_TAG Date : $CURRENT_DATE `n"
$COMMENT += "`n"
$COMMENT += "/**********************************************************************************`n"
$COMMENT += "*`n"

$TAIL = $QuestionContent.Length
foreach($a in $QuestionContent[0 .. $TAIL] ){
    $COMMENT += $a.Insert(0,”* “) + "`n"
}
$COMMENT += "*`n"
$COMMENT += "**********************************************************************************/`n"
$COMMENT += "`n"
$COMMENT += "using System;`nusing System.Collections.Generic;`nusing Algorithms.Utils;`n"
$COMMENT += "namespace Algorithms`n"
$COMMENT += "{`n"
$COMMENT += $CLASS
$COMMENT += "}`n"
$COMMENT > ../Algorithms/$FILE

$TESTCLASSNAME = $TITLE.Replace(" ", "") + "Test"
$TESTCLASS = "using System;`nusing System.Collections.Generic;`nusing Algorithms;`nusing Algorithms.Utils;`nusing Xunit;`nnamespace AlgorithmsTest`n{`n"
$TESTCLASS += "    public class $TESTCLASSNAME`n"
$TESTCLASS += "    {`n"
$TESTCLASS += "        [Theory]`n"
$TESTCLASS += "        [InlineData()]`n"
$TESTCLASS += "        public void TestMethod($Params, $ReturnType output)`n"
$TESTCLASS += "        {`n" 
$TESTCLASS += "            Assert.Equal(output, Solution$NUM.$FunName());`n" 
$TESTCLASS += "        }`n" 
$TESTCLASS += "    }`n"
$TESTCLASS += "}`n" 
$TESTCLASS > ../AlgorithmsTest/$TESTFILE

"|$NUM|[$TITLE]($URL) | [C#](./Algorithms/$FILE)|$DIFFCULT|" | Out-File -Encoding "utf8" -Append ../README.md