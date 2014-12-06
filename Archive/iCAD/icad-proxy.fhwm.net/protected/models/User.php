<?php

/**
 * This is the model class for table "{{User}}".
 *
 * The followings are the available columns in table '{{User}}':
 * @property integer $UserID
 * @property string $Timestamp
 * @property string $License
 * @property integer $UserLock
 * @property integer $Active
 * @property string $UserName
 * @property integer $UserStatus
 * @property string $Password
 * @property string $Salt
 * @property string $FullName
 * @property string $Email
 * @property string $StartDate
 * @property string $EndDate
 * @property string $IPRestriction
 * @property string $CookieKey
 * @property integer $CookieTime
 */
class User extends CActiveRecord
{
	/**
	 * Returns the static model of the specified AR class.
	 * @return User the static model class
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
		return '{{User}}';
	}

	/**
	 * @return array validation rules for model attributes.
	 */
	public function rules()
	{
		// NOTE: you should only define rules for those attributes that
		// will receive user inputs.
		return array(
			array('Timestamp, License, UserName, Password, Salt, FullName, Email', 'required'),
			array('UserLock, Active, UserStatus, CookieTime', 'numerical', 'integerOnly'=>true),
			array('License', 'length', 'max'=>12),
			array('UserName', 'length', 'max'=>25),
			array('Password', 'length', 'max'=>128),
			array('Salt', 'length', 'max'=>128),
			array('FullName, Email', 'length', 'max'=>255),
			array('IPRestriction', 'length', 'max'=>16),
			array('CookieKey', 'length', 'max'=>220),
			array('StartDate, EndDate', 'safe'),
			// The following rule is used by search().
			// Please remove those attributes that should not be searched.
			array('UserID, Timestamp, License, UserLock, Active, UserName, UserStatus, PWDHash, FullName, Email, StartDate, EndDate, IPRestriction, CookieKey, CookieTime', 'safe', 'on'=>'search'),
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
			'UserID' => 'User',
			'Timestamp' => 'Timestamp',
			'License' => 'License',
			'UserLock' => 'User Lock',
			'Active' => 'Active',
			'UserName' => 'User Name',
			'UserStatus' => 'User Status',
			'Password' => 'Password',
			'Salt' => 'Password Salt',
			'FullName' => 'Full Name',
			'Email' => 'Email',
			'StartDate' => 'Start Date',
			'EndDate' => 'End Date',
			'IPRestriction' => 'Iprestriction',
			'CookieKey' => 'Cookie Key',
			'CookieTime' => 'Cookie Time',
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

		$criteria->compare('UserID',$this->UserID);
		$criteria->compare('Timestamp',$this->Timestamp,true);
		$criteria->compare('License',$this->License,true);
		$criteria->compare('UserLock',$this->UserLock);
		$criteria->compare('Active',$this->Active);
		$criteria->compare('UserName',$this->UserName,true);
		$criteria->compare('UserStatus',$this->UserStatus);
		$criteria->compare('Password',$this->Password,true);
		$criteria->compare('Salt',$this->Salt,true);
		$criteria->compare('FullName',$this->FullName,true);
		$criteria->compare('Email',$this->Email,true);
		$criteria->compare('StartDate',$this->StartDate,true);
		$criteria->compare('EndDate',$this->EndDate,true);
		$criteria->compare('IPRestriction',$this->IPRestriction,true);
		$criteria->compare('CookieKey',$this->CookieKey,true);
		$criteria->compare('CookieTime',$this->CookieTime);

		return new CActiveDataProvider($this, array(
			'criteria'=>$criteria,
		));
	}

	public function validatePassword($password)
	{
		return $this->hashPassword($password, $this->Salt) === $this->Password;
	}

	 public function hashPassword($password, $salt)
    {
        return md5( $salt . $password );
    }

	protected function generateSalt()
	{
	    return uniqid('', true);
	}
}