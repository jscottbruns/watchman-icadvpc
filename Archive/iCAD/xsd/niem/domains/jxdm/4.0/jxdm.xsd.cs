namespace Schemas.xsd.niem.domains.jxdm._4._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"OrganizationAugmentation", @"OrganizationORIIdentification", @"ServiceCallDispatchedDate", @"ServiceCallMechanismText", @"ServiceCallOperator"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.niem_core._2._0.niem_core", typeof(Schemas.xsd.niem.niem_core._2._0.niem_core))]
    public sealed class jxdm : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:nc=""http://niem.gov/niem/niem-core/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" xmlns:j=""http://niem.gov/niem/domains/jxdm/4.0"" targetNamespace=""http://niem.gov/niem/domains/jxdm/4.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:import schemaLocation=""Schemas.xsd.niem.structures._2._0.structures"" namespace=""http://niem.gov/niem/structures/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.appinfo._2._0.appinfo"" namespace=""http://niem.gov/niem/appinfo/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.niem_core._2._0.niem_core"" namespace=""http://niem.gov/niem/niem-core/2.0"" />
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
  <xsd:complexType name=""OrganizationAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:AugmentationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""j:OrganizationORIIdentification"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ServiceCallType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""ActivityType"" i:namespace=""http://niem.gov/niem/niem-core/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:ActivityType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""j:ServiceCallDispatchedDate"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""j:ServiceCallMechanismText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:element name=""OrganizationAugmentation"" substitutionGroup=""s:Augmentation"" type=""j:OrganizationAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:AppliesTo i:namespace=""http://niem.gov/niem/niem-core/2.0"" i:name=""OrganizationType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""OrganizationORIIdentification"" nillable=""true"" type=""nc:IdentificationType"" />
  <xsd:element name=""ServiceCallDispatchedDate"" nillable=""true"" type=""nc:DateType"" />
  <xsd:element name=""ServiceCallMechanismText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ServiceCallOperator"" nillable=""true"" type=""nc:PersonType"" />
</xsd:schema>";
        
        public jxdm() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [5];
                _RootElements[0] = "OrganizationAugmentation";
                _RootElements[1] = "OrganizationORIIdentification";
                _RootElements[2] = "ServiceCallDispatchedDate";
                _RootElements[3] = "ServiceCallMechanismText";
                _RootElements[4] = "ServiceCallOperator";
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
        
        [Schema(@"http://niem.gov/niem/domains/jxdm/4.0",@"OrganizationAugmentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationAugmentation"})]
        public sealed class OrganizationAugmentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationAugmentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationAugmentation";
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
        
        [Schema(@"http://niem.gov/niem/domains/jxdm/4.0",@"OrganizationORIIdentification")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationORIIdentification"})]
        public sealed class OrganizationORIIdentification : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationORIIdentification() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationORIIdentification";
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
        
        [Schema(@"http://niem.gov/niem/domains/jxdm/4.0",@"ServiceCallDispatchedDate")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ServiceCallDispatchedDate"})]
        public sealed class ServiceCallDispatchedDate : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ServiceCallDispatchedDate() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ServiceCallDispatchedDate";
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
        
        [Schema(@"http://niem.gov/niem/domains/jxdm/4.0",@"ServiceCallMechanismText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ServiceCallMechanismText"})]
        public sealed class ServiceCallMechanismText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ServiceCallMechanismText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ServiceCallMechanismText";
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
        
        [Schema(@"http://niem.gov/niem/domains/jxdm/4.0",@"ServiceCallOperator")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ServiceCallOperator"})]
        public sealed class ServiceCallOperator : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ServiceCallOperator() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ServiceCallOperator";
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
