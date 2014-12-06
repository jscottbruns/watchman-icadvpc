<?php
class AJAX_layer extends errorHandler {

	public $ajax_vars = array();
	public $content = array();
	public $popup_id;

	private $err = array();
	private $jscript = array();

	function exec_post($post) {
		if ($_SESSION['force_login'] && get_class($this) != 'login') {
			$sf_func = $_POST['aa_sfunc'];
			$cf_func = $_POST['aa_cfunc'];
			$orig_ajax_vars = base64_encode(serialize($this->ajax_vars));
			$invoked_class = get_class($this);

			$this->content['jscript'] = "agent.call('login','sf_loadcontent','show_popup_window','login_prompt','popup_id=main_popup','invoked_class=$invoked_class','invoked_method=$method','orig_ajax_vars=$orig_ajax_vars','sf_func=$sf_func','cf_func=$cf_func');";
		} else
			$this->doit();

        $xml = new dC_AJAX_XML_Builder('text/xml',DEFAULT_CHARSET);
        $xml->array2xml($this->content);
        $xml->print_xml();
	}

	function load_class_vars($default,$args=NULL) {
		if (is_array($args) && count($args) > $default) {
			for ($i = $default; $i < count($args); $i++) {
				if (strstr($args[$i],"=") != strrchr($args[$i],"="))
					$this->ajax_vars[substr($args[$i],0,strpos($args[$i],"="))] = substr(strstr($args[$i],"="),1);
				else {
					list($arg1,$arg2) = explode("=",$args[$i]);
					$this->ajax_vars[$arg1] = $arg2;
				}
			}
		}
	}

	function sf_loadcontent($method) {
		$args = func_get_args();
		$this->load_class_vars(1,$args);
		if ($_SESSION['force_login'] && get_class($this) != 'login') {
			$sf_func = $_POST['aa_sfunc'];
			$cf_func = $_POST['aa_cfunc'];
			$orig_ajax_vars = base64_encode(serialize($this->ajax_vars));
			$invoked_class = get_class($this);

			$this->content['jscript'] = "agent.call('login','sf_loadcontent','show_popup_window','login_prompt','popup_id=main_popup','invoked_class=$invoked_class','invoked_method=$method','orig_ajax_vars=$orig_ajax_vars','sf_func=$sf_func','cf_func=$cf_func');";
		} elseif ($method)
			$this->$method();

        $xml = new dC_AJAX_XML_Builder('text/xml',DEFAULT_CHARSET);
        $xml->array2xml($this->content);
        $xml->print_xml();
	}

	function __trigger_error($error_msg, $errno, $file, $line, $flush=false, $popup=false, $submit_btn=NULL, $reset_error=false) {

		if ( $reset_error )
			$this->reset_error();

		if ( $error_msg ) {

			$file = find_root($file); # Shorten the file path

			$err_msg = "<!--E_LEVEL-->[" . strftime('%c') . "] [" . ( $_SESSION['user_name'] ? $_SESSION['user_name'] : "anonymous" ) . "@" . ( $_SERVER['REMOTE_ADDR'] ? $_SERVER['REMOTE_ADDR'] : "unknown" ) . "] [{$file}:{$line}] " . ( is_array($error_msg) ? $error_msg[0] : $error_msg ) . " ";
    		trigger_error($err_msg, $errno);

    		if ( $errno == E_DATABASE_ERROR ) {

    			if ( preg_match('/^(.*) - (.*)$/', $error_msg, $matches) )
                    $error_no = $matches[1];

                $error_msg = ( $error_no ? "$error_no - " : NULL ) . "A database error occurred when trying to process your request. The error has been logged and a notification has been sent to the DealerChoice support team. Please try your request again.";

                if ( $error_no == 'DB100' )
                    $error_msg = "$error_no - {$matches[2]}";
    		}

    		if ( $popup == 2 )
        		$error_msg = preg_replace('/^(.*)<!--.*-->$/', '$1', $error_msg);

    		if ( ! is_array($this->err) )
                $this->err = array();

    		if ( is_array($error_msg) )
                $this->err = array_merge($this->err, $error_msg);
    		else
                array_push($this->err, $error_msg);
		}

		if ( $flush ) {

			if ( $this->db->transaction === true )
				$this->db->end_transaction(1);

			if ( $flush == 2 ) # Return error message string for integration purposes if flush is 2
				return $err_msg;
			else
				$this->flush_error($popup);
		}
		if ( $submit_btn )
			$this->content['submit_btn'] = $submit_btn;

		return;
	}

	private function flush_error($popup=false) {

		$msg = implode("<br />", $this->err);

		if ( $popup == 1 ) {

			$this->error_template( implode("<br />", $this->err) );
			$this->content['popup_controls']['popup_id'] = $this->popup_id;
		} elseif ( $popup == 2 ) {

			if ( ! $this->content['action'] )
				$this->content['action'] = 'continue';

			$this->content['jscript'] = "alert('Error! " . addslashes( implode("\r\n", $this->err) ) . "');";
		} else {

			$this->content['error'] = 1;
			$this->content['form_return']['feedback'] = implode("<br />", $this->err);
		}

		if ( $this->jscript ) {

			if ( ! is_array($this->content['jscript']) ) {

				if ( $this->content['jscript'] )
    				$this->content['jscript'] = array($this->content['jscript']);
    			else
        			$this->content['jscript'] = array();
			}

			for ( $i = 0; $i < count($this->jscript); $i++ )
				array_push($this->content['jscript'], $this->jscript[$i]);
		}

		if ( $this->popup_id && ! $this->content['popup_controls']['popup_id'] )
            $this->content['popup_controls']['popup_id'] = $this->popup_id;

		return;
	}

	private function reset_error() {

		$this->err = array();
		return;
	}

	private function reset_jscript() {

		$this->jscript = array();
		return;
	}

	function jscript_action($jscript) {

		if ( ! is_array($this->jscript) )
    		$this->jscript = array();

		if ( $jscript )
			array_push($this->jscript, $jscript);
	}

	function set_error($node) {
		if (!trim($node))
            return $node;

        if (!is_array($node))
            $node = array($node);

        foreach ($node as $key => $val)
            $this->content['form_return']['err'][$val] = 1;

        return;
	}

	function set_error_msg($msg) {
        if ($msg)
            $this->err[] = $msg;
	}
}