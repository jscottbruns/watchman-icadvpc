namespace Schemas.xsd.niem.domains.emergencyManagement._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"CategoryInformation", @"CategoryStructure", @"ResourceAnticipatedIncidentAssignmentText", @"ResourceDescriptionText", @"ResourceInformation", @"ResourceKeywordValue", @"ResourceKind", @"ResourceName", @"ResourceQuantity", @"ResourceSpecialRequirementsText", @"ValueListURN", @"ValueText"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.niem_core._2._0.niem_core", typeof(Schemas.xsd.niem.niem_core._2._0.niem_core))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.proxy.xsd._2._0.xsd", typeof(Schemas.xsd.niem.proxy.xsd._2._0.xsd))]
    public sealed class emergencyManagement : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:i=""http://niem.gov/niem/appinfo/2.0"" xmlns:niem-xsd=""http://niem.gov/niem/proxy/xsd/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:em=""http://niem.gov/niem/domains/emergencyManagement/2.0"" xmlns:nc=""http://niem.gov/niem/niem-core/2.0"" targetNamespace=""http://niem.gov/niem/domains/emergencyManagement/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:import schemaLocation=""Schemas.xsd.niem.structures._2._0.structures"" namespace=""http://niem.gov/niem/structures/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.appinfo._2._0.appinfo"" namespace=""http://niem.gov/niem/appinfo/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.niem_core._2._0.niem_core"" namespace=""http://niem.gov/niem/niem-core/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.proxy.xsd._2._0.xsd"" namespace=""http://niem.gov/niem/proxy/xsd/2.0"" />
  <xsd:annotation>
    <xsd:appinfo>
      <i:ConformantIndicator xmlns:i=""http://niem.gov/niem/appinfo/2.0"">true</i:ConformantIndicator>
      <references xmlns=""http://schemas.microsoft.com/BizTalk/2003"">
        <reference targetNamespace=""http://niem.gov/niem/structures/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/appinfo/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/niem-core/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/proxy/xsd/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/usps_states/2.0"" />
      </references>
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:complexType name=""ResourceInformationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceQuantity"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceAnticipatedIncidentAssignmentText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ResourceKindType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:CategoryStructure"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:CategoryInformation"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ResourceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceKeywordValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceDescriptionText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ResourceSpecialRequirementsText"" />
          <xsd:element minOccurs=""0"" ref=""em:ResourceInformation"" />
          <xsd:element minOccurs=""0"" ref=""em:ResourceKind"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ValueType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ValueText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""em:ValueListURN"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:element name=""CategoryInformation"" nillable=""true"" type=""em:ValueType"" />
  <xsd:element name=""CategoryStructure"" nillable=""true"" type=""em:ValueType"" />
  <xsd:element name=""ResourceAnticipatedIncidentAssignmentText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ResourceDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ResourceInformation"" nillable=""true"" type=""em:ResourceInformationType"" />
  <xsd:element name=""ResourceKeywordValue"" nillable=""true"" type=""em:ValueType"" />
  <xsd:element name=""ResourceKind"" nillable=""true"" type=""em:ResourceKindType"" />
  <xsd:element name=""ResourceName"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ResourceQuantity"" nillable=""true"" type=""niem-xsd:nonNegativeInteger"" />
  <xsd:element name=""ResourceSpecialRequirementsText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ValueListURN"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ValueText"" nillable=""true"" type=""nc:TextType"" />
</xsd:schema>";
        
        public emergencyManagement() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [12];
                _RootElements[0] = "CategoryInformation";
                _RootElements[1] = "CategoryStructure";
                _RootElements[2] = "ResourceAnticipatedIncidentAssignmentText";
                _RootElements[3] = "ResourceDescriptionText";
                _RootElements[4] = "ResourceInformation";
                _RootElements[5] = "ResourceKeywordValue";
                _RootElements[6] = "ResourceKind";
                _RootElements[7] = "ResourceName";
                _RootElements[8] = "ResourceQuantity";
                _RootElements[9] = "ResourceSpecialRequirementsText";
                _RootElements[10] = "ValueListURN";
                _RootElements[11] = "ValueText";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"CategoryInformation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"CategoryInformation"})]
        public sealed class CategoryInformation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public CategoryInformation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "CategoryInformation";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"CategoryStructure")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"CategoryStructure"})]
        public sealed class CategoryStructure : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public CategoryStructure() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "CategoryStructure";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceAnticipatedIncidentAssignmentText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceAnticipatedIncidentAssignmentText"})]
        public sealed class ResourceAnticipatedIncidentAssignmentText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceAnticipatedIncidentAssignmentText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceAnticipatedIncidentAssignmentText";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceDescriptionText"})]
        public sealed class ResourceDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceInformation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceInformation"})]
        public sealed class ResourceInformation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceInformation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceInformation";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceKeywordValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceKeywordValue"})]
        public sealed class ResourceKeywordValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceKeywordValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceKeywordValue";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceKind")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceKind"})]
        public sealed class ResourceKind : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceKind() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceKind";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceName"})]
        public sealed class ResourceName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceName";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceQuantity")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceQuantity"})]
        public sealed class ResourceQuantity : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceQuantity() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceQuantity";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ResourceSpecialRequirementsText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ResourceSpecialRequirementsText"})]
        public sealed class ResourceSpecialRequirementsText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ResourceSpecialRequirementsText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ResourceSpecialRequirementsText";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ValueListURN")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ValueListURN"})]
        public sealed class ValueListURN : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ValueListURN() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ValueListURN";
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
        
        [Schema(@"http://niem.gov/niem/domains/emergencyManagement/2.0",@"ValueText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ValueText"})]
        public sealed class ValueText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ValueText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ValueText";
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
