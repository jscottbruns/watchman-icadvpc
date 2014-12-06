namespace Schemas.xsd.niem.appinfo._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"Resource", @"Deprecated", @"Base", @"ReferenceTarget", @"AppliesTo", @"ConformantIndicator", @"ExternalAdapterTypeIndicator"})]
    public sealed class appinfo : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" attributeFormDefault=""qualified"" targetNamespace=""http://niem.gov/niem/appinfo/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:annotation>
    <xsd:documentation>The appinfo schema provides support for high level
    data model concepts and additional syntax to support the NIEM
    conceptual model and validation of NIEM-conformant
    instances.</xsd:documentation>
  </xsd:annotation>
  <xsd:element name=""Resource"">
    <xsd:annotation>
      <xsd:documentation>The Resource element provides a method for
      application information to define a name within a schema, without the
      name being bound to a schema component. This is used by the
      structures schema to define names for structures:Object and
      structures:Association.</xsd:documentation>
    </xsd:annotation>
    <xsd:complexType>
      <xsd:attribute name=""name"" type=""xsd:NCName"" use=""required"" />
    </xsd:complexType>
  </xsd:element>
  <xsd:element name=""Deprecated"">
    <xsd:annotation>
      <xsd:documentation>The Deprecated element provides a method for
      identifying components as being deprecated. A deprecated component is
      one which is provided, but whose use is not
      recommended.</xsd:documentation>
    </xsd:annotation>
    <xsd:complexType>
      <xsd:attribute name=""value"" use=""required"">
        <xsd:simpleType>
          <xsd:restriction base=""xsd:boolean"">
            <xsd:pattern value=""true"" />
          </xsd:restriction>
        </xsd:simpleType>
      </xsd:attribute>
    </xsd:complexType>
  </xsd:element>
  <xsd:element name=""Base"">
    <xsd:annotation>
      <xsd:documentation>The Base element provides a mechanism for
      indicating base types and base elements in schema, for the cases in
      which XML Schema mechanisms are insufficient. For example, it is used
      to indicate Object or Association bases.</xsd:documentation>
    </xsd:annotation>
    <xsd:complexType>
      <xsd:attribute name=""name"" type=""xsd:NCName"" use=""required"" />
      <xsd:attribute name=""namespace"" type=""xsd:anyURI"" use=""optional"" />
    </xsd:complexType>
  </xsd:element>
  <xsd:element name=""ReferenceTarget"">
    <xsd:annotation>
      <xsd:documentation>The ReferenceTarget element indicates a NIEM type
      which may be a target (that is, a destination) of a NIEM reference
      element. It may be used in combinations to indicate a set of valid
      types.</xsd:documentation>
    </xsd:annotation>
    <xsd:complexType>
      <xsd:attribute name=""name"" type=""xsd:NCName"" use=""required"" />
      <xsd:attribute name=""namespace"" type=""xsd:anyURI"" use=""optional"" />
    </xsd:complexType>
  </xsd:element>
  <xsd:element name=""AppliesTo"">
    <xsd:annotation>
      <xsd:documentation>The AppliesTo element is used in two ways. First,
      it indicates the set of types to which a metadata type may be
      applied. Second, it indicates the set of types to which an
      augmentation element may be applied.</xsd:documentation>
    </xsd:annotation>
    <xsd:complexType>
      <xsd:attribute name=""name"" type=""xsd:NCName"" use=""required"" />
      <xsd:attribute name=""namespace"" type=""xsd:anyURI"" use=""optional"" />
    </xsd:complexType>
  </xsd:element>
  <xsd:element name=""ConformantIndicator"" type=""xsd:boolean"">
    <xsd:annotation>
      <xsd:documentation>The ConformantIndicator element may be used in two
      ways. First, it is included as application information for a schema
      document element to indicate that the schema is NIEM-conformant.
      Second, it is used as application information of a namespace import
      to indicate that the schema is not
      NIEM-conformant.</xsd:documentation>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""ExternalAdapterTypeIndicator"" type=""xsd:boolean"">
    <xsd:annotation>
      <xsd:documentation>The ExternalAdapterTypeIndicator element indicates
      that a complex type is an external adapter type. Such a type is one
      that is composed of elements and attributes from non-NIEM-conformant
      schemas. The indicator allows schema processors to switch to
      alternative processing modes when processing NIEM-conformant versus
      non-NIEM-conformant content.</xsd:documentation>
    </xsd:annotation>
  </xsd:element>
</xsd:schema>";
        
        public appinfo() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [7];
                _RootElements[0] = "Resource";
                _RootElements[1] = "Deprecated";
                _RootElements[2] = "Base";
                _RootElements[3] = "ReferenceTarget";
                _RootElements[4] = "AppliesTo";
                _RootElements[5] = "ConformantIndicator";
                _RootElements[6] = "ExternalAdapterTypeIndicator";
                return _RootElements;
            }
        }
        
        protected override object RawSchema {
            get {
                return _rawSchema;
            }
            set {
                _rawSchema = value;
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"Resource")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"Resource"})]
        public sealed class Resource : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public Resource() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "Resource";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"Deprecated")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"Deprecated"})]
        public sealed class Deprecated : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public Deprecated() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "Deprecated";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"Base")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"Base"})]
        public sealed class Base : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public Base() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "Base";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"ReferenceTarget")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ReferenceTarget"})]
        public sealed class ReferenceTarget : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ReferenceTarget() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ReferenceTarget";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"AppliesTo")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AppliesTo"})]
        public sealed class AppliesTo : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AppliesTo() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AppliesTo";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"ConformantIndicator")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ConformantIndicator"})]
        public sealed class ConformantIndicator : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ConformantIndicator() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ConformantIndicator";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
        
        [Schema(@"http://niem.gov/niem/appinfo/2.0",@"ExternalAdapterTypeIndicator")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ExternalAdapterTypeIndicator"})]
        public sealed class ExternalAdapterTypeIndicator : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ExternalAdapterTypeIndicator() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ExternalAdapterTypeIndicator";
                    return _RootElements;
                }
            }
            
            protected override object RawSchema {
                get {
                    return _rawSchema;
                }
                set {
                    _rawSchema = value;
                }
            }
        }
    }
}
