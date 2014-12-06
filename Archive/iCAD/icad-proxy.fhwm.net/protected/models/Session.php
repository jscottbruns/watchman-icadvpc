<?php

/**
 * This is the model class for table "{{Session}}".
 *
 * The followings are the available columns in table '{{Session}}':
 * @property string $SessionID
 * @property string $UserHash
 * @property integer $SessionTime
 * @property integer $ReloadSession
 */
class Session extends CActiveRecord
{
	/**
	 * Returns the static model of the specified AR class.
	 * @return Session the static model class
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
		return '{{Session}}';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('SessionID, UserHash', 'required'),
			array('SessionTime, ReloadSession', 'numerical', 'integerOnly'=>true),
			array('SessionID', 'length', 'max'=>128),
			array('UserHash', 'length', 'max'=>32),
			// The following rule is used by search().
			// Please remove those attributes that should not be searched.
			array('SessionID, UserHash, SessionTime, ReloadSession', 'safe', 'on'=>'search'),
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
		);
	}

	/**
	 * @return array customized attribute labels (name=>label)
	 */
	public function attributeLabels()
	{
		return array(
			'SessionID' => 'Session',
			'UserHash' => 'User Hash',
			'SessionTime' => 'Session Time',
			'ReloadSession' => 'Reload Session',
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

		$criteria->compare('SessionID',$this->SessionID,true);
		$criteria->compare('UserHash',$this->UserHash,true);
		$criteria->compare('SessionTime',$this->SessionTime);
		$criteria->compare('ReloadSession',$this->ReloadSession);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}
}