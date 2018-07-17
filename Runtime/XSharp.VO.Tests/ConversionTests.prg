//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
USING System
USING System.Collections.Generic
USING System.Linq
USING System.Text
USING XUnit
USING System.Globalization


BEGIN NAMESPACE XSharp.VO.Tests

	CLASS VoConversionTests

		[Fact, Trait("Category", "Conversion")];
		METHOD AsStringTest() AS VOID 
			LOCAL u AS USUAL
			u := "123"
			Assert.Equal("123", AsString(u))
			u := #A123
			Assert.Equal("A123", AsString(u))

			Assert.Equal("1", AsString(1))
			VAR c1 := GetRTFullPath()
			Assert.Equal(TRUE, c1:ToLower():IndexOf(".vo.dll") > 0)

			VAR n1 := GetThreadCount()
			Assert.Equal(TRUE, n1 > 1)

		[Fact, Trait("Category", "Conversion")];
		METHOD StrTest() AS VOID 
			LOCAL c AS STRING
			SetDecimalSep(46)
			c := Str3(12.3456,5,2)
			Assert.Equal("12.35", c)	// ROunded up
			c := Str3(12.3411,5,2)
			Assert.Equal("12.34", c)	// ROunded down
			c := Str3(FloatFormat(12.3456,10,4),10,5)
			Assert.Equal("  12.34560", c)	// ROunded down
			c := StrZero(12.3456,10,2)
			Assert.Equal("0000012.35", c)	// ROunded up
			c := Str3(2.49999,4,2)
			assert.Equal("2.50", c )  
			c := Str3(2.50012,4,2)
			assert.Equal("2.50", c )  

		[Fact, Trait("Category", "Val")];
		METHOD ValTest() AS VOID
			LOCAL u AS USUAL
			u := Val("1.234")
			Assert.Equal(1.234, (FLOAT) u)
			SetDecimalSep(44) // ,
			u := Val("1,234")
			Assert.Equal(1.234, (FLOAT) u)
			u := Val("1.23E2")
			Assert.Equal(123.0, (FLOAT) u)
			u := Val("1.2345E2")
			Assert.Equal(123.45, (FLOAT) u)

			Assert.Equal(238, Val("0XEE"))
			Assert.Equal(238, Val("0xEE"))
			Assert.Equal(256, Val("0x100"))
			Assert.Equal(430, Val("0x1AE"))


	END CLASS
END NAMESPACE // XSharp.Runtime.Tests
