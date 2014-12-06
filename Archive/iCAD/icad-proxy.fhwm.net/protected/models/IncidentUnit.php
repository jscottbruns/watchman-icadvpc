<?php

/**
 * This is the model class for table "IncidentUnit".
 *
 * The followings are the available columns in table 'IncidentUnit':
 * @property string $UnitId
 * @property string $Timestamp
 * @property string $Unit
 * @property string $IncidentNo
 * @property integer $AlertTrans
 * @property string $Dispatch
 * @property string $Enroute
 * @property string $OnScene
 * @property string $InService
 * @property integer $Status
 * @property integer $Closed
 */
class IncidentUnit extends CActiveRecord
{
	/**
	 * Returns the static model of the specified AR class.
	 * @return IncidentUnit the static model class
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
		return 'IncidentUnit';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('UnitId, Timestamp, Unit, IncidentNo', 'required'),
			array('AlertTrans, Status, Closed', 'numerical', 'integerOnly'=>true),
			array('UnitId', 'length', 'max'=>20),
			array('Unit', 'length', 'max'=>12),
			array('IncidentNo', 'length', 'max'=>16),
			array('Dispatch, Enroute, OnScene, InService', 'safe'),
			// The following rule is used by search().
			// Please remove those attributes that should not be searched.
			array('UnitId, Timestamp, Unit, IncidentNo, AlertTrans, Dispatch, Enroute, OnScene, InService, Status, Closed', 'safe', 'on'=>'search'),
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
			'incident'	=> array(self::BELONGS_TO, 'Incident', 'IncidentNo'),
		);
	}

	/**
	 * @return array customized attribute labels (name=>label)
	 */
	public function attributeLabels()
	{
		return array(
			'UnitId' => 'Unit',
			'Timestamp' => 'Timestamp',
			'Unit' => 'Unit',
			'IncidentNo' => 'Incident No',
			'AlertTrans' => 'Alert Trans',
			'Dispatch' => 'Dispatch',
			'Enroute' => 'Enroute',
			'OnScene' => 'On Scene',
			'InService' => 'In Service',
			'Status' => 'Status',
			'Closed' => 'Closed',
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

		$criteria->compare('UnitId',$this->UnitId,true);
		$criteria->compare('Timestamp',$this->Timestamp,true);
		$criteria->compare('Unit',$this->Unit,true);
		$criteria->compare('IncidentNo',$this->IncidentNo,true);
		$criteria->compare('AlertTrans',$this->AlertTrans);
		$criteria->compare('Dispatch',$this->Dispatch,true);
		$criteria->compare('Enroute',$this->Enroute,true);
		$criteria->compare('OnScene',$this->OnScene,true);
		$criteria->compare('InService',$this->InService,true);
		$criteria->compare('Status',$this->Status);
		$criteria->compare('Closed',$this->Closed);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}
}