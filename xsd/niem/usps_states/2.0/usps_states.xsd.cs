namespace Schemas.xsd.niem.usps_states._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    public sealed class usps_states : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:usps=""http://niem.gov/niem/usps_states/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" targetNamespace=""http://niem.gov/niem/usps_states/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:import schemaLocation=""Schemas.xsd.niem.structures._2._0.structures"" namespace=""http://niem.gov/niem/structures/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.appinfo._2._0.appinfo"" namespace=""http://niem.gov/niem/appinfo/2.0"" />
  <xsd:annotation>
    <xsd:appinfo>
      <i:ConformantIndicator xmlns:i=""http://niem.gov/niem/appinfo/2.0"">true</i:ConformantIndicator>
      <references xmlns=""http://schemas.microsoft.com/BizTalk/2003"">
        <reference targetNamespace=""http://niem.gov/niem/structures/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/appinfo/2.0"" />
      </references>
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:simpleType name=""USStateCodeSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:token"" />
  </xsd:simpleType>
  <xsd:complexType name=""USStateCodeType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""usps:USStateCodeSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
</xsd:schema>";
        
        public usps_states() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [0];
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
