<?php

/**
 * This is the model class for table "IncidentNotes".
 *
 * The followings are the available columns in table 'IncidentNotes':
 * @property string $NoteId
 * @property string $Timestamp
 * @property string $IncidentNo
 * @property string $NoteTime
 * @property string $Note
 */
class IncidentNotes extends CActiveRecord
{
	/**
	 * Returns the static model of the specified AR class.
	 * @return IncidentNotes the static model class
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
		return 'IncidentNotes';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('NoteId, Timestamp, IncidentNo, NoteTime, Note', 'required'),
			array('NoteId', 'length', 'max'=>20),
			array('IncidentNo', 'length', 'max'=>16),
			array('Note', 'length', 'max'=>255),
			// The following rule is used by search().
			// Please remove those attributes that should not be searched.
			array('NoteId, Timestamp, IncidentNo, NoteTime, Note', 'safe', 'on'=>'search'),
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
			'NoteId' => 'Note',
			'Timestamp' => 'Timestamp',
			'IncidentNo' => 'Incident No',
			'NoteTime' => 'Note Time',
			'Note' => 'Note',
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

		$criteria->compare('NoteId',$this->NoteId,true);
		$criteria->compare('Timestamp',$this->Timestamp,true);
		$criteria->compare('IncidentNo',$this->IncidentNo,true);
		$criteria->compare('NoteTime',$this->NoteTime,true);
		$criteria->compare('Note',$this->Note,true);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}
}