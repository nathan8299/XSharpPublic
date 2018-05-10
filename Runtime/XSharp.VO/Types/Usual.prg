//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using System
USING System.Runtime.InteropServices
using System.Runtime.CompilerServices
using System.Diagnostics
using XSharp.Internal
begin namespace XSharp
	/// <summary>Internal type that implements the VO Compatible USUAL type.<br/>
	/// This type has many operators and implicit converters that normally are never directly called from user code.
	/// </summary>
    [StructLayout(LayoutKind.Sequential, Pack := 4)];
    [DebuggerDisplay("{Value,nq} ({_usualType})", Type := "USUAL")];
    [DebuggerTypeProxy(typeof(UsualDebugView))];
    public structure __Usual implements IConvertible,IComparable
        #region static fields
            public static _NIL as __Usual
        #endregion
        
        #region private fields
            private initonly _flags    	as UsualFlags	// type, byref, width, decimals
            private initonly _valueData	as _UsualData		// for non GC data
            private initonly _refData  	as object			// for GC data
        #endregion
        
        #region constructors
            static constructor
            _NIL := __Usual{}
            return
            
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(u as __Usual)
            self:_flags     := u:_flags
            self:_valueData	:= u:_valueData
            self:_refData 	:= u:_refData 
            
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(f as Float)
            self:_valueData:r8		:= f:Value
            self:_flags:usualType	:= UsualType.Float
            self:_flags:Width		:= (Sbyte) f:Digits
            self:_flags:Decimals	:= (Sbyte) f:Decimals
            
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(r8 as real8)
            self:_valueData:r8		:= r8
            self:_flags:usualType	:= UsualType.Float
            self:_flags:Width		:= -1
            self:_flags:Decimals	:= -1
            
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as logic)
            self:_flags:usualType	:= UsualType.LOGIC
            self:_valueData:l		:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as Array)
            self:_flags:usualType	:= UsualType.Array
            self:_refData			:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as Date)
            self:_flags:usualType	:= UsualType.Date
            self:_valueData:d		:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as System.DateTime)
            self:_flags:usualType	:= UsualType.DateTime
            self:_valueData:dt		:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as long)
            self:_flags:usualType	:= UsualType.LONG
            _valueData:i			:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as int64)
            self:_flags:usualType	:= UsualType.INT64
            self:_valueData:i64		:= value
            return
            
            [MethodImpl(MethodImplOptions.AggressiveInlining)];        
            private constructor(value as uint64)
            if value < Int64.MaxValue
                self:_flags:usualType	:= UsualType.INT64
                self:_valueData:i64:= (int64) value
            else
                self:_flags:usualType	:= UsualType.FLOAT
                self:_valueData:r8 := value
            endif
            return
            
            private constructor(d as System.Decimal)
            self:_flags:usualType  := UsualType.Decimal
            self:_refdata	:= d
            
            
            private constructor(value as System.IntPtr)
            self:_flags:usualType	:= UsualType.PTR
            self:_valueData:p		:= value
            return
            
            public constructor(o as object)
            local u				as __Usual
            if o != null
                if o:GetType() == typeof(__Usual)
                    // boxed __Usual
                    u		:= (__Usual)o 
                    self:_flags		:= u:_flags
                    self:_refData	:= u:_refData 
                    self:_valueData	:= u:_valueData
                else
                    //  decode type from typecode
                    var vartype := o:GetType()
                    var typeCode := System.Type.GetTypeCode(vartype)
                    switch typeCode
                        case  System.TypeCode.DBNull
                            self:_flags:usualType := UsualType.Void
                            self:_refData	:= null
                        
                        case System.TypeCode.Boolean
                            self:_flags:usualType := UsualType.LOGIC
                            self:_valueData:l := (logic)o 
                        
                        case System.TypeCode.Char
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (char)o 
                        
                        case System.TypeCode.SByte
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (SByte)o 
                        
                        case System.TypeCode.Byte
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (byte)o 
                        
                        case System.TypeCode.Int16 
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (short)o 
                        
                        case System.TypeCode.UInt16
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (word)o 
                        
                        case System.TypeCode.Int32
                            self:_flags:usualType		:= UsualType.Long
                            self:_valueData:i	:= (long)o 
                        
                        case System.TypeCode.UInt32
                            if (dword)o  <= Int32.MaxValue
                                self:_flags:usualType := UsualType.Long
                                self:_valueData:i := (long)(dword)o  
                            else
                                self:_flags:usualType := UsualType.Float
                                self:_valueData:r8:= (real8) (UInt32) o 
                                self:_flags:width	:= -1
                                self:_flags:decimals := -1
                            endif
                        case System.TypeCode.Int64 
                            self:_flags:usualType		:= UsualType.Int64
                            self:_valueData:i64	:= (int64)o 
                        
                        case System.TypeCode.UInt64 
                            if (uint64) o  <= Int64.MaxValue
                                self:_flags:usualType	:= UsualType.Int64
                                self:_valueData:i64		:= (int64)(uint64)o  
                            else
                                self:_flags:usualType := UsualType.FLOAT
                                self:_valueData:r8 := (real8)(uint64)o  
                                self:_flags:width	:= -1
                                self:_flags:decimals := -1
                            endif
                        case System.TypeCode.Single  
                            self:_flags:usualType		:= UsualType.Float
                            self:_valueData:r8	:= (real8)o 
                            self:_flags:width	:= -1
                            self:_flags:decimals := -1
                        
                        case System.TypeCode.Double 
                            self:_flags:usualType := UsualType.Float
                            self:_valueData:r8 := (real8)o 
                            self:_flags:width := -1
                            self:_flags:decimals := -1
                        
                        case System.TypeCode.Decimal 
                            self:_flags:usualType := UsualType.Decimal
                            self:_refData  := o
                        
                        case System.TypeCode.DateTime 
                            self:_flags:usualType := UsualType.DateTime
                            self:_valueData:dt := (System.DateTime) o 
                        
                        case System.TypeCode.String 
                            self:_flags:usualType := UsualType.STRING
                            self:_refData  := (string)o 
                        
                        otherwise
                            IF vartype == typeof(ARRAY)
                                SELF:_flags:usualType := UsualType.Array
                                self:_refData  := o
							// CodeBlock ?
							// _CodeBlock ?
                            ELSEIF vartype == typeof(DATE)
                                SELF:_flags:usualType := UsualType.Date
                                SELF:_valueData:d :=  (DATE) o
                            ELSEIF vartype == typeof(SYMBOL)
                                SELF:_flags:usualType := UsualType.Symbol
                                SELF:_valueData:s :=   (SYMBOL) o
                            ELSEIF vartype == typeof(System.Reflection.Pointer)
                                self:_flags:usualType := UsualType.Ptr
                                self:_valueData:p	  := Intptr{System.Reflection.Pointer.UnBox(o)}
							elseif o is IFloat
								local f := (IFLoat) o as IFloat
								self:_valueData:r8		:= f:Value
								self:_flags:usualType	:= UsualType.Float
								self:_flags:Width		:= (Sbyte) f:Digits
								SELF:_flags:Decimals	:= (Sbyte) f:Decimals
							elseif o is ICodeBlock
                                SELF:_flags:usualType := UsualType.CodeBlock
                                self:_refData := o
                            ELSE
                                SELF:_flags:usualType := UsualType.Object
                                self:_refData := o
                            endif
                    end switch
                endif
            endif
            return
            
            private constructor(s as string)
            self:_flags:usualType	:= UsualType.STRING
            self:_refData 			:= s
            return

        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
        private constructor(s as symbol)
            self:_flags:usualType	:= UsualType.SYMBOL
            self:_valueData:s       := s
            return

        [MethodImpl(MethodImplOptions.AggressiveInlining)];        
        private constructor(o as object, lIsNull as logic)
            self:_flags:usualType	:= UsualType.OBJECT
            self:_refData 			:= null
            return

        #endregion
        
        #region properties
			private property _isByRef		as LOGIC	get _flags:isByRef
            private property _usualType		as UsualType get _flags:usualType 

			private property _arrayValue    as array	get iif(IsArray, (array) _refData , null_array)
			private property _codeblockValue as codeblock	get iif(IsCodeBlock, (Codeblock) _refData , null_codeblock)
            private property _dateValue		as Date get _valueData:d 
            private property _dateTimeValue as DateTime get _valueData:dt
            private property _decimalValue	as System.Decimal get (System.Decimal) _refData 
            private property _floatValue    as Float get Float{ _valueData:r8, _width, _decimals}
            private property _i64Value		as int64	get _valueData:i64 
            private property _intValue		as int		get _valueData:i  
            private property _logicValue	as logic	get _valueData:l 
            private property _ptrValue		as IntPtr	get _valueData:p 
            private property _r8Value		as real8	get _valueData:r8 
            private property _stringValue   as string	get iif(IsString, (string) _refData , String.Empty)
            private property _symValue		as Symbol	get _valueData:s 

            // properties for floats
            private property _width			as SBYTE get _flags:width 
            private property _decimals		as SBYTE get _flags:decimals 
			// Is .. ?
			internal property IsArray		as logic get _usualtype == UsualType.Array
			internal property IsCodeblock	as logic get _usualtype == UsualType.CodeBlock
			internal property IsDate		as logic get _usualtype == UsualType.Date
			internal property IsDateTime	as logic get _usualtype == UsualType.DateTime
			internal property IsDecimal		as logic get _usualtype == UsualType.Decimal
			internal property IsFloat		as logic get _usualtype == UsualType.Float
			internal property IsInt64		as logic get _usualtype == UsualType.Int64
			internal property IsLogic		as logic get _usualtype == UsualType.Logic
			internal property IsLong		as logic get _usualtype == UsualType.Long
			internal property IsInteger		as logic get _usualtype == UsualType.Long .or. _usualtype == UsualType.Int64
			internal property Type			as UsualType get _flags:usualType 
			internal property IsNumeric as logic
				get
					switch _usualType
					case UsualType.Long
					case UsualType.Int64
					case UsualType.Float
					case UsualType.Decimal
						return true
					otherwise
						return false
					end switch
				end get
			end property
			internal property IsObject		as logic get _usualtype == UsualType.Object
			internal property IsPtr			as logic get _usualtype == UsualType.Ptr
			internal property IsSymbol		as logic get _usualtype == UsualType.Symbol
			internal property IsString		as logic get _usualtype == UsualType.String
			internal property IsByRef		as logic get _isByRef
            
            private property IsReferenceType as logic
                get
                    switch _usualType
                        case UsualType.Array
                        case UsualType.Object
                        case UsualType.Decimal
                        case UsualType.String
                            return true
                        otherwise
                            return false
                    end switch
                end get
            end property
  			internal property IsEmpty as logic
				get
				switch _usualType
				case UsualType.Array
					return _refData == null .or. ((Array)_refData):Length == 0
				case UsualType.CodeBlock
				case UsualType.Object
					return _refData == null 
				case UsualType.Date
					return _dateValue:IsEmpty
				case UsualType.DateTime
					return _dateTimeValue == DateTime.MinValue
				case UsualType.Float
					return _floatValue == 0.0
				case UsualType.Decimal
					return _decimalValue == 0
				case UsualType.Long
					return _intValue == 0
				case UsualType.Ptr
					return _ptrValue == IntPtr.Zero
				case UsualType.String
					return EmptyString(_stringValue)
				case UsualType.Symbol
					return _symValue == 0
				case UsualType.Psz
					return _ptrValue == IntPtr.Zero
				case UsualType.Void
					return true
				otherwise
					Debug.Fail( "Unhandled data type in Usual:Empty()" )
				end switch
				return false
				end get
			end property
          
            internal property IsNil as logic
                get
                    return self:_usualType == UsualType.Void .or. ;
						(self:IsReferenceType .and. self:_refData  == null) .or. ;
						(self:_usualType == UsualType.Ptr .and. self:_ptrValue == IntPtr.Zero)
                    
                end get
            end property

            internal property SystemType as System.Type
                get
					switch _usualType
					case UsualType.Array
						return typeof(Array)
					case UsualType.Codeblock
						return typeof(Codeblock)
					case UsualType.Date
						return typeof(Date)
					case UsualType.DateTime
						return typeof(System.DateTime)
					case UsualType.Decimal
						return typeof(System.Decimal)
					case UsualType.Float
						return typeof(Float)
					case UsualType.Long
						return typeof(INT)
					case UsualType.Int64
						return typeof(INT64)
					case UsualType.Logic
						return typeof(LOGIC)
					case UsualType.OBJECT
						return typeof(OBJECT)
					case UsualType.PTR
						return typeof(IntPtr)
					case UsualType.STRING
						return typeof(STRING)
					case UsualType.SYMBOL
						return typeof(SYMBOL)
					case UsualType.VOID
						return typeof(USUAL)
					otherwise
						Debug.Fail( "Unhandled data type in Usual:SystemType" )
					end switch 					                    
					return null
                end get
				
            end property

        #endregion
        #region Properties for the Debugger
            property Value as object 
                get
                    switch _UsualType
                        case UsualType.Array		; return (Array) _refData
                        case UsualType.Date		; return _dateValue
                        case UsualType.DateTime	; return _dateTimeValue
                        case UsualType.Decimal	; return _decimalValue
                        case UsualType.Float		; return _r8Value
                        case UsualType.Int64		; return _i64Value
                        case UsualType.Long		; return _intValue
                        case UsualType.Logic		; return _logicValue
                        case UsualType.Ptr		; return _ptrValue
                        case UsualType.Symbol		; return _symValue
                        case UsualType.String		; return _stringValue
                        case UsualType.Void		; return "NIL"
                        case UsualType.Object
                        otherwise					; return _refData
                    end switch
                end get
            end property
            
        #endregion
        
        
        #region implementation IComparable
            /// <summary>This method is needed to implement the IComparable interface.</summary>
            public method CompareTo(o as object) as long
            local rhs as __Usual
            rhs := (__Usual) o
            if self:_UsualType == rhs:_UsualType
                // Compare ValueTypes
                switch _UsualType
                    case UsualType.Date		; return self:_dateValue:CompareTo(rhs:_dateValue)
                    case UsualType.DateTime	; return self:_dateTimeValue:CompareTo(rhs:_dateTimeValue)
                    case UsualType.Decimal	; return self:_decimalValue:CompareTo(rhs:_decimalValue)
                    case UsualType.Int64		; return self:_i64Value:CompareTo(rhs:_i64Value)
                    case UsualType.Logic		; return self:_logicValue:CompareTo(rhs:_logicValue)
                    case UsualType.Long		; return self:_intValue:CompareTo(rhs:_intValue)
                    case UsualType.Ptr		; return self:_ptrValue:ToInt64():CompareTo(rhs:_ptrValue:ToInt64())
                    // Uses String Comparison rules
                    // Vulcan does a case insensitive comparison ?
                    case UsualType.String		; return String.Compare( _stringValue,  rhs:_stringValue)
                    case UsualType.Symbol		; return String.Compare( (string) self:_symValue, (string) rhs:_symValue)
                    otherwise					; return 0
                end switch
            else
                // Type of LHS different from type of RHS
                switch self:_UsualType
                    case UsualType.Void
                        return -1
                    case UsualType.Date
                        // Upscale when needed to avoid overflow errors
                        switch rhs:_UsualType
                            case UsualType.DateTime	; return _dateValue:CompareTo((Date) rhs:_dateTimeValue)
                            case UsualType.Decimal	; return ((System.Decimal) (int) _dateValue):CompareTo(rhs:_decimalValue)
                            case UsualType.Float		; return ((real8) (int) _dateValue):CompareTo(rhs:_r8Value)
                            case UsualType.Int64		; return ( (int64) (int) _dateValue):CompareTo(rhs:_i64Value)
                            case UsualType.Long		; return ((int) _dateValue):CompareTo(rhs:_intValue)
                            otherwise
                                nop	// uses comparison by type
                        end switch
                    
                    case UsualType.Float
                        switch rhs:_usualType
                            case UsualType.Date		; return _r8Value:CompareTo( (real8) (int) rhs:_dateValue)
                            case UsualType.Decimal	; return _r8Value:CompareTo( (real8) rhs:_decimalValue)
                            case UsualType.Long		; return _r8Value:CompareTo( (real8) rhs:_intValue)
                            case UsualType.Int64		; return _r8Value:CompareTo( (real8) rhs:_i64Value)
                            otherwise
                                nop	// uses comparison by type
                        end switch
                    
                    case UsualType.Long
                        // Upscale when needed to avoid overflow errors
                        switch rhs:_usualType
                            case UsualType.Date		; return _intValue:CompareTo((int) rhs:_dateValue)
                            case UsualType.Int64		; return ((int64)_intValue):CompareTo(rhs:_i64Value)
                            case UsualType.Float		; return ((real8)_intValue):CompareTo(rhs:_r8Value)
                            case UsualType.Decimal	; return ((System.Decimal)_intValue):CompareTo(rhs:_decimalValue)
                            otherwise
                                nop	// uses comparison by type
                        end switch
                    
                    case UsualType.Int64
                        switch rhs:_usualType
                            case UsualType.Date		; return _i64Value:CompareTo((int) rhs:_dateValue)
                            case UsualType.Long		; return _i64Value:CompareTo( rhs:_intValue)
                            case UsualType.Float		; return _i64Value:CompareTo( rhs:_r8Value)
                            case UsualType.Decimal	; return _i64Value:CompareTo( rhs:_decimalValue)
                            otherwise
                                nop	// uses comparison by type
                        end switch
                    
                    case UsualType.Decimal
                        switch rhs:_usualType
                            case UsualType.Date		; return _decimalValue:CompareTo((int) rhs:_dateValue)
                            case UsualType.Long		; return _decimalValue:CompareTo(rhs:_intValue)
                            case UsualType.Float		; return _decimalValue:CompareTo(rhs:_r8Value)
                            case UsualType.Int64		; return _decimalValue:CompareTo(rhs:_i64Value)
                            otherwise
                                nop	// uses comparison by type
                        end switch
                end switch 
            endif
            if rhs:_usualType == UsualType.Void
                return 1
            elseif self:_usualType > rhs:_usualType
                return 1
            elseif self:_usualType < rhs:_usualType
                return -1
            endif
            return 0
            
            
            
        #endregion
        
        #region Comparison Operators 
		/// <summary>This operator is used in code generated by the compiler when needed.</summary>
        static operator >(lhs as __Usual, rhs as __Usual) as logic
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue > rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue > rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue > rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue > rhs:_decimalValue
                        otherwise
                            throw BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value > rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value > rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value > rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value > rhs:_decimalValue
                        otherwise
                            throw BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_r8Value > rhs:_intValue
                        case UsualType.Int64		; return lhs:_r8Value > rhs:_i64Value
                        case UsualType.Float		; return lhs:_r8Value > rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_r8Value > (real8) rhs:_decimalValue
                        otherwise
                            throw BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue > rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue > rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue > (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue >  rhs:_decimalValue
                        otherwise
                            throw BinaryError(">", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.String
                    if rhs:_usualType == UsualType.String
                        return lhs:_stringValue> rhs:_stringValue
                    else
                        nop // error below
                    endif
                
                case UsualType.Symbol
                    if rhs:_usualType == UsualType.Symbol
                        return lhs:_symValue > rhs:_symValue
                    else
                        nop // error below
                    endif
                case UsualType.Date
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue > rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateValue > (Date) rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                case UsualType.DateTime
                    switch (rhs:_usualType)
                        case UsualType.DateTime	; return lhs:_dateTimeValue > rhs:_dateTimeValue
                        case UsualType.Date		; return lhs:_dateTimeValue > (DateTime) rhs:_dateValue
                        otherwise
                            nop // error below
                    end switch
                otherwise
                    nop // error below
            end switch
            throw BinaryError(">", __CavoStr(VOErrors.ARGSINCOMPATIBLE), false, lhs, rhs)
            
			/// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator >=(lhs as __Usual, rhs as __Usual) as logic
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType	
                        case UsualType.Long		; return lhs:_intValue >= rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue >= rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue >= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue >= rhs:_decimalValue
                        otherwise
                            throw BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value >= rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value >= rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value >= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value >= rhs:_decimalValue
                        otherwise
                            throw BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_r8Value >= rhs:_intValue
                        case UsualType.Int64		; return lhs:_r8Value >= rhs:_i64Value
                        case UsualType.Float		; return lhs:_r8Value >= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_r8Value >= (real8) rhs:_decimalValue
                        otherwise
                            throw BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue >= rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue >= rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue >= (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue >=  rhs:_decimalValue
                        otherwise
                            throw BinaryError(">=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.String
                    if rhs:_usualType == UsualType.String
                        return lhs:_stringValue>= rhs:_stringValue
                    else
                        nop // error below
                    endif
                
                case UsualType.Symbol
                    if rhs:_usualType == UsualType.Symbol
                        return lhs:_symValue >= rhs:_symValue
                    else
                        nop // error below
                    endif
                case UsualType.Date
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue		>= rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateTimeValue >= rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                case UsualType.DateTime
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue		>=  rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateTimeValue >=  rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                otherwise
                    throw BinaryError(">=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError(">=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
			static operator <(lhs as __Usual, rhs as __Usual) as logic
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue < rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue < rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue < rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue < rhs:_decimalValue
                        otherwise
                            throw BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value < rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value < rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value < rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value < rhs:_decimalValue
                        otherwise
                            throw BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_r8Value < rhs:_intValue
                        case UsualType.Int64		; return lhs:_r8Value < rhs:_i64Value
                        case UsualType.Float		; return lhs:_r8Value < rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_r8Value < (real8) rhs:_decimalValue
                        otherwise
                            throw BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue < rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue < rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue < (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue <  rhs:_decimalValue
                        otherwise
                            throw BinaryError("<", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.String
                    if rhs:_usualType == UsualType.String
                        return lhs:_stringValue< rhs:_stringValue
                    else
                        nop // error below
                    endif
                
                case UsualType.Symbol
                    if rhs:_usualType == UsualType.Symbol
                        return lhs:_symValue < rhs:_symValue
                    else
                        nop // error below
                    endif
                case UsualType.Date
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue	< rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateValue < (Date) rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                case UsualType.DateTime
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue		<  rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateTimeValue <  rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                otherwise
                    throw BinaryError("<", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("<", __CavoStr(VOErrors.ARGSINCOMPATIBLE), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator <=(lhs as __Usual, rhs as __Usual) as logic
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue <= rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue <= rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue <= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue <= rhs:_decimalValue
                        otherwise
                            throw BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value <= rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value <= rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value <= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value <= rhs:_decimalValue
                        otherwise
                            throw BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_r8Value <= rhs:_intValue
                        case UsualType.Int64		; return lhs:_r8Value <= rhs:_i64Value
                        case UsualType.Float		; return lhs:_r8Value <= rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_r8Value <= (real8) rhs:_decimalValue
                        otherwise
                            throw BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue <= rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue <= rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue <= (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue <=  rhs:_decimalValue
                        otherwise
                            throw BinaryError("<=", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
                    end switch
                
                case UsualType.String
                    if rhs:_usualType == UsualType.String
                        return  lhs:_stringValue<= rhs:_stringValue
                    else
                        nop // error below
                    endif
                
                case UsualType.Symbol
                    if rhs:_usualType == UsualType.Symbol
                        return lhs:_symValue <= rhs:_symValue
                    else
                        nop // error below
                    endif
                case UsualType.Date
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue	<= rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateValue <= (Date) rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                case UsualType.DateTime
                    switch (rhs:_usualType)
                        case UsualType.Date		; return lhs:_dateValue		<=  rhs:_dateValue
                        case UsualType.DateTime	; return lhs:_dateTimeValue <=  rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                otherwise
                    throw BinaryError("<=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("<=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), false, lhs, rhs)
        #endregion
        
        #region Operators for Equality
            public method Equals(obj as object) as logic
				if obj == null
					return self:IsNil
				endif
				return UsualEquals((USUAL) obj, "Usual.Equals()")

            
            public method GetHashCode() as int
				local oValue as object
				oValue := self:Value
				if oValue == NULL
					return 0
				endif
				return oValue:GetHashCode()
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator ==(lhs as __Usual, rhs as __Usual) as logic
				return lhs:UsualEquals(rhs, "==")
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator !=(lhs as __Usual, rhs as __Usual) as logic
            if lhs:_usualType == UsualType.STRING .and. rhs:_usualType == UsualType.STRING
                // Todo __StringEquals
                return ! String.Equals(  lhs:_stringValue, rhs:_stringValue)
            else
                return ! lhs:UsualEquals(rhs, "!=")
            endif
            
            method UsualEquals( rhs as __Usual, op as string) as logic
			if rhs:IsNil
				return self:IsNil
			endif
            switch self:_usualType
                case UsualType.Object
                    if rhs:_usualType == UsualType.Object
                        return self:_refData == rhs:_refData
                    else
                        nop // error below
                    endif
                
                case UsualType.Void
                    return rhs:_usualType == UsualType.Void
                
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return self:_intValue == rhs:_intValue
                        case UsualType.Int64		; return (int64) self:_intValue == rhs:_i64Value	// cast lhs to int64 to avoid overflow 
                        case UsualType.Float		; return (real8) self:_intValue == rhs:_r8Value // cast lhs to real8 to avoid overflow 
                        case UsualType.Decimal	; return (System.Decimal) self:_intValue == rhs:_decimalValue	// cast lhs to decimal to avoid overflow 
                        case UsualType.Logic		; return rhs:_logicValue == (self:_intValue <> 0)
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return _i64Value == (int64) rhs:_intValue
                        case UsualType.Int64		; return _i64Value == rhs:_i64Value
                        case UsualType.Float		; return  (real8) _i64Value == rhs:_r8Value
                        case UsualType.Decimal	; return _i64Value == rhs:_decimalValue
                        case UsualType.Logic		; return rhs:_logicValue == (self:_i64Value <> 0)
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return self:_r8Value == (real8) rhs:_intValue
                        case UsualType.Int64		; return self:_r8Value == (real8) rhs:_i64Value
                        case UsualType.Float		; return self:_r8Value ==  rhs:_r8Value
                        case UsualType.Decimal	; return self:_r8Value ==  (real8) rhs:_decimalValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return self:_decimalValue == rhs:_intValue
                        case UsualType.Int64		; return self:_decimalValue == rhs:_i64Value
                        case UsualType.Float		; return self:_decimalValue == (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return self:_decimalValue == rhs:_decimalValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.LOGIC
                    switch rhs:_usualType
                        case UsualType.LOGIC		; return self:_logicValue == rhs:_logicValue
                        case UsualType.Long		; return self:_logicValue == (rhs:_intValue <> 0)
                        case UsualType.Int64		; return self:_logicValue == (rhs:_i64Value <> 0)
                        case UsualType.Decimal	; return self:_logicValue == (rhs:_decimalValue <> 0)
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.DATE
                    switch rhs:_usualType
                        case UsualType.DATE		; return self:_dateValue == rhs:_dateValue
                        case UsualType.DateTime	; return self:_dateValue == (Date) rhs:_dateTimeValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.DateTime
                    switch rhs:_usualType
                        case UsualType.DateTime	; return self:_dateTimeValue == rhs:_dateTimeValue
                        case UsualType.DATE		; return self:_dateTimeValue == (DateTime) rhs:_dateValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.STRING
                    switch rhs:_usualType
                        case UsualType.STRING		; return self:_stringValue== rhs:_stringValue
                        case UsualType.Symbol		; return self:_stringValue == rhs:_symValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.ARRAY
                    switch rhs:_usualType
                        case UsualType.ARRAY		; return self:_refData == rhs:_refData
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.CodeBlock
                    switch rhs:_usualType
                        case UsualType.CodeBlock	; return self:_refData == rhs:_refData
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Ptr
                    switch rhs:_usualType
                        case UsualType.Ptr		; return self:_ptrValue == rhs:_ptrValue
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Symbol
                    switch rhs:_usualType
                        case UsualType.Symbol		; return self:_symValue == rhs:_symValue
                        case UsualType.String		; return self:_symValue == rhs:_stringValue
                        otherwise
                            nop // error below
                    end switch
                otherwise
                    throw BinaryError(op, __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, self, rhs)
                
            end switch
            throw BinaryError(op, __CavoStr(VOErrors.ARGSINCOMPATIBLE), false, self, rhs)
            
        #endregion
        
        #region Unary Operators
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator !(u as __Usual) as logic
            if u:_usualType == UsualType.LOGIC
                return !u:_logicValue
            endif
            throw UnaryError("!", u)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator ~(u as __Usual) as __Usual
            if u:_usualType == UsualType.Long
                return ~u:_intValue
            endif
            if u:_usualType == UsualType.Int64
                return ~u:_i64Value
            endif
            throw UnaryError("~", u)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator -(u as __Usual) as __Usual
            switch u:_usualType
                case UsualType.LONG		; return -u:_intValue
                case UsualType.Int64		; return -u:_i64Value
                case UsualType.Float		; return -u:_floatValue
                case UsualType.Decimal	; return -u:_decimalValue
                otherwise
                    throw UnaryError("-", u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator +(u as __Usual) as __Usual
            switch u:_usualType
                case UsualType.LONG		; return u:_intValue
                case UsualType.Int64		; return u:_i64Value
                case UsualType.Float		; return u:_floatValue
                case UsualType.Decimal	; return u:_decimalValue
                otherwise
                    throw UnaryError("+", u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
			static operator --(u as __Usual) as __Usual
            switch u:_usualType
                case UsualType.LONG		; return u:_intValue - 1
                case UsualType.Int64		; return u:_i64Value - 1
                case UsualType.Float		; return u:_floatValue -1
                case UsualType.Decimal	; return u:_decimalValue - 1 
                otherwise					
                    throw UnaryError("--", u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator ++(u as __Usual) as __Usual
            switch u:_usualType
                case UsualType.LONG		; return u:_intValue + 1	
                case UsualType.Int64		; return u:_i64Value + 1
                case UsualType.Float		; return u:_floatValue +1
                case UsualType.Decimal	; return u:_decimalValue + 1 
                otherwise
                    throw UnaryError("++", u)
            end switch
            
        #endregion
        #region Numeric Operators for Add, Delete etc (also for strings)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator +(lhs as __Usual, rhs as __Usual) as __Usual
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType	
                        case UsualType.Long		; return lhs:_intValue + rhs:_intValue 
                        case UsualType.Int64		; return lhs:_intValue + rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue + rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue + rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value + rhs:_intValue 
                        case UsualType.Int64		; return lhs:_i64Value + rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value + rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value + rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return Float{lhs:_r8Value + rhs:_intValue, lhs:_width, lhs:_decimals}
                        case UsualType.Int64		; return Float{lhs:_r8Value + rhs:_i64Value, lhs:_width, lhs:_decimals}
                        case UsualType.Float		; return Float{lhs:_r8Value + rhs:_r8Value, lhs:_width, lhs:_decimals}
                        case UsualType.Decimal	; return Float{lhs:_r8Value + (real8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue + rhs:_intValue 
                        case UsualType.Int64		; return lhs:_decimalValue + rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue + (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue + rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.String
                    switch rhs:_usualType
                        case UsualType.String		; return lhs:_stringValue+ rhs:_stringValue
                        otherwise
                            throw BinaryError("+", __CavoStr(VOErrors.ARGNOTSTRING), false, lhs, rhs)
                    end switch
                case UsualType.Date
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_dateValue + rhs:_intValue 
                        case UsualType.Int64	; return lhs:_dateValue + rhs:_i64Value
                        CASE UsualType.Float	; RETURN lhs:_dateValue + rhs:_r8Value
						// Note We can't add dates, but we can subtract dates
                        otherwise
                            throw BinaryError("+", __CavoStr(VOErrors.DATE_ADD), false, lhs, rhs)
                    end switch
                case UsualType.DateTime
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_dateTimeValue:Add( TimeSpan.FromDays(rhs:_intValue ))
                        case UsualType.Int64	; return lhs:_dateTimeValue:Add(TimeSpan.FromDays(rhs:_i64Value))
                        CASE UsualType.Float	; RETURN lhs:_dateTimeValue:Add(TimeSpan.FromDays(rhs:_r8Value))
						// Note We can't add dates, but we can subtract dates
                        otherwise
                            throw BinaryError("+", __CavoStr(VOErrors.DATE_ADD), false, lhs, rhs)
                    end switch
                
                otherwise
                    throw BinaryError("+", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("+", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator -(lhs as __Usual, rhs as __Usual) as __Usual
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue - rhs:_intValue 
                        case UsualType.Int64		; return lhs:_intValue - rhs:_i64Value
                        case UsualType.Float		; return lhs:_intValue - rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_intValue - rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value - rhs:_intValue 
                        case UsualType.Int64		; return lhs:_i64Value - rhs:_i64Value
                        case UsualType.Float		; return lhs:_i64Value - rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_i64Value - rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return Float{lhs:_r8Value - rhs:_intValue ,lhs:_width, lhs:_decimals}
                        case UsualType.Int64		; return Float{lhs:_r8Value - rhs:_i64Value ,lhs:_width, lhs:_decimals}
                        case UsualType.Float		; return Float{lhs:_r8Value - rhs:_r8Value	,lhs:_width, lhs:_decimals}
                        case UsualType.Decimal	; return Float{lhs:_r8Value - (real8) rhs:_decimalValue ,lhs:_width, lhs:_decimals}
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue - rhs:_intValue 
                        case UsualType.Int64		; return lhs:_decimalValue - rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue - (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue - rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.String
                    switch rhs:_usualType
                        case UsualType.String		; return CompilerServices.__StringSubtract(lhs, rhs)
                        otherwise					; throw BinaryError("-", __CavoStr(VOErrors.ARGNOTSTRING), false, lhs, rhs)
                    end switch
                case UsualType.Date
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_dateValue - rhs:_intValue 
                        case UsualType.Int64		; return lhs:_dateValue - rhs:_i64Value
                        case UsualType.Float		; return lhs:_dateValue - rhs:_r8Value
                        case UsualType.Date			; return lhs:_dateValue - rhs:_dateValue
                        case UsualType.DateTime		; return lhs:_dateValue - (Date) rhs:_dateTimeValue
                        otherwise					; throw BinaryError("+", __CavoStr(VOErrors.DATE_SUBTRACT), false, lhs, rhs)
                    end switch
                
                case UsualType.DateTime
                    switch rhs:_usualType
                        case UsualType.Long			; return lhs:_dateTimeValue:Subtract(TimeSpan{rhs:_intValue,0,0,0})
                        case UsualType.Int64		; return lhs:_dateTimeValue:Subtract( TimeSpan{(int)rhs:_i64Value,0,0,0})
                        case UsualType.Float		; return lhs:_dateTimeValue:Subtract( TimeSpan{(int)rhs:_r8Value,0,0,0})
                        case UsualType.Date			; return lhs:_dateTimeValue:Subtract((DateTime) rhs:_dateValue):Days
                        case UsualType.DateTime		; return lhs:_dateTimeValue:Subtract( rhs:_dateTimeValue):Days
                        otherwise					; throw BinaryError("+", __CavoStr(VOErrors.DATE_SUBTRACT), false, lhs, rhs)
                    end switch
                
                otherwise
                    throw BinaryError("-", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("-", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)

            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator /(lhs as __Usual, rhs as __Usual) as __Usual
            
            switch lhs:_usualType
                
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long
                            local result as int
                            local remainder as int
                            result := Math.DivRem(lhs:_intValue, rhs:_intValue, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_intValue / rhs:_intValue
                            endif
                        case UsualType.Int64
                            local result as int64
                            local remainder as int64
                            result := Math.DivRem((int64) lhs:_intValue, rhs:_i64Value, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_intValue / rhs:_i64Value
                            endif
                        case UsualType.Float
                            return Float{lhs:_intValue / rhs:_r8Value, rhs:_width, rhs:_decimals}
                        
                        case UsualType.Decimal
                            local result as int64
                            local remainder as int64
                            result := Math.DivRem((int64) lhs:_intValue, (int64) rhs:_decimalValue, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_intValue / rhs:_decimalValue
                            endif
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long
                            local result as int64
                            local remainder as int64
                            result := Math.DivRem(lhs:_i64Value, rhs:_intValue, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_i64Value / rhs:_intValue
                            endif
                        case UsualType.Int64
                            local result as int64
                            local remainder as int64
                            result := Math.DivRem( lhs:_i64Value, rhs:_i64Value, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_i64Value / rhs:_i64Value
                            endif
                        case UsualType.Float
                            return Float{lhs:_i64Value / rhs:_r8Value, rhs:_width, rhs:_decimals}
                        case UsualType.Decimal
                            local result as int64
                            local remainder as int64
                            result := Math.DivRem(lhs:_i64Value, (int64) rhs:_decimalValue, out remainder)
                            if remainder == 0
                                return result
                            else
                                return lhs:_i64Value / rhs:_decimalValue
                            endif
                        otherwise
                            nop // error below
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return Float{lhs:_r8Value / rhs:_intValue, lhs:_width, lhs:_decimals}
                        case UsualType.Int64		; return Float{lhs:_r8Value / rhs:_i64Value, lhs:_width, lhs:_decimals}
                        case UsualType.Float		; return Float{lhs:_r8Value / rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        case UsualType.Decimal	; return Float{lhs:_r8Value / (real8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue / rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue / rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue / (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue / rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                otherwise
                    throw BinaryError("/", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("/", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator %(lhs as __Usual, rhs as __Usual) as __Usual
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue % rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue % rhs:_i64Value
                        case UsualType.Float		; return Float{lhs:_intValue % rhs:_r8Value, rhs:_width, rhs:_decimals}
                        case UsualType.Decimal	; return lhs:_intValue % rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value % rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value % rhs:_i64Value
                        case UsualType.Float		; return Float{lhs:_i64Value % rhs:_r8Value, rhs:_width, rhs:_decimals}
                        case UsualType.Decimal	; return lhs:_i64Value % rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType
                        case UsualType.Long		; return Float{lhs:_r8Value % rhs:_intValue, lhs:_width, lhs:_decimals}
                        case UsualType.Int64		; return Float{lhs:_r8Value % rhs:_i64Value, lhs:_width, lhs:_decimals}
                        case UsualType.Float		; return Float{lhs:_r8Value % rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        case UsualType.Decimal	; return Float{lhs:_r8Value % (real8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue % rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue % rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue % (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue %  rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                
                otherwise
                    throw BinaryError("%", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("%", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator *(lhs as __Usual, rhs as __Usual) as __Usual
            switch lhs:_usualType
                case UsualType.Long
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_intValue * rhs:_intValue
                        case UsualType.Int64		; return lhs:_intValue * rhs:_i64Value
                        case UsualType.Float		; return Float{lhs:_intValue * rhs:_r8Value, rhs:_width, rhs:_decimals}
                        case UsualType.Decimal	; return lhs:_intValue * rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Int64
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_i64Value * rhs:_intValue
                        case UsualType.Int64		; return lhs:_i64Value * rhs:_i64Value
                        case UsualType.Float		; return Float{lhs:_i64Value * rhs:_r8Value, rhs:_width, rhs:_decimals}
                        case UsualType.Decimal	; return lhs:_i64Value * rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Float
                    switch rhs:_usualType		
                        case UsualType.Long		; return Float{lhs:_r8Value * rhs:_intValue, lhs:_width, lhs:_decimals}
                        case UsualType.Int64		; return Float{lhs:_r8Value * rhs:_i64Value, lhs:_width, lhs:_decimals}
                        case UsualType.Float		; return Float{lhs:_r8Value * rhs:_r8Value, Math.Max(lhs:_width,rhs:_width), lhs:_decimals+ rhs:_decimals}
                        case UsualType.Decimal	; return Float{lhs:_r8Value * (real8) rhs:_decimalValue, lhs:_width, lhs:_decimals}
                        otherwise					; nop // error below
                    end switch
                
                case UsualType.Decimal
                    switch rhs:_usualType
                        case UsualType.Long		; return lhs:_decimalValue * rhs:_intValue
                        case UsualType.Int64		; return lhs:_decimalValue * rhs:_i64Value
                        case UsualType.Float		; return lhs:_decimalValue * (System.Decimal) rhs:_r8Value
                        case UsualType.Decimal	; return lhs:_decimalValue *  rhs:_decimalValue
                        otherwise					; nop // error below
                    end switch
                
                otherwise
                    throw BinaryError("*", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
            end switch
            throw BinaryError("*", __CavoStr(VOErrors.ARGNOTNUMERIC), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator >>(lhs as __Usual, rhs as int) as __Usual
            // Right shift
            switch lhs:_usualType
                case UsualType.Long	; return lhs:_intValue >> rhs
                case UsualType.Int64	; return lhs:_i64Value >> rhs
                otherwise				
                    throw BinaryError(">>", __CavoStr(VOErrors.ARGNOTINTEGER), true, lhs, rhs)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator <<(lhs as __Usual, rhs as long) as __Usual
            // Left shift
            switch (lhs:_usualType)
                case UsualType.Long	; return lhs:_intValue << rhs
                case UsualType.Int64	; return lhs:_i64Value << rhs
                otherwise
                    throw BinaryError("<<", __CavoStr(VOErrors.ARGNOTINTEGER), true, lhs, rhs)
            end switch
            
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator &(lhs as __Usual, rhs as __Usual) as __Usual
            // Bitwise And
            switch (lhs:_usualType)
                case UsualType.Long
                    switch (rhs:_usualType)
                        case UsualType.Long		; return lhs:_intValue & rhs:_intValue
                        case UsualType.Int64		; return (int64) lhs:_intValue & rhs:_i64Value
                        otherwise					; nop // error below
                    end switch
                case UsualType.Int64
                    switch (rhs:_usualType)
                        case UsualType.Long		; return lhs:_i64Value & (int64) rhs:_intValue
                        case UsualType.Int64	; return  lhs:_i64Value & rhs:_i64Value
                        otherwise					; nop // error below
                    end switch
                otherwise
                    throw BinaryError("&", __CavoStr(VOErrors.ARGNOTINTEGER), true, lhs, rhs)
            end switch
            throw BinaryError("&", __CavoStr(VOErrors.ARGNOTINTEGER), false, lhs, rhs)
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator |(lhs as __Usual, rhs as __Usual) as __Usual
            // Bitwise or
            switch (lhs:_usualType)
                case UsualType.Long
                    switch (rhs:_usualType)
                        case UsualType.Long		; return lhs:_intValue | rhs:_intValue
                        case UsualType.Int64		; return (int64) lhs:_intValue | rhs:_i64Value
                        otherwise					; nop // error below
                    end switch
                case UsualType.Int64
                    switch (rhs:_usualType)
                        case UsualType.Long		; return lhs:_i64Value | (int64) rhs:_intValue
                        case UsualType.Int64		; return  lhs:_i64Value | rhs:_i64Value
                        otherwise					; nop // error below
                    end switch
                otherwise
                    throw BinaryError("|", __CavoStr(VOErrors.ARGNOTINTEGER), true, lhs, rhs)
            end switch
            throw BinaryError("|", __CavoStr(VOErrors.ARGNOTINTEGER), false, lhs, rhs)
        #endregion
        
        #region Implicit From Usual to Other Type
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as Array
            switch u:_usualType
                case UsualType.Array	; return (Array) u:_refData
                case UsualType.Void	; return null
                case UsualType.Object	
                    if u:_refData== null
                        return null
                    elseif u:_refData is Array
                        return (Array) u:_refData
                    endif
            end switch
            throw ConversionError(ARRAY, typeof(Array), u)
            
            // Todo
            //STATIC OPERATOR IMPLICIT(u AS __Usual) AS CodeBlock
            //	THROW NotImplementedException{}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as logic
            switch u:_usualType
                case UsualType.Logic		; return u:_logicValue
                case UsualType.Long		; return u:_intValue != 0
                case UsualType.Int64		; return u:_i64Value != 0
                case UsualType.Decimal	; return u:_decimalValue != 0
                case UsualType.Void		; return false
                otherwise
                    throw ConversionError(LOGIC, typeof(logic), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as Date
            switch u:_usualType
                case UsualType.Date		; return u:_dateValue
                case UsualType.DateTime	; return (Date) u:_dateTimeValue
                case UsualType.Void		; return Date{0}
                otherwise
                    throw ConversionError(DATE, typeof(Date), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as DateTime
            switch u:_usualType
                case UsualType.Date		; return (DateTime) u:_dateValue
                case UsualType.DateTime	; return u:_dateTimeValue
                case UsualType.Void		; return DateTime.MinValue
                otherwise
                    throw ConversionError(DATE, typeof(Date), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as System.IntPtr
            switch u:_usualType
                CASE UsualType.Ptr		; RETURN u:_ptrValue
				case UsualType.Psz		; return u:_ptrValue
                case UsualType.LONG		; return (IntPtr) u:_intValue
                case UsualType.Int64		; return (IntPtr) u:_i64Value
                case UsualType.Decimal	; return (IntPtr) u:_decimalValue 
                case UsualType.Void		; return IntPtr.Zero
                otherwise
                    throw ConversionError(PTR, typeof(IntPtr), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as string
            switch u:_usualType
                case UsualType.String	; return u:_stringValue
                case UsualType.Void	; return ""
                case UsualType.SYMBOL	; return (string) u:_symValue
                otherwise
                    throw ConversionError(STRING, typeof(string), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as Symbol
            switch u:_usualType
                case UsualType.String	; return (Symbol) u:_stringValue
                case UsualType.Void	; return Symbol{""}
                case UsualType.SYMBOL	; return u:_symValue
                otherwise
                    throw ConversionError(SYMBOL, typeof(Symbol), u)
            end switch
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as Psz
            switch u:_usualType
                case UsualType.Ptr	; return (Psz) u:_ptrValue
                case UsualType.String	; return Psz{u:_stringValue}
                case UsualType.Void	; return Null_Psz
                otherwise
                    throw ConversionError(PSZ, typeof(Psz), u)
            end switch
            
        #endregion
        #region Implicit Numeric Operators
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as byte
            try
                switch u:_usualType
                    case UsualType.Long		; return checked((byte) u:_intValue)
                    case UsualType.Int64		; return checked((byte) u:_i64Value)
                    case UsualType.Float		
						if RuntimeState.CompilerOptionVO11
							return Convert.ToByte(u:_r8Value)
						else
							return checked((byte) u:_r8Value)
						endif
                    case UsualType.Logic		; return iif(u:_logicValue, 1, 0)
                    case UsualType.Decimal	
						if RuntimeState.CompilerOptionVO11
							return Convert.ToByte(u:_decimalValue )
						else
							return checked((byte) u:_decimalValue )
						endif
                    case UsualType.Void		; return  0
                    otherwise
                        throw ConversionError(BYTE, typeof(byte), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "BYTE", typeof(byte), u)
            end try
            return 0
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as short
            try
                // todo use CompilerOptionVO11 for types with decimal
                switch u:_usualType
                    case UsualType.Long	; return checked((short) u:_intValue)
                    case UsualType.Int64	; return checked((short) u:_i64Value)
                    case UsualType.Float	
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt16(u:_r8value)
						else
							return checked((short) u:_r8Value)
						endif

                    case UsualType.Decimal
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt16(u:_decimalValue )
						else
							return checked((short) u:_decimalValue )
						endif

                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(SHORT, typeof(short), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "SHORT", typeof(short), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as long
            try
                switch u:_usualType
                    case UsualType.Long	; return u:_intValue
                    case UsualType.Int64	; return checked((long) u:_i64Value)
                    case UsualType.Float	
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt32(u:_r8Value)
						else
							return  checked((long) u:_r8Value)
						endif
                    case UsualType.Decimal
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt32(u:_decimalValue )
						else
							return checked((long) u:_decimalValue )
						endif
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(LONG, typeof(long), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "LONG", typeof(long), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as int64
            try
                switch u:_usualType
                    case UsualType.Long	; return u:_intValue
                    case UsualType.Int64	; return checked((int64) u:_i64Value)
                    case UsualType.Float	
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt64(u:_r8Value)
						else
							return  checked((int64) u:_r8Value)
						endif
                    case UsualType.Decimal
						if RuntimeState.CompilerOptionVO11
							return Convert.ToInt64(u:_decimalValue )
						else
							return checked((int64) u:_decimalValue )
						endif

                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(INT64, typeof(int64), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "INT64", typeof(int64), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as System.Decimal
            try
                switch u:_usualType
                    case UsualType.Long	; return checked(u:_intValue)
                    case UsualType.Int64	; return checked(u:_i64Value)
                    case UsualType.Float	; return checked((System.Decimal) u:_r8Value)
                    case UsualType.Decimal; return checked(u:_decimalValue)
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(UsualType.DECIMAL, typeof(int64), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "DECIMAL", typeof(int64), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as SByte
            try
                switch u:_usualType
                    case UsualType.Long	; return checked( (SByte) u:_intValue)
                    case UsualType.Int64	; return checked( (SByte) u:_i64Value)
                    case UsualType.Float	; return checked( (SByte) u:_r8Value)
                    case UsualType.Decimal; return checked((SByte) u:_decimalValue )
                    case UsualType.Logic	; return (SByte) iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(BYTE, typeof(SByte), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "SBYTE", typeof(SByte), u)
            end try
            
            // Unsigned
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as word
            try
                switch u:_usualType
                    case UsualType.Long	; return checked((word) u:_intValue)
                    case UsualType.Int64	; return checked((word) u:_i64Value)
                    case UsualType.Float	; return checked((word) u:_r8Value)
                    case UsualType.Decimal; return checked((word) u:_decimalValue )
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(WORD, typeof(word), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "WORD", typeof(word), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as dword
            try
                switch u:_usualType
                    case UsualType.Long	; return checked((dword) u:_intValue)
                    case UsualType.Int64	; return checked((dword) u:_i64Value)
                    case UsualType.Float	; return checked((dword) u:_r8Value)
                    case UsualType.Decimal; return checked((dword) u:_decimalValue )
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(DWORD, typeof(dword), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "DWORD", typeof(dword), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as uint64
            try
                switch u:_usualType
                    case UsualType.Long	; return checked((uint64) u:_intValue)
                    case UsualType.Int64	; return checked((uint64) u:_i64Value)
                    case UsualType.Float	; return checked((uint64) u:_r8Value)
                    case UsualType.Decimal; return checked((uint64) u:_decimalValue )
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(UINT64, typeof(uint64), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "UINT64", typeof(uint64), u)
            end try
            
            // Single, Double and FLoat
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as real4
            try
                switch u:_usualType
                    case UsualType.Long	; return checked((real4) u:_intValue)
                    case UsualType.Int64	; return checked((real4) u:_i64Value)
                    case UsualType.Float	; return checked((real4) u:_r8Value)
                    case UsualType.Decimal; return checked((real4) u:_decimalValue )
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(REAL4, typeof(real4), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "REAL4", typeof(real4), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as real8
            try
                switch u:_usualType
                    case UsualType.Long	; return checked((real8) u:_intValue)
                    case UsualType.Int64	; return checked((real8) u:_i64Value)
                    case UsualType.Float	; return checked((real8) u:_r8Value)
                    case UsualType.Decimal; return checked((real8) u:_decimalValue )
                    case UsualType.Logic	; return iif(u:_logicValue, 1, 0)
                    case UsualType.Void	; return 0
                    otherwise
                        throw ConversionError(REAL8, typeof(real8), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "REAL8", typeof(real8), u)
            end try
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(u as __Usual) as Float
            try
                switch u:_usualType
                    case UsualType.Long	; return checked(Float{(real8) u:_intValue})
                    case UsualType.Int64	; return checked(Float{(real8) u:_i64Value})
                    case UsualType.Float	; return checked(Float{(real8) u:_r8Value, u:_flags:Width, u:_flags:Decimals})
                    case UsualType.Decimal; return checked(Float{(real8) u:_decimalValue})
                    case UsualType.Logic	; return Float{iif(u:_logicValue, 1, 0)}
                    case UsualType.Void	; return Float{0}
                    otherwise
                        throw ConversionError(FLOAT, typeof(Float), u)
                end switch
            catch ex as OverflowException
                throw OverflowError(ex, "FLOAT", typeof(Float), u)
            end try
            
        #endregion
        #region Implicit from Other Type to Usual

            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as object) as Usual
				local result as USUAL
				if value != null .and. value:GetType() == typeof(__Usual)
					result := (Usual) value
				elseif value == null
					result := Usual{NULL, true}
				else
					result := usual{value}
				endif
				return result

            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as logic) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as byte) as __Usual
            return __Usual{(int)value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as Array) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as Date) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as System.DateTime) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as Float) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as real8) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as short) as __Usual
            return __Usual{(int)value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as long) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as int64) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as uint64) as __Usual
            return __Usual{value}

            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as symbol) as __Usual
				return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as System.Decimal) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as System.IntPtr) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as SByte) as __Usual
            return __Usual{(int)value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as real4) as __Usual
            return __Usual{(real8)value }
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as string) as __Usual
            return __Usual{value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as word) as __Usual
            return __Usual{(int)value}
            
            /// <summary>This operator is used in code generated by the compiler when needed.</summary>
            static operator implicit(value as dword) as __Usual
            return iif((value <= 0x7fffffff),__Usual{(long)value },__Usual{(Float)value })
        #endregion
        
        #region implementation IConvertable
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToBoolean(provider as System.IFormatProvider) as logic
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToByte(provider as System.IFormatProvider) as byte
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToChar(provider as System.IFormatProvider) as char
            var o := __Usual.ToObject(self)
            if o is IConvertible
                return ((IConvertible)o):ToChar(provider)
            endif
            throw InvalidCastException{}
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToDateTime(provider as System.IFormatProvider) as System.DateTime
            return (Date) self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToDecimal(provider as System.IFormatProvider) as Decimal
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToDouble(provider as System.IFormatProvider) as real8
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToInt16(provider as System.IFormatProvider) as short
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToInt32(provider as System.IFormatProvider) as long
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToInt64(provider as System.IFormatProvider) as int64
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            static method ToObject(u as __Usual) as object
            switch u:_usualType
                case UsualType.ARRAY		; return u:_refData
                case UsualType.CodeBlock	; return u:_refData			
                case UsualType.Date		; return u:_dateValue
                case UsualType.DateTime	; return u:_dateTimeValue
                case UsualType.Decimal	; return u:_decimalValue
                case UsualType.FLOAT		; return Float{u:_r8Value, u:_width, u:_decimals}
                case UsualType.Int64		; return u:_i64Value
                case UsualType.Long		; return u:_intValue
                case UsualType.LOGIC		; return u:_logicValue
                case UsualType.OBJECT		; return u:_refData
                case UsualType.PTR		; return u:_ptrValue
                case UsualType.STRING		; return u:_refData
                case UsualType.SYMBOL		; return u:_symValue
                case UsualType.Void		; return null
                otherwise					; return null
            end switch
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToSByte(provider as System.IFormatProvider) as SByte
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToSingle(provider as System.IFormatProvider) as real4
            return self
           
			public method AsString() as string strict
				return self:ToString()
			
			
			public method Clone() as usual
				// clone types that need cloning
				local result as usual
				switch self:_usualType
				case UsualType.Object
					result := usual{self:value}
				case UsualType.String
					result := usual { String.Copy(self:_stringValue)}
				case UsualType.Array
					result := usual { Aclone(self:_arrayValue) }
				otherwise
					result := self
				end switch
				return result
				 
            public method ToString() as string
            local strResult as string
            
            switch (self:_usualType)
                case UsualType.Array		; strResult := iif (self:_refData == null, "NULL_ARRAY", self:_arrayValue:ToString())
                case UsualType.CODEBLOCK  ; strResult := iif (self:_refData == null, "NULL_CODEBLOCK", self:_codeblockValue:ToString())
                case UsualType.OBJECT		; strResult := iif (self:_refData == null, "NULL_OBJECT", self:_refData:ToString())
                case UsualType.Date		; strResult := self:_dateValue:ToString()
                case UsualType.DateTime	; strResult := self:_dateTimeValue:ToString()
                case UsualType.Decimal	; strResult := iif (self:_refData == null, "0", self:_decimalValue:ToString())
                case UsualType.Float		; strResult := self:_r8Value:ToString()
                case UsualType.Long		; strResult := self:_intValue:ToString()
                case UsualType.Int64		; strResult := self:_i64Value:ToString()
                case UsualType.LOGIC		; strResult := iif(!self:_logicValue , ".F." , ".T.")
                case UsualType.PTR		; strResult := self:_ptrValue:ToString()
                case UsualType.STRING		; strResult := iif (self:_refData == null, "NULL_STRING", self:_stringValue:ToString())
                case UsualType.Symbol		; strResult := self:_symValue:ToString()
                case UsualType.Void		; strResult := "NIL"
                otherwise					; strResult := ""
            end switch
            return strResult
            
            
            public method ToString(provider as System.IFormatProvider) as string
            return self:ToString()
            
            public method ToType(conversionType as System.Type, provider as System.IFormatProvider) as object
            if conversionType:IsPointer
                switch self:_usualType	
                    case UsualType.PTR	; return _ptrValue
                    case UsualType.Long	; return (IntPtr) _intValue
                    case UsualType.Int64	; return (IntPtr) _i64Value
                    otherwise	
                        throw InvalidCastException{}
                end switch
            else
                var o := __Usual:ToObject(self)
                if conversionType:IsAssignableFrom(o:GetType())
                    return o
                elseif o is IConvertible
                    return ((IConvertible) o):Totype(conversionType, provider)
                else
                    throw InvalidCastException{}
                endif
            endif
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToUInt16(provider as System.IFormatProvider) as word
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToUInt32(provider as System.IFormatProvider) as dword
            return self
            
            /// <summary>This method is needed to implement the IConvertible interface.</summary>
            public method ToUInt64(provider as System.IFormatProvider) as uint64
            return self
            
            public method GetTypeCode() as System.TypeCode
            switch _usualType
                case UsualType.ARRAY	; return TypeCode.Object
                case UsualType.CodeBlock; return TypeCode.Object			
                case UsualType.Date	; return TypeCode.Object
                case UsualType.DateTime; return TypeCode.DateTime
                case UsualType.Decimal; return TypeCode.Decimal
                case UsualType.FLOAT	; return TypeCode.Object
                case UsualType.Int64	; return TypeCode.Int64
                case UsualType.Long	; return TypeCode.Int32
                case UsualType.LOGIC	; return TypeCode.Boolean
                case UsualType.OBJECT	; return TypeCode.Object
                case UsualType.PTR	; return TypeCode.Object
                case UsualType.STRING ; return TypeCode.String
                case UsualType.SYMBOL ; return TypeCode.Object
                case UsualType.Void
                otherwise				; return TypeCode.Object
            end switch
        #endregion
        
        #region Error Method
           internal method ValType() as string
            switch self:_usualType
                case UsualType.Array		; return "A"
                case UsualType.CodeBlock	; return "B"
                case UsualType.Date			; return "D"
                case UsualType.DateTime		; return "D"
                case UsualType.DECIMAL		; return "N"
                case UsualType.FLOAT		; return "N"
                case UsualType.Int64		; return "N"
                case UsualType.Long			; return "N"
                case UsualType.Logic		; return "L"
                case UsualType.PTR			; return "-"
                case UsualType.String		; return "C"
				case UsualType.Object		; return "O"
                case UsualType.Symbol		; return "#"
                case UsualType.Void			; return "U"
                otherwise
					Debug.Fail( "Unhandled data type in Usual:Valtype" )
            end switch
			return "?"                        

            static internal method ConversionError(toTypeString as string, toType as System.Type, u as Usual) as Error
				var err			:= Error{InvalidCastException{}}
				err:GenCode		:= GenCode.EG_DataType
				err:ArgTypeReq	:= toType
				err:ArgNum		:= 1
				err:FuncSym		:= "USUAL => "+toTypeString
				err:Description := VO_Sprintf(VOErrors.USUALCONVERSIONERR, TypeString(UsualType(u)), toTypeString)  
				err:Arg			:= "USUAL"
				err:Args        := <OBJECT>{u}
				return err

            static internal method ConversionError(typeNum as DWORD, toType as System.Type, u as Usual) as Error
				var err			:= Error{ InvalidCastException{} }
				err:GenCode		:= GenCode.EG_DataType
				err:ArgTypeReq	:= toType
				err:ArgNum		:= 1
				err:FuncSym		:= "USUAL => "+TypeString((DWORD) typeNum)
				err:ArgType		:= typeNum
				err:Description := VO_Sprintf(VOErrors.USUALCONVERSIONERR, TypeString(UsualType(u)), typeString(DWORD(typeNum)))  
				err:Arg			:= "USUAL"
				err:Args        := <OBJECT>{u}
				return err
            
            static internal method OverflowError(ex as OverflowException, toTypeString as string, toType as System.Type, u as Usual) as Error
				var err			 := Error{ex}
				err:GenCode		 := GenCode.EG_NUMOVERFLOW
				err:ArgTypeReq	 := toType
				err:ArgNum		 := 1
				err:FuncSym		 := "USUAL => "+toTypeString
				err:Description  := VO_Sprintf(VOErrors.USUALOVERFLOWERR, TypeString(UsualType(u)), toTypeString)  
				err:Arg			 := "USUAL"
				err:Args		 := <OBJECT>{u}
				return err
            
            static internal method BinaryError( cOperator as string, message as string, left as logic, lhs as Usual, rhs as Usual) as Error
				var err			 := Error{ArgumentException{}}
				err:GenCode		 := GenCode.EG_ARG
				err:ArgNum		 := iif (left, 1, 2)
				err:FuncSym		 := cOperator
				err:Description  := message
				err:Arg			 := IIF(left, "left operand" , "right operand")
				err:Args         := <OBJECT> {lhs, rhs}
				return err
            
            static internal method UnaryError( cOperator as string, u as Usual) as Error
				var err			 := Error{ArgumentException{}}
				err:GenCode		 := GenCode.EG_ARG
				err:ArgNum		 := 1
				err:FuncSym		 := cOperator
				err:Description  := __CavoStr(VOErrors.INVALIDARGTYPE)
				err:Arg			 := "USUAL"
				err:Args         := <OBJECT> {u}
				return err
            
            
        #endregion

		#region Special methods used by the compiler
        /// <summary>This method is used by the compiler for code that does an inexact comparison between two usuals.</summary>
		static method __InexactEquals( lhs as usual, rhs as usual ) as logic
			if lhs:IsString .and. rhs:IsString
				return __StringEquals( lhs:_stringValue, rhs:_stringValue)
			else
				return lhs:UsualEquals(rhs, "=")
			endif

        /// <summary>This method is used by the compiler for code that does an inexact comparison between a usual and a string.</summary>
		static method __InexactEquals( lhs as usual, rhs as string ) as logic
			if lhs:IsString 
				return __StringEquals( lhs:_stringValue, rhs)
			else
				throw BinaryError("=", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
			endif

        /// <summary>This method is used by the compiler for code that does an inexact comparison.</summary>
		static method __InexactNotEquals( lhs as usual, rhs as usual ) as logic
			// emulate VO behavior for "" and NIL
			// "" = NIL but also "" != NIL, NIL = "" and NIL != ""
			if lhs:IsString .and. rhs:IsNil .and. lhs:_stringValue != null .and. lhs:_stringValue:Length == 0
				return false
			elseif rhs:IsString .and. lhs:IsNil .and. rhs:_stringValue != null .and. rhs:_stringValue:Length == 0
				return false
			else
				return ! lhs:UsualEquals(rhs, "<>")
			endif
        /// <summary>This method is used by the compiler for code that does an inexact comparison.</summary>
		static method __InexactNotEquals( lhs as usual, rhs as string ) as logic
			if lhs:IsString 
				return __StringNotEquals( lhs:_stringValue, rhs)
			else
				throw BinaryError("<>", __CavoStr(VOErrors.ARGSINCOMPATIBLE), true, lhs, rhs)
			endif

		#endregion
        internal class UsualDebugView
            private _uvalue as __Usual
            public constructor (u as __Usual)
            _uvalue := u
            
            [DebuggerBrowsable(DebuggerBrowsableState.RootHidden)] ;
            public property Value as object get _uvalue:VALUE
            public property Type  as UsualType get _uvalue:_usualType
            
        end class
        */
    end structure			
    
    
    [StructLayout(LayoutKind.Explicit)];
    internal structure _UsualData
        // Fields
        [FieldOffset(0)] internal d as __VoDate
        [FieldOffset(0)] internal r8 as real8
        [FieldOffset(0)] internal i as long
        [FieldOffset(0)] internal i64 as int64
        [FieldOffset(0)] internal l as logic
        [FieldOffset(0)] internal p as System.IntPtr
        [FieldOffset(0)] internal s as symbol
        [FieldOffset(0)] internal dt as System.DateTime
        
    end structure
    
    internal enum UsualType as byte
        // These numbers must match with the types defined in the compiler
        // They also match with the USUAL types in VO (BaseType.h)
        member @@Void		:=0
        member @@Long		:=1
        member @@Date		:=2
        member @@Float		:=3
        // Note # 4 (FIXED) was defined but never used in VO
        member @@Array		:=5
        member @@Object		:=6
        member @@String		:=7
        member @@Logic		:=8
        member @@CodeBlock	:=9
        member @@Symbol		:=10
        // see below for missing values
        // The follow numbers are defined but never stored inside a USUAL in VO and Vulcan
        member @@Byte		:=11
        member @@ShortInt	:=12
        member @@Word		:=13
        member @@DWord		:=14
        member @@Real4		:=15
        member @@Real8		:=16
        member @@Psz		:=17
        member @@Ptr		:=18
        member @@Usual		:=19	// USUAL by Ref, not implemented in Vulcan
        member @@Int64		:=22
        member @@Uint64     :=23
        member @@Char		:=24    // not stored in a usual
        member @@Dynamic    :=25 
        member @@DateTime	:=26
        member @@Decimal	:=27
        member @@Memo		:=32	// Used in RDD system in VO
        member @@Invalid    :=99
    end enum
    
    [StructLayout(LayoutKind.Explicit, Pack := 1)];
    internal structure UsualFlags
        [FieldOffset(0)] export usualType as UsualType
        [FieldOffset(1)] export width as Sbyte
        [FieldOffset(2)] export decimals as Sbyte
        [FieldOffset(3)] export isByRef as logic
        
        constructor(type as UsualType)
        usualType := type
    end structure
/// <summary>
/// Determine the data type of an expression.
/// </summary>
/// <param name="x"></param>
/// <returns>
/// </returns>
function UsualType(u as __Usual) as dword
	return (dword) u:Type
    
/// <summary>
/// Access contents of an address, whether it is passed by reference or not.
/// </summary>
/// <param name="u"></param>
/// <returns>
/// </returns>
function UsualVal(u as Usual) as Usual
	return u

/// <summary>
/// Determine the data type of an expression.
/// </summary>
/// <param name="u"></param>
/// <returns>
/// </returns>
function ValType(u as Usual) as string
	return u:ValType()

    
end namespace
