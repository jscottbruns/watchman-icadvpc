<?php

/**
 * UserIdentity represents the data needed to identity a user.
 * It contains the authentication method that checks if the provided
 * data can identity the user.
 */
class UserIdentity extends CUserIdentity
{

	private $_id;
	private $_fullname;

	public function authenticate()
	{
		$username = strtolower($this->username);
		$user = User::model()->find('LOWER(UserName)=?', array($username));

		if( $user === null )
			$this->errorCode = self::ERROR_USERNAME_INVALID;
		else if ( !$user->validatePassword($this->password) )
			$this->errorCode = self::ERROR_PASSWORD_INVALID;
		else
		{
			$this->_id = $user->UserID;
			$this->_fullname = $user->FullName;
			$this->username = $user->UserName;
			$this->errorCode = self::ERROR_NONE;
		}

		return $this->errorCode == self::ERROR_NONE;
	}

	public function getId()
    {
        return $this->_id;
    }

	public function getName()
    {
        return $this->_fullname;
    }
}