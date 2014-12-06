<?php
require_once('login_hash.class.php');

class login_class extends AJAX_layer {

	public $err;
	public $cookie_timeout = 15; # Cookie valid for 10 days
	public $session_timeout = 60; # Timeout inactive sessions after 60 mins
    public $agent_random = 'YbQx5V'; # Random string

	public $login_hash; # Object representing the secure hash class

	private $db;

	public function __construct(DBLayer $db) {

		$this->db = $db;
		$this->form =& new form;

		$this->login_hash =& new login_hash;

		if ( isset($_SESSION['id_hash']) && isset($_SESSION[ session_name() ]) && $_SESSION[ session_name() ] == session_id() && $_SESSION['HTTP_USER_AGENT'] == md5( $this->agent_random . $_SERVER['HTTP_USER_AGENT'] . $this->agent_random ) ) {

			$result = $this->db->query("SELECT
	                            			t1.id_hash,
	                            			t1.time AS session_time
										FROM hostsync_session t1
										WHERE t1.session_id = '{$_SESSION[ session_name() ]}'");
            if ( $session_row = $this->db->fetch_assoc($result) ) {

				if ( $session_row['id_hash'] && $session_row['id_hash'] == $_SESSION['id_hash'] ) {

					if ( $_SESSION['user_status'] < 99 && isset($_SESSION['VARIABLE']['USER_TIMEOUT']) && ( ( time() - (int)$session_row['session_time'] ) / 60 > (int)$_SESSION['VARIABLE']['USER_TIMEOUT'] ) && ! $_COOKIE['remember_me'] ) {

						$_SESSION['force_login'] = $_SESSION['login_timeout'] = true;
						return false;
					}

					$this->db->query("UPDATE hostsync_session t1
									  SET t1.time = UNIX_TIMESTAMP()
									  WHERE t1.id_hash = '{$session_row['id_hash']}'");

					setcookie("session_time", time(), time() + ( ( $_SESSION['VARIABLE']['USER_TIMEOUT'] ? $_SESSION['VARIABLE']['USER_TIMEOUT'] : 60 ) * 60 ), "/", COOKIE_DOMAIN, ( $_SERVER['HTTPS'] ? 1 : 0 ) );

					unset($_SESSION['force_login']);

					return true;
				}

				$_SESSION['force_login'] = true;
            }
		}

		$_SESSION['force_login'] = true;

		return false;
	}

	function user_login($auto_login=false) {

		if ( ! $auto_login && ( ! $_POST['user_name'] || ! $_POST['password'] ) )
			return "Missing username or password : [Error 1001]";
		else {

            if ( $auto_login && $_POST['user_name'] )
                unset($auto_login);

			if ( $auto_login && $_COOKIE['user_hash'] ) {

                if ( ! trim($_COOKIE['cookie_key']) || ! trim($_COOKIE['user_hash']) ) {

                	$this->user_logout();
                	return "Your <i>Remember Me</i> session is no longer valid. Please enter your username, password and optionally check the <i>Remember Me</i> box to login and start a new session. [Error 1002]";
                }

                $sql_cond = "t1.id_hash = '" . $this->db->escape($_COOKIE['user_hash']) . "'";

			} else {

				$user_name = strtolower($_POST['user_name']);
				$password = $_POST['password'];
				$remember = $_POST['rememberme'];

	            $sql_cond = "t1.user_name = '" . $this->db->escape($user_name) . "'";
	            if ( $this->validEmail($user_name) )
	                $sql_cond = "t1.email = '" . $this->db->escape($user_name) . "'";
			}

			$redirect = $_POST['r'];

			if ( ! $result = $this->db->query("SELECT
			                                       t1.user_name,
    			                            	   t1.user_lock,
			                            		   t1.id_hash,
			                            		   t1.active,
			                            		   t1.full_name,
			                            		   t1.email,
			                            		   t1.pwd_hash,
			                            		   t1.start_date,
			                            		   t1.end_date,
			                            		   t1.ip_restriction,
			                            		   t1.user_status,
			                            		   t1.cookie_key,
			                            		   t1.cookie_time,
			                            		   t2.license_name,
			                            		   t2.county
										  		FROM hostsync_client t1
												LEFT JOIN license t2 ON t2.license_no = t1.license
										  		WHERE $sql_cond
										  		GROUP BY t1.id_hash")
            ) {

            	$this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);
                return "A database error was encountered when trying to validate your login information.
                <br />
                [Error 1000-{$this->db->db_errno}]";
            }

			if ( $row = $this->db->fetch_assoc($result) ) {

				if ( $auto_login ) {

					$cookie_key = $row['cookie_key'];
					$cookie_time = (int)$row['cookie_time'];

					if ( ( time() - $cookie_time ) > ( 86400 * (int)$this->cookie_timeout ) ) {

						$this->user_logout();
						return "<i>Remember Me</i> sessions remain active for a maximum of {$this->cookie_timeout} days. Your session has exceeded this timeframe and has since expired. To log in please enter your username and password below. If you'd like to renew your persistent session please make sure you've checked the <i>Remember Me</i> box. [Error 1003]";
					}

					if ( empty($cookie_key) || $_COOKIE['cookie_key'] != sha1($cookie_key) ) {

    					$this->user_logout();
    					return "The <i>Remember Me</i> session data used to maintain a persistent session is no longer valid and cannot be used to log you in at this time. To log in and create a new session please enter your username and password below. If you'd like to revalidate your <i>Remember Me</i> session please check the <i>Remember Me</i> box. [Error 1004]";
					}

					$user_name = $row['user_name'];

				} else {

					if ( ! $this->login_hash->check($row['pwd_hash'], $password) )
		                return "The username and password you entered cannot be matched against a valid user. Please verify that you have entered your username and cAsE sensitive password correctly. [Error 1005]";
				}

	            $user_status = (int)$row['user_status'];

				if ( ( $row['user_lock'] ) && $user_status != 99 )
					return "Sorry, user account has been disabled. Contact your system administrator. [Error 1006]";

				if ( ! $row['active'] && $user_status != 99 )
					return "Sorry, user account is not active. Contact your system administrator. [Error 1007]";

				if ( $row['ip_restriction'] && $row['ip_restriction'] != $_SERVER['REMOTE_ADDR'] )
					return "Sorry, your IP address has been restricted. Please contact your system administrator. [Error 1008]";

				if ( ( $row['start_date'] && $row['end_date'] && ( strtotime( date("Y-m-d") ) < strtotime($row['start_date']) || strtotime( date("Y-m-d") ) > strtotime($row['end_date']) ) ) || ( $row['start_date'] && ! $row['end_date'] && strtotime( date("Y-m-d") ) > strtotime($row['start_date']) ) || ( $row['end_date'] && ! $row['start_date'] && strtotime(date("Y-m-d") ) > strtotime($row['end_date']) ) )
					return "Sorry, user account is date restricted and access is not permitted at this time. [Error 1009]";

				$result = $this->db->query("SELECT t1.var_val
											FROM system_vars t1
											WHERE t1.var_name = 'USER_LOGIN'");
				if ( ! $this->db->result($result, 0, 'var_val') && $user_status != 99 )
					return "Sorry, site logins have been disabled. Please check with your system administrator. [Error 1010]";

				session_regenerate_id(true);

				if ( ! $this->user_set_tokens( array(
					'id_hash'        =>  $row['id_hash'],
					'remember'       =>  $remember,
	    			'user_status'    =>  $user_status,
	                'full_name'      =>  $row['full_name'],
	                'user_name'      =>  $user_name,
	                'email'          =>  $row['email'],
	                'county'		 =>	 $row['county']
				) ) ) {

					return "The system encountered an error and was unable to process your login request. Please reload your browser and try again. [Error 1011]";
				}

				$this->load_system_vars();

				$tz = ( defined('DEFAULT_TIMEZONE') ? DEFAULT_TIMEZONE : "-5:00" );
				if ( ! date_default_timezone_set( $timezone_map[ $tz ] ) )
	        		$tz = "-5:00";

				$_SESSION['TZ'] = $tz;

				$this->db->query("UPDATE hostsync_client t1
								  SET t1.timestamp = UNIX_TIMESTAMP()
								  WHERE t1.id_hash = '{$_SESSION['id_hash']}'");

				unset($_SESSION['login_timeout'], $_SESSION['force_login']);

				session_write_close();

				if ( $redirect == 'poll' )
					header("Location: poll.php");
				else
					header("Location: index.php");

				exit;


			} else
                return "The username and password you entered cannot be matched against a valid user. Please verify that you have entered your username and cAsE sensitive password correctly. [Error 1012]";
		}
	}

	function load_system_vars() {

        if ( ! $_SESSION['VARIABLE'] )
            $_SESSION['VARIABLE'] = array();

		$result = $this->db->query("SELECT
                                	    t1.var_name,
                                	    t1.var_val
    							    FROM system_vars t1");
		while ( $row = $this->db->fetch_assoc($result) ) {

			$_SESSION['VARIABLE'][ $row['var_name'] ] = $row['var_val'];
		}

	}

	function user_set_tokens() {

		$_SESSION[ session_name() ] = session_id();
		$param = func_get_arg(0);

		$result = $this->db->query("SELECT COUNT(*) AS Total
									FROM hostsync_session t1
									WHERE t1.id_hash = '{$param['id_hash']}'");
		if ( $this->db->result($result, 0, 'Total') ) {

			if ( ! $this->db->query("UPDATE hostsync_session t1
									 SET
										 t1.session_id = '" . $_SESSION[ session_name() ] . "',
										 t1.time = UNIX_TIMESTAMP()
									 WHERE t1.id_hash = '{$param['id_hash']}'")
			) {

				$this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);
				return false;
			}

		} else {

			if ( ! $this->db->query("INSERT INTO hostsync_session
									 VALUES
									 (
										 NULL,
										 '" . $_SESSION[ session_name() ] . "',
										 '{$param['id_hash']}',
										 UNIX_TIMESTAMP(),
										 0
									 )")
			) {

				$this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);
				return false;
			}
		}

		$_SESSION['id_hash'] = $param['id_hash'];
		$_SESSION['user_name'] = $param['user_name'];
		$_SESSION['user_status'] = $param['user_status'];
		$_SESSION['my_name'] = stripslashes($param['full_name']);
		$_SESSION['county'] = $param['county'];
		$_SESSION['my_email'] = $param['email'];
		$_SESSION['req_count'] = 0;
		$_SESSION['req_time'] = 0;
		$_SESSION['HTTP_USER_AGENT'] = md5( $this->agent_random . $_SERVER['HTTP_USER_AGENT'] . $this->agent_random );
		if ( ! $_SESSION['VARIABLE'] )
			$_SESSION['VARIABLE'] = array();

		$cookie_expiry = ( time() + ( 86400 * (int)$this->cookie_timeout ) ); # Default 1 day plus cookie timeout value
		$cookie_secure = ( $_SERVER['HTTPS'] ? 1 : 0 );

		# SessID no longer stored in cookie to prevent login issues
		setcookie("session_time", time(), time() + ( ( $_SESSION['VARIABLE']['USER_TIMEOUT'] ? (int)$_SESSION['VARIABLE']['USER_TIMEOUT'] : $this->session_timeout ) * 60 ), "/", COOKIE_DOMAIN, $cookie_secure);
		setcookie("user_name", $param['user_name'], $cookie_expiry, "/", COOKIE_DOMAIN, $cookie_secure);

		if ( $param['remember'] ) {

			$cookie_key = $this->generate_key();
			setcookie("autologin", 1, $cookie_expiry, "/", COOKIE_DOMAIN, $cookie_secure);
			setcookie("cookie_key", sha1($cookie_key), $cookie_expiry, "/", COOKIE_DOMAIN, $cookie_secure);
			setcookie("user_hash", $_SESSION['id_hash'], $cookie_expiry, "/", COOKIE_DOMAIN, $cookie_secure);

			if ( ! $this->db->query("UPDATE hostsync_client
									  SET
										  cookie_key = '$cookie_key',
										  cookie_time = UNIX_TIMESTAMP()
									  WHERE id_hash = '{$param['id_hash']}'")
			) {

				$this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);
				return false;
			}
		}

		return true;
	}

	function user_isloggedin() {

		if ( isset($_SESSION['force_login']) )
    		return false;

		if ( isset($_SESSION['id_hash']) && isset($_SESSION[ session_name() ]) && $_SESSION[ session_name() ] == session_id() ) {

            $result = $this->db->query("SELECT t1.id_hash
                                        FROM hostsync_session t1
                                        WHERE t1.session_id = '{$_SESSION[ session_name() ]}'");
            if ( $stored_hash = $this->db->result($result, 0, 'id_hash') ) {

                if ( $stored_hash && $stored_hash == $_SESSION['id_hash'] )
                    return true;
            }
		}

		$this->db->query("DELETE FROM hostsync_session
                          WHERE id_hash = '{$_SESSION['id_hash']}'") or $this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);

		$this->err = "Invalid session";

		return false;
	}

	function getSessionTime() {

		$user_hash = $_SESSION['id_hash'];
		if ( $arg = func_get_arg(0) )
    		$user_hash = $arg;

		$r = $this->db->query("SELECT
                            	   t1.time AS session_time
							   FROM session t1
							   WHERE t1.id_hash = '$user_hash'");

		return $this->db->result($r, 0, 'session_time');
	}

	function user_logout() {

		$sess_id = $_SESSION['id_hash'];
		$local = true;

		if ( $arg = func_get_arg(0) ) {

			$local = false;
			$sess_id = $arg;
		}

		$this->db->query("DELETE
			                  t1.*,
			                  t2.*
		                  FROM hostsync_session t1
		                  LEFT JOIN table_lock t2 ON t2.user_hash = t1.id_hash
						  WHERE t1.id_hash = '$sess_id'") or $this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);

        $this->db->query("UPDATE hostsync_client t1
                          SET
	                          t1.cookie_key = NULL,
	                          t1.cookie_time = 0
                          WHERE t1.id_hash = '$sess_id'") or $this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);

		$this->db->query("UPDATE user_activity t1
						  SET t1.logout = UNIX_TIMESTAMP()
						  WHERE t1.id_hash = '$sess_id' AND t1.logout = 0") or $this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);

        if ( ! defined('CRON') ) {

        	if ( $local ) {

				unset($_SESSION['id_hash'], $_SESSION['user_name'], $_SESSION['user_status'], $_SESSION['HTTP_USER_AGENT']);
				session_unset();
				session_destroy();
        	}

	        $retain_cookies = array(
    	        'user_name',
    	        'https',
    	        'remember_me'
	        );

	        while ( list($cookie_name) = each($_COOKIE) ) {

	            if ( ! in_array($cookie_name, $retain_cookies) )
	                setcookie($cookie_name, '', time() - 3600, "/", COOKIE_DOMAIN);
	        }
        }

		return true;
	}

	function login_prompt() {

		$invoked_class = ($_POST['invoked_class'] ? $_POST['invoked_class'] : $this->ajax_vars['invoked_class']);
		$invoked_method = ($_POST['invoked_method'] ? $_POST['invoked_method'] : $this->ajax_vars['invoked_method']);
		$cf_func = ($_POST['cf_func'] ? $_POST['cf_func'] : $this->ajax_vars['cf_func']);
		$sf_func = ($_POST['sf_func'] ? $_POST['sf_func'] : $this->ajax_vars['sf_func']);
		$orig_ajax_vars = ($_POST['orig_ajax_vars'] ? $_POST['orig_ajax_vars'] : $this->ajax_vars['orig_ajax_vars']);

		$this->popup_id = $this->content['popup_controls']['popup_id'] = $this->content['popup_controls']['popup_id'] = "login_window";
		$this->content['popup_controls']['popup_title'] = "Please Log-In To Continue";
		$this->content['focus'] = 'user_name';

		$tbl = $this->form->form_tag().
		$this->form->hidden(array("popup_id" => $this->popup_id,
								  "previous_user" => $_SESSION['id_hash'],
								  "invoked_class" => $invoked_class,
								  "invoked_method" => $invoked_method,
								  "orig_ajax_vars" => $orig_ajax_vars,
								  "l"	=>	1,
								  "sf_func" => $sf_func,
								  "cf_func" => $cf_func))."
		<div class=\"panel\" id=\"main_table".$this->popup_id."\" style=\"margin-top:0;\">
			<div id=\"feedback_holder".$this->popup_id."\" style=\"background-color:#ffffff;border:1px solid #cccccc;font-weight:bold;padding:5px;display:none;margin-bottom:5px;\">
				<h3 class=\"error_msg\" style=\"margin-top:0;\">Error!</h3>
					<p id=\"feedback_message".$this->popup_id."\"></p>
			</div>
			<table cellspacing=\"1\" cellpadding=\"5\" style=\"background-color:#8c8c8c;width:700px;margin-top:0;\" class=\"smallfont\">
				<tr>
					<td style=\"width:50%;background-color:#ffffff;vertical-align:top;padding:10px;\">
						".($_SESSION['login_timeout'] ? "
						For security reasons, you were logged out after ".USER_TIMEOUT." minutes of inactivity.<br /><br />Please log in again to continue." : ($_SESSION['id_hash'] ? "
						Your session was interrupted.<br /><br />This tends to happen if you have logged into another computer or the server cleans up old session files. Please log in again to continue." : "Welcome to DealerChoice! Please enter your username and password to login.
						"))."
					</td>
					<td style=\"width:50%;background-color:#ffffff;padding:10px 0 10px 25px;width:50%;\">
						<div style=\"padding-bottom:5px;\">User Name:</div>
						".$this->form->text_box("name=user_name","value=".$_POST['user_name'],"size=25")."
						<div style=\"padding-top:15px;padding-bottom:5px;\">Password:</div>
						".$this->form->password_box("name=password","size=25","onFocus=this.value=''")."
						<div style=\"padding-top:15px;margin-left:145px;\">
							".$this->form->button("value=Go",
                    							  "id=primary",
                    							  "onClick=submit_form(\$('l').form,'login','exec_post','refresh_form','btn=login');")."
						</div>
					</td>
				</tr>
			</table>
		</div>".
		$this->form->close_form();

		$this->content['popup_controls']["cmdTable"] = $tbl;
		$this->content['jscript'] = "agent.poll.stop();";
		return;
	}

	function load_system_definitions() {
		while (list($key,$val) = each($_SESSION['VARIABLE'])) {
		    if ($val || is_numeric($val))
		        define($key,$val);
		}
	}

	function load_database_definitions() {
        if (is_array($_SESSION['DB_DEFINE']) && count($_SESSION['DB_DEFINE']) > 0) {
            for ($i = 0; $i < count($_SESSION['DB_DEFINE']); $i++) {
                if (defined($_SESSION['DB_DEFINE'][$i]))
                    $this->db->define($_SESSION['DB_DEFINE'][$i],constant($_SESSION['DB_DEFINE'][$i]));
            }
        }
	}

	function generate_key($length=7) {

		$password = "";
		$possible = "0123456789abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
		$i = 0;

		while ( $i < $length ) {

			$char = substr($possible, mt_rand(0, strlen($possible) - 1), 1);

			if ( ! strstr($password, $char) ) {

				$password .= $char;
				$i++;
			}
		}

		return $password;
	}

    function validEmail($email) {

        $isValid = true;
        $atIndex = strrpos($email, "@");

        if ( is_bool($atIndex) && ! $atIndex )
            $isValid = false;
        else {

	        $domain = substr($email, $atIndex + 1);
	        $local = substr($email, 0, $atIndex);
	        $localLen = strlen($local);
	        $domainLen = strlen($domain);

	        if ( $localLen < 1 || $localLen > 64 ) # local part length exceeded
    	        $isValid = false;
	        elseif ( $domainLen < 1 || $domainLen > 255 )  # domain part length exceeded
    	        $isValid = false;
	        elseif ( $local[0] == '.' || $local[ $localLen - 1 ] == '.' ) # local part starts or ends with '.'
    	        $isValid = false;
	        elseif ( preg_match('/\\.\\./', $local) ) # local part has two consecutive dots
    	        $isValid = false;
	        elseif ( ! preg_match('/^[A-Za-z0-9\\-\\.]+$/', $domain) ) # character not valid in domain part
    	        $isValid = false;
	        elseif ( preg_match('/\\.\\./', $domain) ) # domain part has two consecutive dots
    	        $isValid = false;
	        elseif ( ! preg_match('/^(\\\\.|[A-Za-z0-9!#%&`_=\\/$\'*+?^{}|~.-])+$/', str_replace("\\\\", "", $local) ) ) { # character not valid in local part unless

    	        if ( ! preg_match('/^"(\\\\"|[^"])+"$/', str_replace("\\\\", "", $local) ) ) # local part is quoted
        	        $isValid = false;
	        }
	        # Not compatible on windows
	        #if ( $isValid && ! ( checkdnsrr($domain, "MX") || checkdnsrr($domain, "A") ) ) # domain not found in DNS
    	        #$isValid = false;
        }

        return $isValid;
    }

    function regenerate_session() {

    	session_regenerate_id(true);
    	$_SESSION[ session_name() ] = session_id();

    	if ( ! $this->db->query("UPDATE hostsync_session t1
    	                         SET t1.session_id = '" . $_SESSION[ session_name() ] . "'
    	                         WHERE t1.id_hash = '{$_SESSION['id_hash']}'")
    	) {

    		$this->__trigger_error("{$this->db->db_errno} - {$this->db->db_error}", E_DATABASE_ERROR, __FILE__, __LINE__);
    		return false;
    	}

    	$this->load_system_vars();
    }
}

?>