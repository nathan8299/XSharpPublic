/* ****************************************************************************
 *
 * Copyright (c) Microsoft Corporation.
 *
 * This source code is subject to terms and conditions of the Apache License, Version 2.0. A
 * copy of the license can be found in the License.txt file at the root of this distribution. 
 * 
 * You must not remove this notice, or any other, from this software.
 *
 * ***************************************************************************/
using System;
using System.Collections;
using System.ComponentModel;

namespace Microsoft.VisualStudio.Project
{
    /// <summary>
    /// The purpose of DesignPropertyDescriptor is to allow us to customize the
    /// display name of the property in the property grid.  None of the CLR
    /// implementations of PropertyDescriptor allow you to change the DisplayName.
    /// </summary>
    public class DesignPropertyDescriptor : PropertyDescriptor
    {
        private string displayName; // Custom display name
		protected PropertyDescriptor property;	// Base property descriptor
        private Hashtable editors = new Hashtable(); // Type -> editor instance
        private TypeConverter converter;


        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override string DisplayName
        {
            get
            {
                return this.displayName;
            }
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override Type ComponentType
        {
            get
            {
                return this.property.ComponentType;
            }
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override bool IsReadOnly
        {
            get
            {
                return this.property.IsReadOnly;
            }
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override Type PropertyType
        {
            get
            {
                return this.property.PropertyType;
            }
        }


        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override object GetEditor(Type editorBaseType)
        {
            object editor = this.editors[editorBaseType];
            if(editor == null)
            {
                for(int i = 0; i < this.Attributes.Count; i++)
                {
                    EditorAttribute attr = Attributes[i] as EditorAttribute;
                    if(attr == null)
                    {
                        continue;
                    }
                    Type editorType = Type.GetType(attr.EditorBaseTypeName);
                    if(editorBaseType == editorType)
                    {
                        Type type = GetTypeFromNameProperty(attr.EditorTypeName);
                        if(type != null)
                        {
                            editor = CreateInstance(type);
                            this.editors[type] = editor; // cache it
                            break;
                        }
                    }
                }
            }
            return editor;
        }


        /// <summary>
        /// Return type converter for property
        /// </summary>
        public override TypeConverter Converter
        {
            get
            {
                if(converter == null)
                {
                    PropertyPageTypeConverterAttribute attr = (PropertyPageTypeConverterAttribute)Attributes[typeof(PropertyPageTypeConverterAttribute)];
                    if(attr != null && attr.ConverterType != null)
                    {
                        converter = (TypeConverter)CreateInstance(attr.ConverterType);
                    }

                    if(converter == null)
                    {
                        converter = TypeDescriptor.GetConverter(this.PropertyType);
                    }
                }
                return converter;
            }
        }



        /// <summary>
        /// Convert name to a Type object.
        /// </summary>
        public virtual Type GetTypeFromNameProperty(string typeName)
        {
            return Type.GetType(typeName);
        }


        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override bool CanResetValue(object component)
        {
            bool result = this.property.CanResetValue(component);
            return result;
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override object GetValue(object component)
        {
            object value = this.property.GetValue(component);
            return value;
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override void ResetValue(object component)
        {
            this.property.ResetValue(component);
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override void SetValue(object component, object value)
        {
            this.property.SetValue(component, value);
        }

        /// <summary>
        /// Delegates to base.
        /// </summary>
        public override bool ShouldSerializeValue(object component)
        {
            //bool result = this.property.ShouldSerializeValue(component);
            //return result;
            return false;
        }

        /// <summary>
        /// Constructor.  Copy the base property descriptor and also hold a pointer
        /// to it for calling its overridden abstract methods.
        /// </summary>
        public DesignPropertyDescriptor(PropertyDescriptor prop)
            : base(prop)
        {
            if (prop == null)
            {
                throw new ArgumentNullException("prop");
            }

            this.property = prop;

            DisplayNameAttribute attr = prop.Attributes[typeof(DisplayNameAttribute)] as DisplayNameAttribute;

            if(attr != null)
            {
                this.displayName = attr.DisplayName;
            }
            else
            {
                this.displayName = prop.Name;
            }
        }
    }
}
