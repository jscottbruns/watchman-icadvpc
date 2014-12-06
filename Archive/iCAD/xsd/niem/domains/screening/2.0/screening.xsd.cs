namespace Schemas.xsd.niem.domains.screening._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"PersonNameAugmentation", @"PersonNameCategoryCode", @"TelephoneCategoryDescriptionText", @"TelephoneNumberAugmentation"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.niem_core._2._0.niem_core", typeof(Schemas.xsd.niem.niem_core._2._0.niem_core))]
    public sealed class screening : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:nc=""http://niem.gov/niem/niem-core/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" xmlns:scr=""http://niem.gov/niem/domains/screening/2.0"" targetNamespace=""http://niem.gov/niem/domains/screening/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
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
  <xsd:complexType name=""PersonNameAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:AugmentationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""scr:PersonNameCategoryCode"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name=""PersonNameCategoryCodeSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:token"" />
  </xsd:simpleType>
  <xsd:complexType name=""PersonNameCategoryCodeType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""scr:PersonNameCategoryCodeSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""TelephoneNumberAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:AugmentationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""scr:TelephoneCategoryDescriptionText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:element name=""PersonNameAugmentation"" substitutionGroup=""s:Augmentation"" type=""scr:PersonNameAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:AppliesTo i:namespace=""http://niem.gov/niem/niem-core/2.0"" i:name=""PersonNameType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""PersonNameCategoryCode"" nillable=""true"" type=""scr:PersonNameCategoryCodeType"" />
  <xsd:element name=""TelephoneCategoryDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""TelephoneNumberAugmentation"" substitutionGroup=""s:Augmentation"" type=""scr:TelephoneNumberAugmentationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:AppliesTo i:namespace=""http://niem.gov/niem/niem-core/2.0"" i:name=""TelephoneNumberType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
</xsd:schema>";
        
        public screening() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [4];
                _RootElements[0] = "PersonNameAugmentation";
                _RootElements[1] = "PersonNameCategoryCode";
                _RootElements[2] = "TelephoneCategoryDescriptionText";
                _RootElements[3] = "TelephoneNumberAugmentation";
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
        
        [Schema(@"http://niem.gov/niem/domains/screening/2.0",@"PersonNameAugmentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonNameAugmentation"})]
        public sealed class PersonNameAugmentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonNameAugmentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonNameAugmentation";
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
        
        [Schema(@"http://niem.gov/niem/domains/screening/2.0",@"PersonNameCategoryCode")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonNameCategoryCode"})]
        public sealed class PersonNameCategoryCode : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonNameCategoryCode() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonNameCategoryCode";
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
        
        [Schema(@"http://niem.gov/niem/domains/screening/2.0",@"TelephoneCategoryDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneCategoryDescriptionText"})]
        public sealed class TelephoneCategoryDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneCategoryDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneCategoryDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/domains/screening/2.0",@"TelephoneNumberAugmentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneNumberAugmentation"})]
        public sealed class TelephoneNumberAugmentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneNumberAugmentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneNumberAugmentation";
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
