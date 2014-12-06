<?php

/**
 * This is the model class for table "Incident".
 *
 * The followings are the available columns in table 'Incident':
 * @property string $IncidentNo
 * @property string $Timestamp
 * @property string $EntryTime
 * @property string $OpenTime
 * @property string $CloseTime
 * @property string $Status
 * @property string $EventNo
 * @property string $CallType
 * @property string $Nature
 * @property string $BoxArea
 * @property string $StationGrid
 * @property string $Location
 * @property string $LocationNote
 * @property string $CrossSt1
 * @property string $CrossSt2
 * @property string $Priority
 * @property string $RadioTac
 * @property string $Map
 */
class Incident extends CActiveRecord
{
	/**
	 * Returns the static model of the specified AR class.
	 * @return Incident the static model class
	 */
	public static function model($className=__CLASS__)
	{
		return parent::model($className);
	}

	/**
	 * @return string the associated database table name
	 */
	public function tableName()
	{
		return 'Incident';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('IncidentNo, Timestamp, EntryTime, OpenTime, CallType, Nature, BoxArea, Location', 'required'),
			array('IncidentNo, Status, EventNo', 'length', 'max'=>16),
			array('CallType', 'length', 'max'=>24),
			array('Nature', 'length', 'max'=>80),
			array('BoxArea, RadioTac', 'length', 'max'=>6),
			array('StationGrid, Map', 'length', 'max'=>12),
			array('Location, LocationNote, CrossSt1, CrossSt2', 'length', 'max'=>255),
			array('Priority', 'length', 'max'=>3),
			array('CloseTime', 'safe'),
			// The following rule is used by search().
			// Please remove those attributes that should not be searched.
			array('IncidentNo, Timestamp, EntryTime, OpenTime, CloseTime, Status, EventNo, CallType, Nature, BoxArea, StationGrid, Location, LocationNote, CrossSt1, CrossSt2, Priority, RadioTac, Map', 'safe', 'on'=>'search'),
		);
	}

	/**
	 * @return array relational rules.
	 */
	public function relations()
	{
		// NOTE: you may need to adjust the relation name and the related
		// class name for the relations automatically generated below.
		return array(
			'units'	=> array(self::HAS_MANY, 'IncidentUnit', 'IncidentNo'),
			'notes'	=> array(self::HAS_MANY, 'IncidentNotes', 'IncidentNo'),
		);
	}

	/**
	 * @return array customized attribute labels (name=>label)
	 */
	public function attributeLabels()
	{
		return array(
			'IncidentNo' => 'Incident No',
			'Timestamp' => 'Timestamp',
			'EntryTime' => 'Entry Time',
			'OpenTime' => 'Open Time',
			'CloseTime' => 'Close Time',
			'Status' => 'Status',
			'EventNo' => 'Event No',
			'CallType' => 'Call Type',
			'Nature' => 'Nature',
			'BoxArea' => 'Box Area',
			'StationGrid' => 'Station Grid',
			'Location' => 'Location',
			'LocationNote' => 'Location Note',
			'CrossSt1' => 'Cross St1',
			'CrossSt2' => 'Cross St2',
			'Priority' => 'Priority',
			'RadioTac' => 'Radio Tac',
			'Map' => 'Map',
		);
	}

	/**
	 * Retrieves a list of models based on the current search/filter conditions.
	 * @return CActiveDataProvider the data provider that can return the models based on the search/filter conditions.
	 */
	public function search()
	{
		// Warning: Please modify the following code to remove attributes that
		// should not be searched.

		$criteria=new CDbCriteria;

		$criteria->compare('IncidentNo',$this->IncidentNo,true);
		$criteria->compare('Timestamp',$this->Timestamp,true);
		$criteria->compare('EntryTime',$this->EntryTime,true);
		$criteria->compare('OpenTime',$this->OpenTime,true);
		$criteria->compare('CloseTime',$this->CloseTime,true);
		$criteria->compare('Status',$this->Status,true);
		$criteria->compare('EventNo',$this->EventNo,true);
		$criteria->compare('CallType',$this->CallType,true);
		$criteria->compare('Nature',$this->Nature,true);
		$criteria->compare('BoxArea',$this->BoxArea,true);
		$criteria->compare('StationGrid',$this->StationGrid,true);
		$criteria->compare('Location',$this->Location,true);
		$criteria->compare('LocationNote',$this->LocationNote,true);
		$criteria->compare('CrossSt1',$this->CrossSt1,true);
		$criteria->compare('CrossSt2',$this->CrossSt2,true);
		$criteria->compare('Priority',$this->Priority,true);
		$criteria->compare('RadioTac',$this->RadioTac,true);
		$criteria->compare('Map',$this->Map,true);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}
}