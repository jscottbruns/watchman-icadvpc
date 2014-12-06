namespace Schemas.xsd.niem.niem_core._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"ActivityReference", @"ActivityDescriptionText", @"ActivityIdentification", @"ActivityItemAssociation", @"ActivityReasonText", @"ActivityReportingOrganizationAssociation", @"ActivityStatus", @"AddressBuildingText", @"AddressDeliveryPoint", @"AddressDeliveryPointID", @"AddressDeliveryPointText", @"AddressFullText", @"AddressPrivateMailboxText", @"AddressRepresentation", @"AddressSecondaryUnitText", @"CommentText", @"ContactEmailID", @"ContactEntity", @"ContactInformationReference", 
@"ContactInformationDescriptionText", @"ContactMeans", @"ContactRadioChannelText", @"ContactTelephoneNumber", @"DateRepresentation", @"DateTime", @"DistributionText", @"EntityPerson", @"EntityRepresentation", @"GeographicCoordinateLatitude", @"GeographicCoordinateLongitude", @"InternationalTelephoneNumber", @"IdentificationID", @"ItemReference", @"LatitudeDegreeValue", @"LatitudeMinuteValue", @"LatitudeSecondValue", @"LocaleNeighborhoodName", @"LocationAltitudeMeasure", @"LocationTwoDimensionalGeographicCoordinate", 
@"LocationUTMCoordinate", @"LocationAddress", @"LocationCategory", @"LocationCategoryText", @"LocationCityName", @"LocationCountry", @"LocationCountryName", @"LocationCounty", @"LocationCountyName", @"LocationDescriptionText", @"LocationLocale", @"LocationName", @"LocationPostalCode", @"LocationState", @"LocationStateUSPostalServiceCode", @"LocationStreet", @"LocationSurroundingAreaDescriptionText", @"LongitudeDegreeValue", @"LongitudeMinuteValue", @"LongitudeSecondValue", @"MeasureCategoryText", 
@"MeasurePointValue", @"MeasureUnitText", @"MeasureValue", @"NANPTelephoneNumber", @"OrganizationReference", @"OrganizationContactInformationAssociation", @"OrganizationDescriptionText", @"OrganizationIdentification", @"OrganizationLocalIdentification", @"OrganizationName", @"OrganizationOwnsItemAssociation", @"OrganizationParentAssociation", @"OrganizationPossessesItemAssociation", @"OrganizationStatus", @"OrganizationUnitReference", @"PersonFullName", @"PersonGivenName", @"PersonMiddleName", 
@"PersonName", @"PersonNamePrefixText", @"PersonNameSuffixText", @"PersonOtherIdentification", @"PersonSurName", @"SourceIDText", @"SpeedMeasure", @"SpeedUnitCode", @"StatusDate", @"StatusDescriptionText", @"StatusText", @"StreetCategoryText", @"StreetName", @"StreetNumberText", @"StreetPostdirectionalText", @"StreetPredirectionalText", @"StructuredAddress", @"SubstanceCategory", @"SubstanceCategoryText", @"TelephoneAreaCodeID", @"TelephoneCountryCodeID", @"TelephoneExchangeID", 
@"TelephoneLineID", @"TelephoneNumberRepresentation", @"TelephoneSuffixID", @"UTMDatumID"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.structures._2._0.structures", typeof(Schemas.xsd.niem.structures._2._0.structures))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.proxy.xsd._2._0.xsd", typeof(Schemas.xsd.niem.proxy.xsd._2._0.xsd))]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.usps_states._2._0.usps_states", typeof(Schemas.xsd.niem.usps_states._2._0.usps_states))]
    public sealed class niem_core : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:i=""http://niem.gov/niem/appinfo/2.0"" xmlns:niem-xsd=""http://niem.gov/niem/proxy/xsd/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:nc=""http://niem.gov/niem/niem-core/2.0"" xmlns:usps=""http://niem.gov/niem/usps_states/2.0"" targetNamespace=""http://niem.gov/niem/niem-core/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:import schemaLocation=""Schemas.xsd.niem.structures._2._0.structures"" namespace=""http://niem.gov/niem/structures/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.appinfo._2._0.appinfo"" namespace=""http://niem.gov/niem/appinfo/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.proxy.xsd._2._0.xsd"" namespace=""http://niem.gov/niem/proxy/xsd/2.0"" />
  <xsd:import schemaLocation=""Schemas.xsd.niem.usps_states._2._0.usps_states"" namespace=""http://niem.gov/niem/usps_states/2.0"" />
  <xsd:annotation>
    <xsd:appinfo>
      <i:ConformantIndicator xmlns:i=""http://niem.gov/niem/appinfo/2.0"">true</i:ConformantIndicator>
      <references xmlns=""http://schemas.microsoft.com/BizTalk/2003"">
        <reference targetNamespace=""http://niem.gov/niem/structures/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/appinfo/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/proxy/xsd/2.0"" />
        <reference targetNamespace=""http://niem.gov/niem/usps_states/2.0"" />
      </references>
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:complexType name=""ActivityItemAssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AssociationType"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:AssociationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityReference"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ItemReference"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ActivityOrganizationAssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AssociationType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:AssociationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityReference"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationReference"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ActivityType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityIdentification"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityDescriptionText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityStatus"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ActivityReasonText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""AddressType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:AddressRepresentation"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name=""AngularMinuteSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:decimal"">
      <xsd:maxExclusive value=""60"" />
      <xsd:minInclusive value=""0"" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name=""AngularMinuteType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:AngularMinuteSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:simpleType name=""AngularSecondSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:decimal"">
      <xsd:maxExclusive value=""60"" />
      <xsd:minInclusive value=""0"" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name=""AngularSecondType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:AngularSecondSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""AssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Association"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"" />
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ContactInformationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""Object"" i:namespace=""http://niem.gov/niem/structures/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ContactMeans"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ContactEntity"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""DateType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:DateRepresentation"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""DocumentType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"" />
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""EntityType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:EntityRepresentation"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""IdentificationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:IdentificationID"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""InternationalTelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""Object"" i:namespace=""http://niem.gov/niem/structures/2.0"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneCountryCodeID"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ItemType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"" />
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""LatitudeCoordinateType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LatitudeDegreeValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LatitudeMinuteValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LatitudeSecondValue"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name=""LatitudeDegreeSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:decimal"">
      <xsd:maxInclusive value=""90"" />
      <xsd:minInclusive value=""-90"" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name=""LatitudeDegreeType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:LatitudeDegreeSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""LengthMeasureType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""MeasureType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:MeasureType"" />
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""LocaleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocaleNeighborhoodName"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""LocationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationAddress"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationAltitudeMeasure"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationCategory"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationDescriptionText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationLocale"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationSurroundingAreaDescriptionText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationTwoDimensionalGeographicCoordinate"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationUTMCoordinate"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""LongitudeCoordinateType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LongitudeDegreeValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LongitudeMinuteValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LongitudeSecondValue"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:simpleType name=""LongitudeDegreeSimpleType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:restriction base=""xsd:decimal"">
      <xsd:minInclusive value=""-180"" />
      <xsd:maxExclusive value=""180"" />
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name=""LongitudeDegreeType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:LongitudeDegreeSimpleType"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""MeasurePointValueType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""xsd:decimal"">
        <xsd:attributeGroup ref=""s:SimpleObjectAttributeGroup"" />
      </xsd:extension>
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""MeasureType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:MeasureValue"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:MeasureUnitText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:MeasureCategoryText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""MetadataType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""MetadataType"" />
        <i:AppliesTo i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
        <i:AppliesTo i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Association"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:MetadataType"" />
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""NANPTelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneAreaCodeID"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneExchangeID"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneLineID"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneSuffixID"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""OrganizationContactInformationAssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AssociationType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:AssociationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationReference"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ContactInformationReference"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""OrganizationItemAssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AssociationType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:AssociationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationReference"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:ItemReference"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""OrganizationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationDescriptionText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationIdentification"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationLocalIdentification"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationStatus"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""OrganizationUnitAssociationType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AssociationType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:AssociationType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationReference"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:OrganizationUnitReference"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""PersonNameTextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""ProperNameTextType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:ProperNameTextType"" />
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""PersonNameType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonNamePrefixText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonGivenName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonMiddleName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonSurName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonNameSuffixText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonFullName"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""PersonType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:PersonOtherIdentification"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""ProperNameTextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""TextType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""nc:TextType"" />
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""SpeedMeasureType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""MeasureType"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""nc:MeasureType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:SpeedUnitCode"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""StatusType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StatusText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StatusDate"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StatusDescriptionText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""StreetType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StreetNumberText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StreetPredirectionalText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StreetName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StreetCategoryText"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:StreetPostdirectionalText"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""StructuredAddressType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:AddressDeliveryPoint"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationCityName"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationCounty"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationState"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationCountry"" />
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:LocationPostalCode"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""TelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element minOccurs=""0"" maxOccurs=""unbounded"" ref=""nc:TelephoneNumberRepresentation"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/proxy/xsd/2.0"" i:name=""string"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:simpleContent>
      <xsd:extension base=""niem-xsd:string"" />
    </xsd:simpleContent>
  </xsd:complexType>
  <xsd:complexType name=""TwoDimensionalGeographicCoordinateType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element ref=""nc:GeographicCoordinateLatitude"" />
          <xsd:element ref=""nc:GeographicCoordinateLongitude"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:complexType name=""UTMCoordinateType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:namespace=""http://niem.gov/niem/structures/2.0"" i:name=""Object"" />
      </xsd:appinfo>
    </xsd:annotation>
    <xsd:complexContent mixed=""false"">
      <xsd:extension base=""s:ComplexObjectType"">
        <xsd:sequence>
          <xsd:element ref=""nc:UTMDatumID"" />
        </xsd:sequence>
      </xsd:extension>
    </xsd:complexContent>
  </xsd:complexType>
  <xsd:element name=""ActivityReference"" type=""s:ReferenceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:ReferenceTarget i:name=""ActivityType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""ActivityDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ActivityIdentification"" nillable=""true"" type=""nc:IdentificationType"" />
  <xsd:element name=""ActivityItemAssociation"" nillable=""true"" type=""nc:ActivityItemAssociationType"" />
  <xsd:element name=""ActivityReasonText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ActivityReportingOrganizationAssociation"" nillable=""true"" type=""nc:ActivityOrganizationAssociationType"" />
  <xsd:element name=""ActivityStatus"" nillable=""true"" type=""nc:StatusType"" />
  <xsd:element name=""AddressBuildingText"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""AddressDeliveryPoint"" type=""xsd:anyType"" />
  <xsd:element name=""AddressDeliveryPointID"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""niem-xsd:string"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""AddressDeliveryPointText"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""AddressFullText"" nillable=""true"" substitutionGroup=""nc:AddressRepresentation"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""AddressPrivateMailboxText"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""AddressRepresentation"" type=""xsd:anyType"" />
  <xsd:element name=""AddressSecondaryUnitText"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""CommentText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ContactEmailID"" nillable=""true"" substitutionGroup=""nc:ContactMeans"" type=""niem-xsd:string"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""ContactMeans"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""ContactEntity"" nillable=""true"" type=""nc:EntityType"" />
  <xsd:element name=""ContactInformationReference"" type=""s:ReferenceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:ReferenceTarget i:name=""ContactInformationType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""ContactInformationDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element abstract=""true"" name=""ContactMeans"" type=""xsd:anyType"" />
  <xsd:element name=""ContactRadioChannelText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""ContactTelephoneNumber"" nillable=""true"" substitutionGroup=""nc:ContactMeans"" type=""nc:TelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""ContactMeans"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""DateRepresentation"" type=""xsd:anyType"" />
  <xsd:element name=""DateTime"" nillable=""true"" substitutionGroup=""nc:DateRepresentation"" type=""niem-xsd:dateTime"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""DateRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""DistributionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""EntityPerson"" nillable=""true"" substitutionGroup=""nc:EntityRepresentation"" type=""nc:PersonType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""EntityRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""EntityRepresentation"" type=""xsd:anyType"" />
  <xsd:element name=""GeographicCoordinateLatitude"" nillable=""true"" type=""nc:LatitudeCoordinateType"" />
  <xsd:element name=""GeographicCoordinateLongitude"" nillable=""true"" type=""nc:LongitudeCoordinateType"" />
  <xsd:element name=""InternationalTelephoneNumber"" nillable=""true"" substitutionGroup=""nc:TelephoneNumberRepresentation"" type=""nc:InternationalTelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""TelephoneNumberRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""IdentificationID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""ItemReference"" type=""s:ReferenceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:ReferenceTarget i:name=""ItemType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""LatitudeDegreeValue"" nillable=""true"" type=""nc:LatitudeDegreeType"" />
  <xsd:element name=""LatitudeMinuteValue"" nillable=""true"" type=""nc:AngularMinuteType"" />
  <xsd:element name=""LatitudeSecondValue"" nillable=""true"" type=""nc:AngularSecondType"" />
  <xsd:element name=""LocaleNeighborhoodName"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""LocationAltitudeMeasure"" nillable=""true"" type=""nc:LengthMeasureType"" />
  <xsd:element name=""LocationTwoDimensionalGeographicCoordinate"" nillable=""true"" type=""nc:TwoDimensionalGeographicCoordinateType"" />
  <xsd:element name=""LocationUTMCoordinate"" nillable=""true"" type=""nc:UTMCoordinateType"" />
  <xsd:element name=""LocationAddress"" nillable=""true"" type=""nc:AddressType"" />
  <xsd:element abstract=""true"" name=""LocationCategory"" type=""xsd:anyType"" />
  <xsd:element name=""LocationCategoryText"" nillable=""true"" substitutionGroup=""nc:LocationCategory"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""LocationCategory"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""LocationCityName"" nillable=""true"" type=""nc:ProperNameTextType"" />
  <xsd:element abstract=""true"" name=""LocationCountry"" type=""xsd:anyType"" />
  <xsd:element name=""LocationCountryName"" nillable=""true"" substitutionGroup=""nc:LocationCountry"" type=""nc:ProperNameTextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""LocationCountry"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""LocationCounty"" type=""xsd:anyType"" />
  <xsd:element name=""LocationCountyName"" nillable=""true"" substitutionGroup=""nc:LocationCounty"" type=""nc:ProperNameTextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""LocationCounty"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""LocationDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""LocationLocale"" nillable=""true"" type=""nc:LocaleType"" />
  <xsd:element name=""LocationName"" nillable=""true"" type=""nc:ProperNameTextType"" />
  <xsd:element name=""LocationPostalCode"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element abstract=""true"" name=""LocationState"" type=""xsd:anyType"" />
  <xsd:element name=""LocationStateUSPostalServiceCode"" nillable=""true"" substitutionGroup=""nc:LocationState"" type=""usps:USStateCodeType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""LocationState"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""LocationStreet"" nillable=""true"" substitutionGroup=""nc:AddressDeliveryPoint"" type=""nc:StreetType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressDeliveryPoint"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""LocationSurroundingAreaDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""LongitudeDegreeValue"" nillable=""true"" type=""nc:LongitudeDegreeType"" />
  <xsd:element name=""LongitudeMinuteValue"" nillable=""true"" type=""nc:AngularMinuteType"" />
  <xsd:element name=""LongitudeSecondValue"" nillable=""true"" type=""nc:AngularSecondType"" />
  <xsd:element name=""MeasureCategoryText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""MeasurePointValue"" nillable=""true"" substitutionGroup=""nc:MeasureValue"" type=""nc:MeasurePointValueType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""MeasureValue"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""MeasureUnitText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element abstract=""true"" name=""MeasureValue"" type=""xsd:anyType"" />
  <xsd:element name=""NANPTelephoneNumber"" nillable=""true"" substitutionGroup=""nc:TelephoneNumberRepresentation"" type=""nc:NANPTelephoneNumberType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""TelephoneNumberRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""OrganizationReference"" type=""s:ReferenceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:ReferenceTarget i:name=""OrganizationType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""OrganizationContactInformationAssociation"" nillable=""true"" type=""nc:OrganizationContactInformationAssociationType"" />
  <xsd:element name=""OrganizationDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""OrganizationIdentification"" nillable=""true"" type=""nc:IdentificationType"" />
  <xsd:element name=""OrganizationLocalIdentification"" nillable=""true"" type=""nc:IdentificationType"" />
  <xsd:element name=""OrganizationName"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""OrganizationOwnsItemAssociation"" nillable=""true"" type=""nc:OrganizationItemAssociationType"" />
  <xsd:element name=""OrganizationParentAssociation"" nillable=""true"" type=""nc:OrganizationUnitAssociationType"" />
  <xsd:element name=""OrganizationPossessesItemAssociation"" nillable=""true"" type=""nc:OrganizationItemAssociationType"" />
  <xsd:element name=""OrganizationStatus"" nillable=""true"" type=""nc:StatusType"" />
  <xsd:element name=""OrganizationUnitReference"" type=""s:ReferenceType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:ReferenceTarget i:name=""OrganizationType"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""PersonFullName"" nillable=""true"" type=""nc:PersonNameTextType"" />
  <xsd:element name=""PersonGivenName"" nillable=""true"" type=""nc:PersonNameTextType"" />
  <xsd:element name=""PersonMiddleName"" nillable=""true"" type=""nc:PersonNameTextType"" />
  <xsd:element name=""PersonName"" nillable=""true"" type=""nc:PersonNameType"" />
  <xsd:element name=""PersonNamePrefixText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""PersonNameSuffixText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""PersonOtherIdentification"" nillable=""true"" type=""nc:IdentificationType"" />
  <xsd:element name=""PersonSurName"" nillable=""true"" type=""nc:PersonNameTextType"" />
  <xsd:element name=""SourceIDText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""SpeedMeasure"" nillable=""true"" type=""nc:SpeedMeasureType"" />
  <xsd:element name=""SpeedUnitCode"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""StatusDate"" nillable=""true"" type=""nc:DateType"" />
  <xsd:element name=""StatusDescriptionText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StatusText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StreetCategoryText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StreetName"" nillable=""true"" type=""nc:ProperNameTextType"" />
  <xsd:element name=""StreetNumberText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StreetPostdirectionalText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StreetPredirectionalText"" nillable=""true"" type=""nc:TextType"" />
  <xsd:element name=""StructuredAddress"" nillable=""true"" substitutionGroup=""nc:AddressRepresentation"" type=""nc:StructuredAddressType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""AddressRepresentation"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""SubstanceCategory"" type=""xsd:anyType"" />
  <xsd:element name=""SubstanceCategoryText"" nillable=""true"" substitutionGroup=""nc:SubstanceCategory"" type=""nc:TextType"">
    <xsd:annotation>
      <xsd:appinfo>
        <i:Base i:name=""SubstanceCategory"" />
      </xsd:appinfo>
    </xsd:annotation>
  </xsd:element>
  <xsd:element name=""TelephoneAreaCodeID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""TelephoneCountryCodeID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""TelephoneExchangeID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""TelephoneLineID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element abstract=""true"" name=""TelephoneNumberRepresentation"" type=""xsd:anyType"" />
  <xsd:element name=""TelephoneSuffixID"" nillable=""true"" type=""niem-xsd:string"" />
  <xsd:element name=""UTMDatumID"" nillable=""true"" type=""niem-xsd:string"" />
</xsd:schema>";
        
        public niem_core() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [104];
                _RootElements[0] = "ActivityReference";
                _RootElements[1] = "ActivityDescriptionText";
                _RootElements[2] = "ActivityIdentification";
                _RootElements[3] = "ActivityItemAssociation";
                _RootElements[4] = "ActivityReasonText";
                _RootElements[5] = "ActivityReportingOrganizationAssociation";
                _RootElements[6] = "ActivityStatus";
                _RootElements[7] = "AddressBuildingText";
                _RootElements[8] = "AddressDeliveryPoint";
                _RootElements[9] = "AddressDeliveryPointID";
                _RootElements[10] = "AddressDeliveryPointText";
                _RootElements[11] = "AddressFullText";
                _RootElements[12] = "AddressPrivateMailboxText";
                _RootElements[13] = "AddressRepresentation";
                _RootElements[14] = "AddressSecondaryUnitText";
                _RootElements[15] = "CommentText";
                _RootElements[16] = "ContactEmailID";
                _RootElements[17] = "ContactEntity";
                _RootElements[18] = "ContactInformationReference";
                _RootElements[19] = "ContactInformationDescriptionText";
                _RootElements[20] = "ContactMeans";
                _RootElements[21] = "ContactRadioChannelText";
                _RootElements[22] = "ContactTelephoneNumber";
                _RootElements[23] = "DateRepresentation";
                _RootElements[24] = "DateTime";
                _RootElements[25] = "DistributionText";
                _RootElements[26] = "EntityPerson";
                _RootElements[27] = "EntityRepresentation";
                _RootElements[28] = "GeographicCoordinateLatitude";
                _RootElements[29] = "GeographicCoordinateLongitude";
                _RootElements[30] = "InternationalTelephoneNumber";
                _RootElements[31] = "IdentificationID";
                _RootElements[32] = "ItemReference";
                _RootElements[33] = "LatitudeDegreeValue";
                _RootElements[34] = "LatitudeMinuteValue";
                _RootElements[35] = "LatitudeSecondValue";
                _RootElements[36] = "LocaleNeighborhoodName";
                _RootElements[37] = "LocationAltitudeMeasure";
                _RootElements[38] = "LocationTwoDimensionalGeographicCoordinate";
                _RootElements[39] = "LocationUTMCoordinate";
                _RootElements[40] = "LocationAddress";
                _RootElements[41] = "LocationCategory";
                _RootElements[42] = "LocationCategoryText";
                _RootElements[43] = "LocationCityName";
                _RootElements[44] = "LocationCountry";
                _RootElements[45] = "LocationCountryName";
                _RootElements[46] = "LocationCounty";
                _RootElements[47] = "LocationCountyName";
                _RootElements[48] = "LocationDescriptionText";
                _RootElements[49] = "LocationLocale";
                _RootElements[50] = "LocationName";
                _RootElements[51] = "LocationPostalCode";
                _RootElements[52] = "LocationState";
                _RootElements[53] = "LocationStateUSPostalServiceCode";
                _RootElements[54] = "LocationStreet";
                _RootElements[55] = "LocationSurroundingAreaDescriptionText";
                _RootElements[56] = "LongitudeDegreeValue";
                _RootElements[57] = "LongitudeMinuteValue";
                _RootElements[58] = "LongitudeSecondValue";
                _RootElements[59] = "MeasureCategoryText";
                _RootElements[60] = "MeasurePointValue";
                _RootElements[61] = "MeasureUnitText";
                _RootElements[62] = "MeasureValue";
                _RootElements[63] = "NANPTelephoneNumber";
                _RootElements[64] = "OrganizationReference";
                _RootElements[65] = "OrganizationContactInformationAssociation";
                _RootElements[66] = "OrganizationDescriptionText";
                _RootElements[67] = "OrganizationIdentification";
                _RootElements[68] = "OrganizationLocalIdentification";
                _RootElements[69] = "OrganizationName";
                _RootElements[70] = "OrganizationOwnsItemAssociation";
                _RootElements[71] = "OrganizationParentAssociation";
                _RootElements[72] = "OrganizationPossessesItemAssociation";
                _RootElements[73] = "OrganizationStatus";
                _RootElements[74] = "OrganizationUnitReference";
                _RootElements[75] = "PersonFullName";
                _RootElements[76] = "PersonGivenName";
                _RootElements[77] = "PersonMiddleName";
                _RootElements[78] = "PersonName";
                _RootElements[79] = "PersonNamePrefixText";
                _RootElements[80] = "PersonNameSuffixText";
                _RootElements[81] = "PersonOtherIdentification";
                _RootElements[82] = "PersonSurName";
                _RootElements[83] = "SourceIDText";
                _RootElements[84] = "SpeedMeasure";
                _RootElements[85] = "SpeedUnitCode";
                _RootElements[86] = "StatusDate";
                _RootElements[87] = "StatusDescriptionText";
                _RootElements[88] = "StatusText";
                _RootElements[89] = "StreetCategoryText";
                _RootElements[90] = "StreetName";
                _RootElements[91] = "StreetNumberText";
                _RootElements[92] = "StreetPostdirectionalText";
                _RootElements[93] = "StreetPredirectionalText";
                _RootElements[94] = "StructuredAddress";
                _RootElements[95] = "SubstanceCategory";
                _RootElements[96] = "SubstanceCategoryText";
                _RootElements[97] = "TelephoneAreaCodeID";
                _RootElements[98] = "TelephoneCountryCodeID";
                _RootElements[99] = "TelephoneExchangeID";
                _RootElements[100] = "TelephoneLineID";
                _RootElements[101] = "TelephoneNumberRepresentation";
                _RootElements[102] = "TelephoneSuffixID";
                _RootElements[103] = "UTMDatumID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityReference")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityReference"})]
        public sealed class ActivityReference : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityReference() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityReference";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityDescriptionText"})]
        public sealed class ActivityDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityIdentification")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityIdentification"})]
        public sealed class ActivityIdentification : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityIdentification() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityIdentification";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityItemAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityItemAssociation"})]
        public sealed class ActivityItemAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityItemAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityItemAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityReasonText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityReasonText"})]
        public sealed class ActivityReasonText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityReasonText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityReasonText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityReportingOrganizationAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityReportingOrganizationAssociation"})]
        public sealed class ActivityReportingOrganizationAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityReportingOrganizationAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityReportingOrganizationAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ActivityStatus")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ActivityStatus"})]
        public sealed class ActivityStatus : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ActivityStatus() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ActivityStatus";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressBuildingText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressBuildingText"})]
        public sealed class AddressBuildingText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressBuildingText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressBuildingText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressDeliveryPoint")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressDeliveryPoint"})]
        public sealed class AddressDeliveryPoint : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressDeliveryPoint() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressDeliveryPoint";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressDeliveryPointID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressDeliveryPointID"})]
        public sealed class AddressDeliveryPointID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressDeliveryPointID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressDeliveryPointID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressDeliveryPointText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressDeliveryPointText"})]
        public sealed class AddressDeliveryPointText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressDeliveryPointText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressDeliveryPointText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressFullText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressFullText"})]
        public sealed class AddressFullText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressFullText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressFullText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressPrivateMailboxText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressPrivateMailboxText"})]
        public sealed class AddressPrivateMailboxText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressPrivateMailboxText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressPrivateMailboxText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressRepresentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressRepresentation"})]
        public sealed class AddressRepresentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressRepresentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressRepresentation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"AddressSecondaryUnitText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"AddressSecondaryUnitText"})]
        public sealed class AddressSecondaryUnitText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public AddressSecondaryUnitText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "AddressSecondaryUnitText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"CommentText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"CommentText"})]
        public sealed class CommentText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public CommentText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "CommentText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactEmailID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactEmailID"})]
        public sealed class ContactEmailID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactEmailID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactEmailID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactEntity")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactEntity"})]
        public sealed class ContactEntity : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactEntity() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactEntity";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactInformationReference")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactInformationReference"})]
        public sealed class ContactInformationReference : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactInformationReference() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactInformationReference";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactInformationDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactInformationDescriptionText"})]
        public sealed class ContactInformationDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactInformationDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactInformationDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactMeans")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactMeans"})]
        public sealed class ContactMeans : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactMeans() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactMeans";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactRadioChannelText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactRadioChannelText"})]
        public sealed class ContactRadioChannelText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactRadioChannelText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactRadioChannelText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ContactTelephoneNumber")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ContactTelephoneNumber"})]
        public sealed class ContactTelephoneNumber : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ContactTelephoneNumber() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ContactTelephoneNumber";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"DateRepresentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"DateRepresentation"})]
        public sealed class DateRepresentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public DateRepresentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "DateRepresentation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"DateTime")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"DateTime"})]
        public sealed class DateTime : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public DateTime() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "DateTime";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"DistributionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"DistributionText"})]
        public sealed class DistributionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public DistributionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "DistributionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"EntityPerson")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"EntityPerson"})]
        public sealed class EntityPerson : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public EntityPerson() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "EntityPerson";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"EntityRepresentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"EntityRepresentation"})]
        public sealed class EntityRepresentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public EntityRepresentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "EntityRepresentation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"GeographicCoordinateLatitude")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"GeographicCoordinateLatitude"})]
        public sealed class GeographicCoordinateLatitude : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public GeographicCoordinateLatitude() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "GeographicCoordinateLatitude";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"GeographicCoordinateLongitude")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"GeographicCoordinateLongitude"})]
        public sealed class GeographicCoordinateLongitude : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public GeographicCoordinateLongitude() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "GeographicCoordinateLongitude";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"InternationalTelephoneNumber")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"InternationalTelephoneNumber"})]
        public sealed class InternationalTelephoneNumber : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public InternationalTelephoneNumber() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "InternationalTelephoneNumber";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"IdentificationID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"IdentificationID"})]
        public sealed class IdentificationID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public IdentificationID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "IdentificationID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"ItemReference")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"ItemReference"})]
        public sealed class ItemReference : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public ItemReference() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "ItemReference";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LatitudeDegreeValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LatitudeDegreeValue"})]
        public sealed class LatitudeDegreeValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LatitudeDegreeValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LatitudeDegreeValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LatitudeMinuteValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LatitudeMinuteValue"})]
        public sealed class LatitudeMinuteValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LatitudeMinuteValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LatitudeMinuteValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LatitudeSecondValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LatitudeSecondValue"})]
        public sealed class LatitudeSecondValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LatitudeSecondValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LatitudeSecondValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocaleNeighborhoodName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocaleNeighborhoodName"})]
        public sealed class LocaleNeighborhoodName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocaleNeighborhoodName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocaleNeighborhoodName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationAltitudeMeasure")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationAltitudeMeasure"})]
        public sealed class LocationAltitudeMeasure : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationAltitudeMeasure() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationAltitudeMeasure";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationTwoDimensionalGeographicCoordinate")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationTwoDimensionalGeographicCoordinate"})]
        public sealed class LocationTwoDimensionalGeographicCoordinate : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationTwoDimensionalGeographicCoordinate() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationTwoDimensionalGeographicCoordinate";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationUTMCoordinate")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationUTMCoordinate"})]
        public sealed class LocationUTMCoordinate : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationUTMCoordinate() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationUTMCoordinate";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationAddress")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationAddress"})]
        public sealed class LocationAddress : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationAddress() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationAddress";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCategory")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCategory"})]
        public sealed class LocationCategory : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCategory() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCategory";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCategoryText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCategoryText"})]
        public sealed class LocationCategoryText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCategoryText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCategoryText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCityName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCityName"})]
        public sealed class LocationCityName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCityName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCityName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCountry")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCountry"})]
        public sealed class LocationCountry : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCountry() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCountry";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCountryName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCountryName"})]
        public sealed class LocationCountryName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCountryName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCountryName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCounty")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCounty"})]
        public sealed class LocationCounty : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCounty() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCounty";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationCountyName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationCountyName"})]
        public sealed class LocationCountyName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationCountyName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationCountyName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationDescriptionText"})]
        public sealed class LocationDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationLocale")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationLocale"})]
        public sealed class LocationLocale : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationLocale() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationLocale";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationName"})]
        public sealed class LocationName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationPostalCode")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationPostalCode"})]
        public sealed class LocationPostalCode : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationPostalCode() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationPostalCode";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationState")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationState"})]
        public sealed class LocationState : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationState() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationState";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationStateUSPostalServiceCode")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationStateUSPostalServiceCode"})]
        public sealed class LocationStateUSPostalServiceCode : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationStateUSPostalServiceCode() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationStateUSPostalServiceCode";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationStreet")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationStreet"})]
        public sealed class LocationStreet : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationStreet() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationStreet";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LocationSurroundingAreaDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LocationSurroundingAreaDescriptionText"})]
        public sealed class LocationSurroundingAreaDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LocationSurroundingAreaDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LocationSurroundingAreaDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LongitudeDegreeValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LongitudeDegreeValue"})]
        public sealed class LongitudeDegreeValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LongitudeDegreeValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LongitudeDegreeValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LongitudeMinuteValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LongitudeMinuteValue"})]
        public sealed class LongitudeMinuteValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LongitudeMinuteValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LongitudeMinuteValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"LongitudeSecondValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"LongitudeSecondValue"})]
        public sealed class LongitudeSecondValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public LongitudeSecondValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "LongitudeSecondValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"MeasureCategoryText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"MeasureCategoryText"})]
        public sealed class MeasureCategoryText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public MeasureCategoryText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "MeasureCategoryText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"MeasurePointValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"MeasurePointValue"})]
        public sealed class MeasurePointValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public MeasurePointValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "MeasurePointValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"MeasureUnitText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"MeasureUnitText"})]
        public sealed class MeasureUnitText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public MeasureUnitText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "MeasureUnitText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"MeasureValue")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"MeasureValue"})]
        public sealed class MeasureValue : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public MeasureValue() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "MeasureValue";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"NANPTelephoneNumber")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"NANPTelephoneNumber"})]
        public sealed class NANPTelephoneNumber : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public NANPTelephoneNumber() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "NANPTelephoneNumber";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationReference")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationReference"})]
        public sealed class OrganizationReference : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationReference() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationReference";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationContactInformationAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationContactInformationAssociation"})]
        public sealed class OrganizationContactInformationAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationContactInformationAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationContactInformationAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationDescriptionText"})]
        public sealed class OrganizationDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationIdentification")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationIdentification"})]
        public sealed class OrganizationIdentification : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationIdentification() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationIdentification";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationLocalIdentification")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationLocalIdentification"})]
        public sealed class OrganizationLocalIdentification : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationLocalIdentification() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationLocalIdentification";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationName"})]
        public sealed class OrganizationName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationOwnsItemAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationOwnsItemAssociation"})]
        public sealed class OrganizationOwnsItemAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationOwnsItemAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationOwnsItemAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationParentAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationParentAssociation"})]
        public sealed class OrganizationParentAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationParentAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationParentAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationPossessesItemAssociation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationPossessesItemAssociation"})]
        public sealed class OrganizationPossessesItemAssociation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationPossessesItemAssociation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationPossessesItemAssociation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationStatus")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationStatus"})]
        public sealed class OrganizationStatus : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationStatus() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationStatus";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"OrganizationUnitReference")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"OrganizationUnitReference"})]
        public sealed class OrganizationUnitReference : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public OrganizationUnitReference() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "OrganizationUnitReference";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonFullName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonFullName"})]
        public sealed class PersonFullName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonFullName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonFullName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonGivenName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonGivenName"})]
        public sealed class PersonGivenName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonGivenName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonGivenName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonMiddleName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonMiddleName"})]
        public sealed class PersonMiddleName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonMiddleName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonMiddleName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonName"})]
        public sealed class PersonName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonNamePrefixText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonNamePrefixText"})]
        public sealed class PersonNamePrefixText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonNamePrefixText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonNamePrefixText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonNameSuffixText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonNameSuffixText"})]
        public sealed class PersonNameSuffixText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonNameSuffixText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonNameSuffixText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonOtherIdentification")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonOtherIdentification"})]
        public sealed class PersonOtherIdentification : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonOtherIdentification() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonOtherIdentification";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"PersonSurName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"PersonSurName"})]
        public sealed class PersonSurName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public PersonSurName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "PersonSurName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"SourceIDText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"SourceIDText"})]
        public sealed class SourceIDText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public SourceIDText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "SourceIDText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"SpeedMeasure")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"SpeedMeasure"})]
        public sealed class SpeedMeasure : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public SpeedMeasure() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "SpeedMeasure";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"SpeedUnitCode")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"SpeedUnitCode"})]
        public sealed class SpeedUnitCode : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public SpeedUnitCode() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "SpeedUnitCode";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StatusDate")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StatusDate"})]
        public sealed class StatusDate : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StatusDate() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StatusDate";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StatusDescriptionText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StatusDescriptionText"})]
        public sealed class StatusDescriptionText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StatusDescriptionText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StatusDescriptionText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StatusText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StatusText"})]
        public sealed class StatusText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StatusText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StatusText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StreetCategoryText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StreetCategoryText"})]
        public sealed class StreetCategoryText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StreetCategoryText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StreetCategoryText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StreetName")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StreetName"})]
        public sealed class StreetName : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StreetName() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StreetName";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StreetNumberText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StreetNumberText"})]
        public sealed class StreetNumberText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StreetNumberText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StreetNumberText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StreetPostdirectionalText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StreetPostdirectionalText"})]
        public sealed class StreetPostdirectionalText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StreetPostdirectionalText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StreetPostdirectionalText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StreetPredirectionalText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StreetPredirectionalText"})]
        public sealed class StreetPredirectionalText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StreetPredirectionalText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StreetPredirectionalText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"StructuredAddress")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"StructuredAddress"})]
        public sealed class StructuredAddress : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public StructuredAddress() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "StructuredAddress";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"SubstanceCategory")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"SubstanceCategory"})]
        public sealed class SubstanceCategory : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public SubstanceCategory() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "SubstanceCategory";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"SubstanceCategoryText")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"SubstanceCategoryText"})]
        public sealed class SubstanceCategoryText : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public SubstanceCategoryText() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "SubstanceCategoryText";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneAreaCodeID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneAreaCodeID"})]
        public sealed class TelephoneAreaCodeID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneAreaCodeID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneAreaCodeID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneCountryCodeID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneCountryCodeID"})]
        public sealed class TelephoneCountryCodeID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneCountryCodeID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneCountryCodeID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneExchangeID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneExchangeID"})]
        public sealed class TelephoneExchangeID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneExchangeID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneExchangeID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneLineID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneLineID"})]
        public sealed class TelephoneLineID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneLineID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneLineID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneNumberRepresentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneNumberRepresentation"})]
        public sealed class TelephoneNumberRepresentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneNumberRepresentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneNumberRepresentation";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"TelephoneSuffixID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"TelephoneSuffixID"})]
        public sealed class TelephoneSuffixID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public TelephoneSuffixID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "TelephoneSuffixID";
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
        
        [Schema(@"http://niem.gov/niem/niem-core/2.0",@"UTMDatumID")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"UTMDatumID"})]
        public sealed class UTMDatumID : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public UTMDatumID() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "UTMDatumID";
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
