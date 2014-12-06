namespace Schemas.xsd.niem.structures._2._0 {
    using Microsoft.XLANGs.BaseTypes;
    
    
    [SchemaType(SchemaTypeEnum.Document)]
    [System.SerializableAttribute()]
    [SchemaRoots(new string[] {@"Augmentation", @"Metadata"})]
    [Microsoft.XLANGs.BaseTypes.SchemaReference(@"Schemas.xsd.niem.appinfo._2._0.appinfo", typeof(Schemas.xsd.niem.appinfo._2._0.appinfo))]
    public sealed class structures : Microsoft.XLANGs.BaseTypes.SchemaBase {
        
        [System.NonSerializedAttribute()]
        private static object _rawSchema;
        
        [System.NonSerializedAttribute()]
        private const string _strSchema = @"<?xml version=""1.0"" encoding=""utf-16""?>
<xsd:schema xmlns:s=""http://niem.gov/niem/structures/2.0"" xmlns:b=""http://schemas.microsoft.com/BizTalk/2003"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" targetNamespace=""http://niem.gov/niem/structures/2.0"" version=""1"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"">
  <xsd:import schemaLocation=""Schemas.xsd.niem.appinfo._2._0.appinfo"" namespace=""http://niem.gov/niem/appinfo/2.0"" />
  <xsd:annotation>
    <xsd:documentation>The structures schema provides support for
    fundamental NIEM linking mechanisms, as well as providing base types
    for definition of NIEM-conformant types.</xsd:documentation>
  </xsd:annotation>
  <xsd:annotation>
    <xsd:documentation>The Object resource defines an identifier which acts
    as a conceptual base for objects in NIEM-conformant
    schemas.</xsd:documentation>
    <xsd:appinfo>
      <i:Resource i:name=""Object"" xmlns:i=""http://niem.gov/niem/appinfo/2.0"" />
      <references xmlns=""http://schemas.microsoft.com/BizTalk/2003"">
        <reference targetNamespace=""http://niem.gov/niem/appinfo/2.0"" />
      </references>
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:annotation>
    <xsd:documentation>The Association resource defines an identifier which
    acts as a conceptual base for association in NIEM-conformant
    schemas.</xsd:documentation>
    <xsd:appinfo>
      <i:Resource i:name=""Association"" />
    </xsd:appinfo>
  </xsd:annotation>
  <xsd:attribute name=""id"" type=""xsd:ID"">
    <xsd:annotation>
      <xsd:documentation>The id attribute is used to define XML IDs for
      NIEM objects. These IDs may be targets of reference elements,
      metadata attributes, and link metadata
      attributes.</xsd:documentation>
    </xsd:annotation>
  </xsd:attribute>
  <xsd:attribute name=""linkMetadata"" type=""xsd:IDREFS"">
    <xsd:annotation>
      <xsd:documentation>The linkMetadata attribute allows an element to
      point to metadata that affects the relationship between the context
      and the value of the object.</xsd:documentation>
    </xsd:annotation>
  </xsd:attribute>
  <xsd:attribute name=""metadata"" type=""xsd:IDREFS"">
    <xsd:annotation>
      <xsd:documentation>The attribute metadata allows an object to point
      to metadata that affects itself.</xsd:documentation>
    </xsd:annotation>
  </xsd:attribute>
  <xsd:attribute name=""ref"" type=""xsd:IDREF"">
    <xsd:annotation>
      <xsd:documentation>The ref attribute is used by reference elements in
      NIEM to refer to an object via an ID reference, rather than including
      the object itself as element content.</xsd:documentation>
    </xsd:annotation>
  </xsd:attribute>
  <xsd:attribute name=""sequenceID"" type=""xsd:integer"">
    <xsd:annotation>
      <xsd:documentation>The sequenceID attribute allows a series of
      elements to define a sequence for content that does not correspond to
      the order of element declarations within a type. This attribute may
      override the sequence of elements appearing within an
      instance.</xsd:documentation>
    </xsd:annotation>
  </xsd:attribute>
  <xsd:attributeGroup name=""SimpleObjectAttributeGroup"">
    <xsd:annotation>
      <xsd:documentation>The SimpleObjectAttributeGroup attribute group
      provides a collection of attributes which are appropriate for
      definition of object types.</xsd:documentation>
    </xsd:annotation>
    <xsd:attribute ref=""s:id"" />
    <xsd:attribute ref=""s:metadata"" />
    <xsd:attribute ref=""s:linkMetadata"" />
  </xsd:attributeGroup>
  <xsd:element abstract=""true"" name=""Augmentation"" type=""s:AugmentationType"">
    <xsd:annotation>
      <xsd:documentation>The Augmentation element provides a substitution
      group head for augmentations. The designer of a message or object may
      use this element within an object definition. This will allow the
      selection of augmentations dynamically, at run time (or at least
      schema selection time) rather than at schema authoring
      time.</xsd:documentation>
    </xsd:annotation>
  </xsd:element>
  <xsd:element abstract=""true"" name=""Metadata"" type=""s:MetadataType"">
    <xsd:annotation>
      <xsd:documentation>The Metadata element provides a substitution group
      head for metadata. Like the substitution group head for
      augmentations, this allows selection of metadata to be decided late
      in message creation, rather than at schema authoring time. This
      element may also be used to provide a single point in a container
      where all metadata for a message may be
      deposited.</xsd:documentation>
    </xsd:annotation>
  </xsd:element>
  <xsd:complexType name=""AugmentationType"" abstract=""true"">
    <xsd:annotation>
      <xsd:documentation>The AugmentationType type is a base type for all
      augmentations. An augmentation may have metadata and an ID, but may
      not have link metadata, as it does not establish a relationship
      between its value and its context. The individual element contents of
      an augmentation, however, do establish a relationship between the
      context of the augmentation and the values of the individual
      elements.</xsd:documentation>
    </xsd:annotation>
    <xsd:attribute ref=""s:id"" />
    <xsd:attribute ref=""s:metadata"" />
  </xsd:complexType>
  <xsd:complexType name=""ComplexObjectType"" abstract=""true"">
    <xsd:annotation>
      <xsd:documentation>The ComplexObjectType type provides a base class
      for object definition, association definitions, and external adapter
      type definitions. An instance of one of these types may have an ID.
      It may have metadata as it establishes the existence of an object
      (maybe a conceptual object). It may also have link metadata, as an
      element of one of these types establishes a relationship between its
      value and its context.</xsd:documentation>
    </xsd:annotation>
    <xsd:attribute ref=""s:id"" />
    <xsd:attribute ref=""s:metadata"" />
    <xsd:attribute ref=""s:linkMetadata"" />
  </xsd:complexType>
  <xsd:complexType name=""MetadataType"" abstract=""true"">
    <xsd:annotation>
      <xsd:documentation>The MetadataType type is a base class for metadata
      type definition. This type provides only an ID, as the metadata may
      be referenced. It does not itself have metadata, and does not have
      link metadata.</xsd:documentation>
    </xsd:annotation>
    <xsd:attribute ref=""s:id"" />
  </xsd:complexType>
  <xsd:complexType name=""ReferenceType"" final=""#all"">
    <xsd:annotation>
      <xsd:documentation>The ReferenceType type is the type of all
      reference elements within NIEM-conformant schemas. This type provides
      a reference attribute, to reference an object defined elsewhere. It
      includes an ID, as the link established by a reference element may
      need to be identified, and it includes link metadata, as an element
      of this type establishes a relationship between its context and the
      referenced object. It does not contain metadata, as it does not
      itself establish the existence of an object; it relies on a
      definition located elsewhere.</xsd:documentation>
    </xsd:annotation>
    <xsd:attribute ref=""s:id"" />
    <xsd:attribute ref=""s:ref"" />
    <xsd:attribute ref=""s:linkMetadata"" />
  </xsd:complexType>
</xsd:schema>";
        
        public structures() {
        }
        
        public override string XmlContent {
            get {
                return _strSchema;
            }
        }
        
        public override string[] RootNodes {
            get {
                string[] _RootElements = new string [2];
                _RootElements[0] = "Augmentation";
                _RootElements[1] = "Metadata";
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
        
        [Schema(@"http://niem.gov/niem/structures/2.0",@"Augmentation")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"Augmentation"})]
        public sealed class Augmentation : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public Augmentation() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "Augmentation";
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
        
        [Schema(@"http://niem.gov/niem/structures/2.0",@"Metadata")]
        [System.SerializableAttribute()]
        [SchemaRoots(new string[] {@"Metadata"})]
        public sealed class Metadata : Microsoft.XLANGs.BaseTypes.SchemaBase {
            
            [System.NonSerializedAttribute()]
            private static object _rawSchema;
            
            public Metadata() {
            }
            
            public override string XmlContent {
                get {
                    return _strSchema;
                }
            }
            
            public override string[] RootNodes {
                get {
                    string[] _RootElements = new string [1];
                    _RootElements[0] = "Metadata";
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
