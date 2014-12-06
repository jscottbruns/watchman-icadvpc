<?php
// Attempt to load XML extension if we don't have the XML functions
// already loaded.
if (!function_exists('xml_set_element_handler'))
{
    $extension_dir = ini_get('extension_dir');
    if (strtoupper(substr(PHP_OS, 0, 3) == 'WIN'))
    {
        $extension_file = 'php_xml.dll';
    }
    else
    {
        $extension_file = 'xml.so';
    }
    if ($extension_dir AND file_exists($extension_dir . '/' . $extension_file))
    {
        ini_set('display_errors', true);
        dl($extension_file);
    }
}

function htmlspecialchars_uni($text, $entities = true)
{
    return str_replace(
        // replace special html characters
        array('<', '>', '"'),
        array('&lt;', '&gt;', '&quot;'),
        preg_replace(
            // translates all non-unicode entities
            '/&(?!' . ($entities ? '#[0-9]+|shy' : '(#[0-9]+|[a-z]+)') . ';)/si',
            '&amp;',
            $text
        )
    );
}

class XML_Builder
{
    var $registry = null;
    var $charset = 'iso-8859-1';
    var $content_type = 'text/xml';
    var $open_tags = array();
    var $tabs = "";

    function XML_Builder($content_type = null, $charset = null)
    {
        if ($content_type)
        {
            $this->content_type = $content_type;
        }

        if ($charset)
        {
            $this->charset = $charset;
            if (strtolower($this->charset) == 'windows-1252')
                $this->charset = 'iso-8859-1';
        }
    }

    /**
    * Fetches the content type header with $this->content_type
    */
    function fetch_content_type_header()
    {
        return 'Content-Type: ' . $this->content_type . ($this->charset == '' ? '' : '; charset=' . $this->charset);
    }

    /**
    * Fetches the content length header
    */
    function fetch_content_length_header()
    {
        return 'Content-Length: ' . $this->fetch_xml_content_length();
    }

    /**
    * Sends the content type header with $this->content_type
    */
    function send_content_type_header()
    {
        @header('Content-Type: ' . $this->content_type . ($this->charset == '' ? '' : '; charset=' . $this->charset));
    }

    /**
    * Sends the content length header
    */
    function send_content_length_header()
    {
        @header('Content-Length: ' . $this->fetch_xml_content_length());
    }

    /**
    * Returns the <?xml tag complete with $this->charset character set defined
    *
    * @return   string  <?xml tag
    */
    function fetch_xml_tag()
    {
        return '<?xml version="1.0" encoding="' . $this->charset . '"?>' . "\n";
    }

    /**
    *
    * @return   integer Length of document
    */
    function fetch_xml_content_length()
    {
        return strlen($this->doc) + strlen($this->fetch_xml_tag());
    }

    function add_group($tag, $attr = array())
    {
        $this->open_tags[] = $tag;
        $this->doc .= $this->tabs . $this->build_tag($tag, $attr) . "\n";
        $this->tabs .= "\t";
    }

    function close_group()
    {
        $tag = array_pop($this->open_tags);
        $this->tabs = substr($this->tabs, 0, -1);
        $this->doc .= $this->tabs . "</$tag>\n";
    }

    function add_tag($tag, $content = '', $attr = array(), $cdata = false, $htmlspecialchars = false)
    {
        $this->doc .= $this->tabs . $this->build_tag($tag, $attr, ($content === ''));
        if ($content !== '')
        {
            if ($htmlspecialchars)
            {
                $this->doc .= htmlspecialchars_uni($content);
            }
            else if ($cdata OR preg_match('/[\<\>\&\'\"\[\]]/', $content))
            {
                $this->doc .= '<![CDATA[' . $this->escape_cdata($content) . ']]>';
            }
            else
            {
                $this->doc .= $content;
            }
            $this->doc .= "</$tag>\n";
        }
    }

    function build_tag($tag, $attr, $closing = false)
    {
        $tmp = "<$tag";
        if (!empty($attr))
        {
            foreach ($attr AS $attr_name => $attr_key)
            {
                if (strpos($attr_key, '"') !== false)
                {
                    $attr_key = htmlspecialchars_uni($attr_key);
                }
                $tmp .= " $attr_name=\"$attr_key\"";
            }
        }
        $tmp .= ($closing ? " />\n" : '>');
        return $tmp;
    }

    function escape_cdata($xml)
    {
        // strip invalid characters in XML 1.0:  00-08, 11-12 and 14-31
        // I did not find any character sets which use these characters.
        $xml = preg_replace('#[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]#', '', $xml);

        return str_replace(array('<![CDATA[', ']]>'), array('�![CDATA[', ']]�'), $xml);
    }

    function output()
    {
        if (!empty($this->open_tags))
        {
            trigger_error("There are still open tags within the document", E_USER_ERROR);
            return false;
        }

        return $this->doc;
    }

    /**
    * Prints out the queued XML and then exits.
    *
    * @param    boolean If not using shut down functions, whether to do a full shutdown (session updates, etc) or to just close the DB
    */
    function print_xml($full_shutdown = false)
    {
        global $db;
        /*
        if (defined('NOSHUTDOWNFUNC'))
        {
            if ($full_shutdown)
            {
                exec_shut_down();
            }
            else
            {
                $this->registry->db->close();
            }
        }*/

        $db->close();

        $this->send_content_type_header();
        echo $this->fetch_xml_tag() . $this->output();
        header('Content-Length: ' . ob_get_length());
        ob_end_flush();
        exit;
    }
}

// #############################################################################
// legacy stuff

class XMLexporter extends XML_Builder
{
}
?>