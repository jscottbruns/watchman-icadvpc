<?php
define('E_DATABASE_ERROR', 512);
$from_common = 1;

function ini_decrypt() {

	if ( ! defined('APPLICATION_PATH') ) {

		print "Error - Premature call to ini file parse. If problem persists delete all temporary internet files, close browser and repeat login process.";
    	exit;
	}

	$ini_file = realpath( APPLICATION_PATH . '/../include/watchman.ini' );

	if ( ! $ini_file || ! file_exists($ini_file) ) {

		print "Error - Cannot stat system settings file $ini_file. Please check filesystem for valid ini file or contact your system administrator.";
		exit;
	}

    $ini_array = parse_ini_file($ini_file, 1);

    foreach ( $ini_array as $key => $val ) {

        foreach ( $val as $sect_key => $sect_val ) {

            $el_key = preg_replace("/^$key\.(.*)$/", "$1", $sect_key);
            $ini_array[ $key ][ strtolower($el_key) ] = $sect_val;
            unset($ini_array[ $key ][ $sect_key ]);
        }
    }

    if ( ! $ini_array || ! is_array($ini_array) ) {

    	print "Error - Cannot parse ini settings file. Please check filesystem for valid ini file or contact your system administrator.";
    	exit;
    }

    define('PUN',1);

    return $ini_array;
}

function defineConfigVars($config_array) {

    if ( ! is_array($config_array) )
        return false;

    $define_sections = array(
        'database'  =>  array(
            'databasetype'          =>  'db_type',
            'databasehost'          =>  'db_host',
            'defaultdatabase'       =>  'db_name',
            'databaselist'          =>  'db_list',
            'databaseuser'          =>  'db_username',
            'databasepass'          =>  'db_password',
            'databaseport'          =>  'db_port',
            'connectioncharset'     =>  'connection_charset',
            'connectioncollation'   =>  'connection_collation'
        ),
        'cookie'    =>  array(
            'cookiename'            =>  'cookie_name',
            'cookiedomain'          =>  'cookie_domain',
            'cookiepath'            =>  'cookie_path',
            'cookiesecure'          =>  'cookie_secure',
            'cookieseed'            =>  'cookie_seed'
        )
    );

    foreach ( $config_array as $section => $value_array ) {

        if ( isset($define_sections[$section]) ) {

            while ( list($key, $val) = each($value_array) ) {

                if ( isset($define_sections[$section][$key]) )
                    define( strtoupper($define_sections[$section][$key]), $val);
                else
                    define( strtoupper($key), $val);
            }
        }
    }

    return true;
}

function find_root($file) {

    if ( $file && defined('SITE_ROOT') ) {

        $path = preg_split('/\\\|\//', $file);

        if ( $doc_root = preg_split('/\\\|\//', SITE_ROOT) ) {

            $delim = array_pop($doc_root);
            if ( ! $delim ) # Since the site_root has a trailing slash, last elem will be empty
                $delim = array_pop($doc_root);
        }

        $doc_match = preg_grep("/^$delim$/", $path);
        $file = implode( array_slice($path, ( key($doc_match) + 1 ) ), '/');
    }

    return $file;
}

function root_path($full_path) {

    $full_path = dirname($full_path);
    $path_split = preg_split('/\/|\\\/', $full_path);
    array_shift($path_split);

    if ( in_array( $path_split[ count($path_split) - 1 ], array('core', 'include') ) )
        $full_path = root_path($full_path);

    return preg_replace('/^(.*)([\/|\\\])$/', '$1', $full_path);
}

function errorlog_setup($errfile) {

	if ( ! $errfile || ! file_exists($errfile) ) {

	    if ( $errfile && ! file_exists( dirname($errfile) ) )
	        mkdir( dirname($errfile), 0777, true);

	    if ( ! $errfile || ( $errfile && ! touch($errfile) ) )
	        $errfile = realpath(APPLICATION_PATH . '/../../log') . '/cadviewer.err';
	}

    define('ERROR_FILE', $errfile);
}

?>