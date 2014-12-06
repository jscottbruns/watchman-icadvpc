namespace Schemas.xsd.niem.ansi_nist._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [Schema(@"http://niem.gov/niem/ansi-nist/2.0",@"TransactionOriginatingOrganization")]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"TransactionOriginatingOrganization"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.niem_core._2._0.niem_core", typeof(Schemas.xsd.niem.niem_core._2._0.niem_core))]
    public sealed class ansi_nist : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:ansi-nist=""http://niem.gov/niem/ansi-nist/2.0"" xmlns:nc=""http://niem.gov/niem/niem-core/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" targetNamespace=""http://niem.gov/niem/ansi-nist/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
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
  <xsd:element name=""TransactionOriginatingOrganization"" nillable=""true"" type=""nc:OrganizationType"" />
</xsd:schema>";
        
        public ansi_nist() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [1];
                _RootElements[0] = "TransactionOriginatingOrganization";
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
