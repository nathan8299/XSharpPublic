﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Collections.Immutable;
using System.Collections.Concurrent;
using LanguageService.SyntaxTree;
using LanguageService.CodeAnalysis;

namespace XSharpModel
{
    [DebuggerDisplay("{FullPath,nq}")]
    public class XFile
    {
        private List<string> _usings;
        private List<string> _usingStatics;
        private string filePath;
        private ConcurrentDictionary<string, XType> _typeList;
        
        private XType _globalType;
        // 
        private object _lock;
        private bool _parsed;
        private DateTime _lastWritten;
        private bool _hasLocals;
        private XFileType _type;

        public XFile(string fullPath)
        {
            // TODO: Change to support Case Sensitive types
            _usings = new List<string>();
            _usingStatics = new List<string>();
            this.filePath = fullPath;
            _type = XFileTypeHelpers.GetFileType(fullPath);
            //
            InitTypeList();
            //
            _parsed = !HasCode;
            _lock = new object();
            _lastWritten = DateTime.MinValue;
            //_hashCode = 0;

        }


        public void GetLocals(string currentBuffer)
        {
            using (var xsWalker = new SourceWalker(this, currentBuffer))
            {
                var xTree = xsWalker.Parse();
                xsWalker.BuildModel(xTree, true);
            }
        }


        /// <summary>
        /// Reset the TypeList associated with the File, reCreating the GlobalType
        /// </summary>
        public void InitTypeList()
        {
            if (HasCode)
            {
                this._typeList = new ConcurrentDictionary<string, XType>(StringComparer.InvariantCultureIgnoreCase);
                this._globalType = XType.CreateGlobalType(this);
                this._typeList.TryAdd(_globalType.Name, _globalType);
                _usings = new List<string>();
                _usingStatics = new List<string>();
            }

        }
        private XProject project;
        public XProject Project {

            get
            {
                if (project == null)
                {
                    project = XSolution.OrphanedFilesProject;
                    project.AddFile(this.filePath);
                }
                return project;
            }

            set
            {
                project = value;
            }
        }

        public string Name
        {
            get
            {
                return System.IO.Path.GetFileNameWithoutExtension(this.filePath);
            }
        }

        public XType GlobalType => _globalType;
        public string XamlCodeBehindFile
        {
            get
            {
                var _prjNode = Project?.ProjectNode;
                string path = System.IO.Path.Combine(_prjNode.IntermediateOutputPath, System.IO.Path.GetFileName(this.FullPath));
                path = System.IO.Path.ChangeExtension(path, ".g.prg");
                return path;
            }
        }

        bool _hasParseErrors = false;
        public bool HasParseErrors
        {
            get
            {
                return _hasParseErrors;
            }
            internal set
            {
                _hasParseErrors = value;
            }
        }
        public string FullPath
        {
            get
            {
                return filePath;
            }

            set
            {
                filePath = value;
            }
        }

        public string SourcePath
        {
            get
            {
                if (IsXaml)
                    return XamlCodeBehindFile;
                else
                    return FullPath;
            }
        }

        public ImmutableList<string> Usings
        {
            get
            {
                if (!HasCode)
                    return null;
                System.Diagnostics.Trace.WriteLine("-->> XFile.Usings");
                ImmutableList<string> ret;
                lock (_lock)
                {
                    ret = _usings.ToImmutableList();
                }
                System.Diagnostics.Trace.WriteLine("<<-- XFile.Usings");
                return ret;
            }

        }
        public ImmutableList<string> AllUsingStatics
        {
            get
            {
                if (!HasCode)
                    return null;
                System.Diagnostics.Trace.WriteLine("-->> XFile.AllUsingStatics");
                List<string> statics = new List<string>();
                lock (_lock)
                {
                    statics.AddRange(_usingStatics);
                    if (this.Project != null && this.Project.ProjectNode != null && this.Project.ProjectNode.ParseOptions.IsDialectVO)
                    {
                        foreach (var asm in this.Project.AssemblyReferences)
                        {
                            var globalclass = asm.GlobalClassName;
                            if (!string.IsNullOrEmpty(globalclass))
                            {
                                statics.AddUnique(globalclass);
                            }
                        }
                    }
                }
                System.Diagnostics.Trace.WriteLine("<<-- XFile.AllUsingStatics");
                return statics.ToImmutableList();
            }

        }


        public void SetTypes(IDictionary<string, XType> types, IList<string> usings, IList<string> staticusings, bool hasLocals)
        {
            if (!HasCode)
                return;
            System.Diagnostics.Trace.WriteLine("-->> XFile.SetTypes() "+System.IO.Path.GetFileName(SourcePath));
            lock (this)
            {
                _typeList.Clear();
                _usings.Clear();
                _usingStatics.Clear();
                _hasLocals = hasLocals;
                foreach (var type in types)
                {
                    bool ok = _typeList.TryAdd(type.Key, type.Value);
                    if (XType.IsGlobalType(type.Value))
                    {
                        _globalType = type.Value;
                    }
                }
                _usings.AddRange(usings);
                _usings.AddRange(staticusings);
            }
            System.Diagnostics.Trace.WriteLine("<<-- XFile.SetTypes() " + System.IO.Path.GetFileName(SourcePath) + " " +_typeList.Count.ToString());
            return;
        }

        public IImmutableDictionary<string, XType> TypeList
        {
            get
            {
                if (!HasCode)
                    return null;
                lock (_lock)
                {
                    return _typeList.ToImmutableDictionary(StringComparer.OrdinalIgnoreCase);
                }
            }

        }
        public DateTime LastWritten
        {
            get { return _lastWritten; }
            set
            {
                lock (_lock)
                {
                    _lastWritten = value;
                }

            }
        }


        /// <summary>
        /// Flag indicating if File has been parsed at least once
        /// </summary>
        public bool Parsed
        {
            get
            {
                bool retValue;
                System.Diagnostics.Trace.WriteLine("-->> XFile.Parsed");
                lock (_lock)
                {
                    retValue = _parsed;
                }
                System.Diagnostics.Trace.WriteLine("<<-- XFile.Parsed");
                return retValue;
            }

        }

        /// <summary>
        /// Block the running Thread until the file has been parsed
        /// </summary>
        public void WaitParsing()
        {
            if (!HasCode)
                return ;
            //_parsedEvent.WaitOne();
            System.Diagnostics.Trace.WriteLine("-->> XFile.WaitParsing()");
            lock (_lock)
            {
                if ( !Parsed )
                {
                    //
                    using (SourceWalker sw = new SourceWalker(this))
                    {
                        try
                        {
                            var xTree = sw.Parse();
                            sw.BuildModel(xTree, false);
                            //
                        }
                        catch (Exception e)
                        {
                            Support.Debug("XFile.WaitParsing" + e.Message);
                        }
                    }
                }
            }
            System.Diagnostics.Trace.WriteLine("<<-- XFile.WaitParsing()");
        }

        public XTypeMember FirstMember()
        {
            if (!HasCode)
                return null;
            if (TypeList == null)
                return null;
            lock (_lock)
            {
                foreach (var type in TypeList.Values)
                {
                    foreach (var member in type.Members)
                    {
                        return member;
                    }
                }
                return null;
            }
        }

        public bool IsXaml => _type == XFileType.XAML;
        public bool IsSource => _type == XFileType.SourceCode;

        public bool HasCode => IsSource || IsXaml;
        public bool HasLocals => _hasLocals;

        public XFileType XFileType => _type;

        /// <summary>
        /// Create a HashCode based on Prototype of all Members of All Types in the file
        /// </summary>
        public uint ContentHashCode
        {
            get
            {
                if (!HasCode)
                    return 0;
                if (TypeList == null)
                    return 0;
                lock (_lock)
                {
                    uint hash = 0;
                    foreach (var type in TypeList.Values)
                    {
                        foreach (var member in type.Members)
                        {
                            hash = unchecked( hash + (uint)member.Prototype.GetHashCode());
                        }
                    }
                    return hash;
                }
            }
        }

    }
}
