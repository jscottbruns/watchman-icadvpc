package Watchman::SOAP;

use strict;

$| = 1;

BEGIN
{
    use constant DOCROOT => "/var/www/html/firehousewatchman.com/log";
    use constant DOCROOT_MOBILE => "/var/www/firehousewatchman.com-cgi/i";
	use constant LOG_DIR	=> '/var/log/watchman-alerting';
	use constant LOG_FILE	=> 'watchman-soap.log';
	use constant LOG_STDERR => 'watchman-soap.err';
	use constant TEMP_DIR	=> '/tmp';

    use vars qw( $DOCROOT $LICENSE $DEBUG $log );

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
}

use POSIX qw(strftime);
use DBI;
use File::Basename;
use File::Copy;
use URI::Escape;
use LWP::Simple;
use HTTP::Request;
use XML::XPath;
use HTML::Entities;
use File::Spec;
use File::Temp qw( tempfile );

use LWP::UserAgent;
use Net::SMTP::TLS;
use Data::Dumper;

use Log::Dispatch;
use Log::Dispatch::File;

open STDERR, '>>', File::Spec->catfile( LOG_DIR, LOG_STDERR );
$DEBUG = 1;

sub init
{
    my $this = shift;
    my $params = shift;

    my $class = ref($this) || $this;
    my $self = {};

    $self->{'err_msg'} = '';

    my $pass = 'yT0WFr5DwDn';
    my $user = 'watchman_soap';
    my $uri = "DBI:mysql:watchman;host=db2.dealer-choice.com";

    $DOCROOT = DOCROOT;

	if ( $log = Log::Dispatch->new )
	{
		unless (
			$log->add(
				Log::Dispatch::Screen->new(
					name		=> 'screen',
					min_level	=> 'debug',
					callbacks	=> sub {
						my %h = @_;
						return uc ( $h{level} ) . " $h{message} \n";
					}
				)
			)
		)
		{
			print STDERR "Error appending system logging to console output $! $@ \n";
		}
		unless (
			$log->add(
				Log::Dispatch::File->new(
					name		=> 'file',
					min_level	=> 'debug',
					mode		=> 'append',
					filename	=> File::Spec->catfile( LOG_DIR, LOG_FILE ),
					callbacks	=> sub {
						my %h = @_;
						return strftime("%Y-%m-%d %H:%M:%S", localtime()) . " " . uc ( $h{level} ) . " $h{message} \n";
					}
				)
			)
		)
		{
			print STDERR "Error appending system logging to log file output $! $@ ($$) \n";
		}
	}

    $self->{'license'} = $LICENSE = $params->{'license'};

    &write_log("New Watchman::SOAP service requested by [$LICENSE]");

    unless (
        $self->{'dbh'} = DBI->connect(
            $uri,
            $user,
            $pass,
            {
               PrintError => 0,
               RaiseError => 0,
               AutoCommit => 1
            }
    ) ) {

        &write_log("[error] Error connecting to database: $DBI::errstr\n", E_ERROR);
        return "-1\nServer error. Please try again. Err100";
    }

    if ( ! $self->{'license'} ) {

        &write_log("Unable to read user license. Invalid request, exiting\n", E_ERROR);
        return "-1\nNot Authorized - Err001\n";
    }

    # Validate the license
    $self->{'service_rss'} = 0;
    $self->{'service_sms'} = 0;
    $self->{'service_gps'} = 0;

	# TODO: ADD GPS AUTHENTICATION CHECK
    my $sth = $self->{'dbh'}->prepare("SELECT
                                           license_name,
                                           sms_viewer_uri,
                                           suspended,
                                           rss,
                                           sms,
                                           gps,
                                           sms_regex_location,
                                           sms_regex_address,
                                           sms_regex_city,
                                           sms_regex_county
                                       FROM license
                                       WHERE license_no = ?");
    if ( $sth->execute( $self->{'license'} ) ) {

        my $ref;
        if ( $ref = $sth->fetchrow_hashref ) {

            if ( $$ref{'suspended'} ) {
                &write_log("License validation failed. Account (" . $self->{'license'} . ") has been suspended.\n", E_ERROR);
                return "-1\nAccount Suspended - Err003\n";
            }

            $self->{'service_sms'} = 1 if $$ref{'sms'};
            $self->{'service_rss'} = 1 if $$ref{'rss'};
            $self->{'service_gps'} = 1 if $$ref{'gps'};

            $self->{'uri'} = $$ref{'sms_viewer_uri'};
            $self->{'regex_location'} = $$ref{'sms_regex_location'};
            $self->{'regex_address'} = $$ref{'sms_regex_address'};
            $self->{'regex_city'} = $$ref{'sms_regex_city'};
            $self->{'regex_county'} = $$ref{'sms_regex_county'};
        }
    }

    # SMTP Settings
    $self->{'smtp_from'}    =   "Watchman Notification <notify\@firehouseautomation.com>";
    $self->{'smtp_to'}      =   "Watchman Notification <notify\@firehouseautomation.com>";
    $self->{'smtp_server'}  =   'smtp.gmail.com';
    $self->{'smtp_port'}    =   '587';
    $self->{'smtp_user'}    =   'notify@firehouseautomation.com';
    $self->{'smtp_pass'}    =   '343K961a';
    $self->{'hostname'}     =   'firehouseautomation.com';
    $self->{'timeout'}      =   60;

    $self->{'response'}     =   '';
    $self->{'archive_days'} =   4;
	$params->{'req_count'} = $params->{'req_count'} || 1;

    $self->{'dispatch'} = {
        'sms_send'    =>  \&sms_send,
        'rss_feed'    =>  \&rss_feed,
        'hostsync'	  =>  \&hostsync,
        'testsoap'	  =>  \&testsoap,
        'gps_send'	  =>  \&gps_send,
    };

    bless $self, $class;

	for ( my $_i = 0; $_i < $params->{'req_count'}; $_i++ ) {

	    #my $handler = $self->{'dispatch'}->{ $params->{"request_$_i"}->{'service'} };
	    my $handler = $self->{'dispatch'}->{ $params->{'service'} };

	    if ( defined $handler && ref($handler) eq "CODE" ) {

	        #unless ( $handler->( $self, $params->{"request_$_i"} ) )
	        unless ( $handler->( $self, $params ) )
	        {

	            return "-1\n$self->{response}";
	        }

	        return "1" . ( $self->{'response'} ? "\n$self->{response}" : undef );
	    }
	}

    return "-1\nService not supported";
}

sub sms_send
{
    my $self = shift;
    my $params = shift;

    $self->{'subject'}      =   $params->{'subject'};
    $self->{'message'}      =   $params->{'message'};
    $self->{'debug'}        =   $params->{'debug'};
    $self->{'recip'}        =   $params->{'recip'};
    $self->{'data'}         =   $params->{'data'};
    $self->{'ulink_pw'}     =   $params->{'ulink_pw'};
    $self->{'inc_no'}       =   $params->{'inc_no'};

    my $location = $params->{'location'};
    my $q_location = $params->{'q_location'};
    # my $geocodeRegexAddr = $params->{'geocodeRegexAddr'};
    # my $geocodeRegexLoc = $params->{'geocodeRegexLoc'};

    my ($prev_inc, $symlink);

    if ( $self->{'data'} || $q_location )
    {
        my $file_path = "/var/www/firehousewatchman.com-cgi/i/$self->{license}";
        &write_log("Preparing to write incident $self->{inc_no} data to $file_path\n") if $self->{'data'};

        if ( $self->{'data'} && ! -d $file_path )
        {
            &write_log("License directory does not exist, creating...\n");
            mkdir( $file_path );
        }

        # Insert the link to google
        my ($address, $cross, $city, $q_link, $url_redirect);
        if ( $q_location ) {

            &write_log("Creating Google Maps html link\n");

            $address = URI::Escape::uri_escape( &trim( $q_location ) );

            my ($content, $uri_str);
            if ( $address ) {

	            $uri_str = $address;
	            $uri_str =~ s/%20/+/g;

	            # Street abbreviation replacement
	            $uri_str =~ s/\b(PY)\b/PKWY/;
	            $uri_str =~ s/\b(HY)\b/HWY/;

	            # Connect to the Google Map API and validate the address
	            &write_log("Validating address [ $uri_str ] against Google Maps Geocoding API\n");
	            $content = LWP::Simple::get("http://maps.googleapis.com/maps/api/geocode/xml?address=$uri_str&sensor=false");
            }

            if ( $content ) {

                my $xp = XML::XPath->new(
                    xml => $content
                );

                my $stat = $xp->findvalue("//status");
                if ( $stat eq 'OK' ) {

                    my ($address, $lat, $lng, $filtered, $geo_type);
                    my $results = $xp->find("//result");

                    &write_log("Address validation was successful, " . $results->size . " result(s) returned\n");

                    if ( $results->size > 1 && $self->{'regex_county'} ) {

                        &write_log("Filtering multi-row result set\n");
                        my $i;
                        for ( $i = 1; $i <= $results->size; $i++ ) {

                            if ( $xp->findvalue("/GeocodeResponse/result[$i]/address_component[type/text()='administrative_area_level_2']/long_name") =~ /$self->{regex_county}/i ) {

                                $address = $xp->findvalue("//result[$i]/formatted_address/text()");
                                $lat = $xp->findvalue("//result[$i]//location/lat");
                                $lng = $xp->findvalue("//result[$i]//location/lng");
                                $geo_type = $xp->findvalue("//result[$i]//location_type");
                                $filtered = 1;

                                last;
                            }
                        }
                    }

                    my $map_link;

                    if ( $results->size == 1 || ! $filtered ) {

                        &write_log("Unable to identify valid address from multi-result set, defaulting to first result\n", 1) if ( $results->size > 1 );

                        $address = $xp->findvalue("//result[1]/formatted_address/text()");
                        $lat = $xp->findvalue("//result[1]//location/lat");
                        $lng = $xp->findvalue("//result[1]//location/lng");
                        $geo_type = $xp->findvalue("//result[1]//location_type");
                    }

                    if ( $geo_type && $geo_type eq 'APPROXIMATE' ) {

                        &write_log("Location geocode result returned approximate coordinates only, geocode location mapping not available for this location.\n");
                        undef $lat;
                        undef $lng;
                    }

                    if ( $lat && $lng ) {

                        &write_log("Assigning geocode address: $address\n");
                        &write_log("Assigning geocode Lat/Long coords: $lat, $lng\n");

                        $uri_str = "$lat,$lng";
                        $map_link = "http://maps.google.com/?q=$uri_str";

                        if ( $self->{'data'} && $location )
                        {
                        	my $reglocation = $location;
                        	$reglocation =~ s/\(/\\(/g;
                        	$reglocation =~ s/\)/\\)/g;

                            $location = "<a href=\"$map_link\">$location</a>";

                            &write_log("Writing map hyperlink $map_link into incident location\n");
                            $self->{'data'} =~ s/$reglocation/$location/ms;

                        }

						&write_log("Loading geoimage display table for [$lat,$lng] ");

						my $geoimg = {
							'map'			=> {
								'large'	=> "http://maps.googleapis.com/maps/api/staticmap?markers=size:small%7C$lat,$lng&zoom=14&size=200x150&scale=2&sensor=false",
								'thumb'	=> "http://maps.googleapis.com/maps/api/staticmap?markers=size:small%7C$lat,$lng&zoom=14&size=125x96&scale=1&sensor=false",
								'href'	=> "http://maps.google.com/?q=$lat,$lng&t=m&output=mobile",
							},
							'hybrid'		=> {
								'large'	=> "http://maps.googleapis.com/maps/api/staticmap?markers=size:small%7C$lat,$lng&zoom=14&size=200x150&scale=2&sensor=false&maptype=hybrid",
								'thumb'	=> "http://maps.googleapis.com/maps/api/staticmap?markers=size:small%7C$lat,$lng&zoom=14&size=125x96&scale=1&sensor=false&maptype=hybrid",
								'href'	=> "http://maps.google.com/?q=$lat,$lng&t=h&output=mobile"
							},
							'street'		=> {
								'large'	=> "http://maps.googleapis.com/maps/api/streetview?location=$lat,$lng&size=400x300&sensor=false",
								'thumb'	=> "http://maps.googleapis.com/maps/api/streetview?location=$lat,$lng&size=125x96&sensor=false",
								'href'	=> "http://maps.google.com/?q=$lat,$lng&output=mobile&layer=c&cbll=$lat,$lng&cbp=12,0,0,0,0"
							}
						};

						$self->{'data'} .= "
						<div style=\"width:538px;height:308px; background-color: #8f8f8f; position: relative;\" id=\"img_bounds\">
						    <div style=\"position: absolute; top: 4px; left: 4px;\" id=\"img_focus\"><a href=\"$geoimg->{map}->{href}\" id=\"geoimg_a\"><img src=\"$geoimg->{map}->{large}\" name=\"geoimg_src\" id=\"geoimg_src\" border=\"0\"/></a></div>
						    <div style=\"position: absolute; top: 5px; right: 4px;\"><a href=\"javascript:void(0);\"><img src=\"$geoimg->{map}->{thumb}\" onClick=\"document.getElementById('geoimg_src').src='$geoimg->{map}->{large}'; document.getElementById('geoimg_a').href='$geoimg->{map}->{href}';\" border=\"0\"/></a></div>
						    <div style=\"position: absolute; top: 106px; right: 4px;\"><a href=\"javascript:void(0);\"><img src=\"$geoimg->{hybrid}->{thumb}\" onClick=\"document.getElementById('geoimg_src').src='$geoimg->{hybrid}->{large}'; document.getElementById('geoimg_a').href='$geoimg->{hybrid}->{href}';\" border=\"0\"/></a></div>
						    <div style=\"position: absolute; top: 207px; right: 4px;\"><a href=\"javascript:void(0);\"><img src=\"$geoimg->{street}->{thumb}\" onClick=\"document.getElementById('geoimg_src').src='$geoimg->{street}->{large}'; document.getElementById('geoimg_a').href='$geoimg->{street}->{href}';\" border=\"0\"/></a></div>
						</div>";


                        # Create the URL redirector
                        my $url_key;
                        &write_log("Creating URL redirector to Google map reference\n");

                        my $sth = $self->{'dbh'}->prepare( qq{
                            SELECT ( MIN(url_key) + 1 ) AS f
                            FROM (
                                SELECT DISTINCT t0.url_key, t1.url_key AS number_plus_one
                                FROM url_redirect AS t0
                                LEFT JOIN url_redirect AS t1 ON ( t0.url_key + 1 ) = t1.url_key
                            ) AS temp1
                            WHERE ISNULL( number_plus_one )
                        } );

                        if ( $sth->execute ) {

                            my $array_ref = $sth->fetchall_arrayref( [ 0 ] );

                            $url_key = @{ $array_ref }[0]->[0] if ( @$array_ref );
                            $url_key = 0 if ( ! $url_key );

                        }

                        if ( defined $url_key && $url_key >= 0 ) {

                            $url_redirect = "http://fhwm.net/r/$url_key";

                            my $sth = $self->{'dbh'}->prepare(  qq{
                                INSERT INTO url_redirect
                                VALUES( ?, ?, NOW(), ?, ? )
                            } );

                            unless ( $sth->execute( $url_redirect, $url_key, $self->{'license'}, $map_link ) ) {

                                &write_log("Database Insert Error: $DBI::errstr \n");
                                undef $url_redirect;
                            }

                            &write_log("URL redirector created $url_redirect \n") if ( $url_redirect );
                        }

                        # Delete from the url redirect table older than archive_days
                        &write_log("Purging redirector table of rows older than $self->{archive_days} days\n");

                        my $sth = $self->{'dbh'}->prepare( qq{
                            DELETE FROM url_redirect
                            WHERE DATEDIFF( NOW(), url_redirect.datetime ) >= ?
                        } )->execute( $self->{'archive_days'} );
                    }

                } else {

                    &write_log("Unable to validate address, no results found\n") if ( $stat eq 'ZERO_RESULTS' );
                    &write_log("Malformed or missing address, request was invalid\n", 1) if ( $stat eq 'INVALID_REQUEST' );
                    &write_log("Client connection abuse reported by Google API, aborting\n", 1) if ( $stat eq '620' );
                }

            } else {

                &write_log("HTTP request failed, unable to map incident location", 1);
            }
        }

        if ( $self->{'data'} ) {

            &write_log("Looking up incident $self->{inc_no} for previous symlink\n");

            my $sth = $self->{'dbh'}->prepare(qq{
                SELECT symlink
                FROM notification
                WHERE license_no = ? AND inc_no = ?
            });

            if ( $sth->execute( $self->{'license'}, $self->{'inc_no'} ) ) {

                my $array_ref = $sth->fetchall_arrayref( [ 0 ] );

                $symlink = @{ $array_ref }[0]->[0] if ( @$array_ref );

                if ( ! $symlink ) {

                    &write_log("No previous incidents found, generating symlink\n");

                    $symlink = 0;
                    do {
                        $symlink++;
                    } until ( ! -f "$file_path/$symlink" );

                } else {

                    &write_log("Previous incident found\n");
                    $prev_inc = 1;
                }

                &write_log("Assigning symlink: $symlink => $self->{inc_no} \n");
            }

            &write_log("Writing incident data to file $self->{inc_no}\n");
            if ( open(FH, ">" . $file_path . '/' . $self->{'inc_no'} ) ) {

                print FH $self->{'data'};
                close FH;

                my $symlink_res;

                if ( $symlink ) {

                    if ( -f "$file_path/$symlink" ) {

                        $symlink_res = 1;
                        &write_log("Symlink exists from previous incident - Assigning symlink $symlink \n");

                        my $link = "http://fhwm.net/$self->{uri}/$symlink";

                        &write_log("Appending SMS link [ $link ] to SMTP message\n");
                        $self->{'message'} .= " $link";

                    } else {

                        &write_log("Writing SMS web view symlink [ $file_path/$symlink ] \n");
                        my $symlink_res = eval { symlink( "$file_path/$self->{inc_no}", "$file_path/$symlink" ); 1 };
                        if ( $symlink_res ) {

                            my $link = "http://fhwm.net/$self->{uri}/$symlink";

                            &write_log("Appending SMS link [ $link ] to SMTP message\n");
                            $self->{'message'} .= " $link";
                        }
                        &write_log("Error writing symlink: $@ \n", 1) if ( ! $symlink_res );
                    }
                }

                my $cmd = "find $file_path/* -mtime +$self->{archive_days} -exec rm {} \\;";
                my $out = `$cmd`;

                &write_log("Removing incident files older than $self->{archive_days} days old [ $cmd ] \n");
                &write_log("Command output was: $out \n") if $DEBUG;
                &write_log("Error removing old incident files. Command return code was: $? \n", 1) if ( $? != 0 );

            } else {

                &write_log("Error writing to file: $@\n");
            }

        }

        if ( $url_redirect ) {

            &write_log("Appending URL redirect to message\n");
            $self->{'message'} .= " $url_redirect";
        }
    }

    unless ( @{ $self->{'recip'} } ) {

        $self->{'response'} = "Recipient list empty, notifications not required at this time\n";
        &write_log( $self->{'response'} );

        return undef;
    }

    &write_log("Total SMS recipients: " . ( $#{ $self->{'recip'} } + 1 ) . " \n");

    my $carrier = {};
    my $c = 0;

    my %row;
    my $sth = $self->{'dbh'}->prepare("SELECT *
                                       FROM carriers");
    if ( $sth->execute ) {

        $sth->bind_columns( \( @row{ @{$sth->{NAME} } } ) );
        while ( $sth->fetch ) {

            $c++;
            $carrier->{ $row{'carrier'} } = {
                'method'    =>  $row{'method'},
                'hostname'  =>  $row{'hostname'},
                'port'      =>  $row{'port'},
                'auth_user' =>  $row{'auth_user'},
                'auth_pass' =>  $row{'auth_pass'},
                'intl_req'  =>  $row{'intl_req'}
            }
        }
    }

    &write_log("Loaded $c wireless carriers\n");
    &write_log("Grouping recipient list by wireless carrier\n");

    my $recip_group = {};
    foreach ( @{ $self->{'recip'} } ) {

        if ( $_ =~ /^(.*)\@(.*)$/ ) {

            $recip_group->{ $2 } = [] if ( ! $recip_group->{ $2 } );
            push( @{ $recip_group->{ $2 } }, $1 );
        }
    }

    my $return;
    my $mid = '1C936BB4';

    for my $key ( keys %{ $recip_group } ) {

        &write_log("Preparing $key recipient group for $carrier->{ $key }->{method} delivery \n");

        if ( $recip_group->{ $key } ) {

            if ( $carrier->{ $key }->{'method'} eq 'smtp' ) {

                &write_log("Calling SMTP SMS delivery service\n");

                $return = $self->sms_sendSMTP( {
                    'recip'       =>  $recip_group->{ $key },
                    'subject'     =>  $params->{'subject'},
                    'message'     =>  $self->{'message'},
                    'hostname'    =>  $carrier->{ $key }->{'hostname'},
                    'msg_id'      =>  $mid
                } );

            } elsif ( $carrier->{ $key }->{'method'} eq 'wctp' ) {

                &write_log("Calling WCTP SMS delivery service\n");

                $return = $self->sms_sendWCTP( {
                    'recip'     =>  $recip_group->{ $key },
                    'subject'   =>  $params->{'subject'},
                    'message'   =>  $self->{'message'},
                    'hostname'  =>  $carrier->{ $key }->{'hostname'},
                    'port'      =>  $carrier->{ $key }->{'port'},
                    'auth_user' =>  $carrier->{ $key }->{'auth_user'},
                    'auth_pass' =>  $carrier->{ $key }->{'auth_pass'},
                    'intl_req'  =>  $carrier->{ $key }->{'intl_req'},
                    'msg_id'    =>  $mid
                } );

            } elsif ( $carrier->{ $key }->{'method'} eq 'snpp' ) {

                $return = $self->sms_sendSNPP( {
                    'recip'     =>  $recip_group->{ $key },
                    'subject'   =>  $params->{'subject'},
                    'message'   =>  $self->{'message'},
                    'hostname'  =>  $carrier->{ $key }->{'hostname'},
                    'port'      =>  $carrier->{ $key }->{'port'},
                    'auth_user' =>  $carrier->{ $key }->{'auth_user'},
                    'auth_pass' =>  $carrier->{ $key }->{'auth_pass'}
                } );


            } elsif ( $carrier->{ $key }->{'method'} eq 'tap' ) {

                $return = $self->sms_sendTAP( {
                    'recip'     =>  $recip_group->{ $key },
                    'subject'   =>  $params->{'subject'},
                    'message'   =>  $self->{'message'},
                    'hostname'  =>  $carrier->{ $key }->{'hostname'},
                    'port'      =>  $carrier->{ $key }->{'port'},
                    'auth_user' =>  $carrier->{ $key }->{'auth_user'},
                    'auth_pass' =>  $carrier->{ $key }->{'auth_pass'}
                } );
            }
        }
    }

    if ( $prev_inc ) {

        &write_log("Updating previous incident\n");
        unless ( $self->{'dbh'}->prepare("UPDATE notification SET recipients = ?, result = ?, symlink = ?, err = ? WHERE license_no = ? AND inc_no = ?")
                               ->execute( "CONCAT(notification.recipients, ', ', " . ( $self->{'recip'} ? "'" . join(', ', @{ $self->{'recip'} }) . "'" : "''" ) . ")", ( defined( $return ) ? 1 : -1 ), $symlink, ( $self->{'err_msg'} ? $self->{'err_msg'} : 'NULL'), $self->{'license'}, $self->{'inc_no'} )
        ) {

            &write_log("Database query error: $DBI::errstr\n");
        }

    } elsif ( $self->{'inc_no'} ) {

        &write_log("Preparing database insert\n");
        unless ( $self->{'dbh'}->prepare("INSERT INTO notification VALUES ( ?, NOW(), ?, ?, ?, ?, ?, ?, ? ) ")
                               ->execute( $self->{'license'}, $self->{'inc_no'}, $self->{'subject'}, $self->{'message'}, ( $self->{'recip'} ? join(', ', @{ $self->{'recip'} }) : ''), ( defined $return ? 1 : -1 ), $symlink, ( $self->{'err_msg'} ? $self->{'err_msg'} : 'NULL') )

        ) {

            &write_log("Database query error: $DBI::errstr\n");
        }
    }

    if ( defined( $return ) ) {

        &write_log("SMS delivery service completed " . ( $self->{'err_msg'} ? "with errors" : "without errors" ) . " \n");
        $self->{'response'} = "SMS delivery service completed " . ( $self->{'err_msg'} ? "with errors" : "without errors" ) . "\n";
        $self->{'response'} .= "SMS Errors: $self->{err_msg}\n" if $self->{'err_msg'};

        return 1;
    }

    &write_log("SMS delivery service failed\n");
    $self->{'response'} = "SMS delivery service failed\n";
    $self->{'response'} .= "SMS Errors: $self->{err_msg}\n" if $self->{'err_msg'};

    return undef;
}

sub sms_sendSMTP
{
    my $self = shift;
    my $params = shift;

    my $smtp;

    &write_log("Opening connection to SMTP server $self->{smtp_server}\n");

    if (
        $smtp = new Net::SMTP::TLS(
            $self->{'smtp_server'},
            Hello       =>      $self->{'hostname'},
            Port        =>      $self->{'smtp_port'},
            User        =>      $self->{'smtp_user'},
            Password    =>      $self->{'smtp_pass'},
            Timeout     =>      $self->{'timeout'},
    ) ) {

        $smtp->mail( "$self->{smtp_from}\n" );
        $smtp->to( $self->{'smtp_to'} );

        my @bcc;
        foreach ( @{ $params->{'recip'} } ) {
            if ( $_ =~ /^([0-9]{10})$/ ) {
                $smtp->bcc( $_ . '@' . $params->{'hostname'} );
                push( @bcc, $_ . '@' . $params->{'hostname'} );
            }
        }

        &write_log("Setting message ID: $params->{msg_id} \n");
        &write_log("Writing recipient list: " . join(', ', @bcc) . "\n") if $self->{'debug'};
        &write_log("Writing subject: $params->{subject}\n");
        &write_log("Writing message: $params->{message}\n");

        $smtp->data();
        $smtp->datasend( "From: $self->{smtp_from}\n" );
        $smtp->datasend( "Subject: $params->{subject}\n" );
        $smtp->datasend( "To: $self->{'smtp_to'}\n" );
        $smtp->datasend( "\n" );
        $smtp->datasend( "$params->{message}\n" );

        $smtp->dataend();

        &write_log("SMTP delivery successful\n");
        $smtp->quit;

        return 1;

    } else {

        $self->{'err_msg'} = ( defined( $@ ) ? $@ : $! );
        $self->{'response'} = "SMTP connection error $self->{err_msg}";
        &write_log( "$self->{response} \n" );

        return undef;
    }
}

sub sms_sendWCTP
{
    my $self = shift;
    my $params = shift;

    &write_log("WCTP delivery service started\n");

    my $gmt_time = POSIX::strftime("%Y-%m-%dT%H:%M:%S", gmtime);

    my $ua = LWP::UserAgent->new(
        'timeout'   =>      25
    );

    $params->{'hostname'} = "http://" . $params->{'hostname'} if ( $params->{'hostname'} !~ /^http:\/\// );

    &write_log("Initiating HTTP request to hostname $params->{'hostname'}\n");

    my $request;
    unless (
        $request = HTTP::Request->new(
            POST    =>  $params->{'hostname'},
            HTTP::Headers->new(
                'Content-Type'  =>  'text/xml'
            )
        )
    ) {

        $self->{'err_msg'} = $self->{'response'} = "Error initiating HTTP Request: $@\n";
        &write_log($self->{'err_msg'});

        return undef;
    }

    my $msg_id = $params->{'msg_id'};
    my $wctp_user = "Watchman Notification";
    $wctp_user = $params->{'auth_user'} if ( $params->{'auth_user'} );

    my $wctp_pass;
    $wctp_pass = "securityCode=\"$params->{auth_pass}\"" if ( $params->{'auth_pass'} );

    &write_log("Setting message ID: $msg_id\n");
    &write_log("Setting WCTP user ID: $wctp_user\n");
    &write_log("Setting WCTP passphrase: $wctp_pass\n");

    my $recip_xml;
    my $c = 0;
    foreach ( @{ $params->{'recip'} } ) {

        if ( $_ =~ /^([0-9]{10})$/ ) {

            $c++;
            my $phone = $_;
            $phone = "+1$phone" if ( $params->{'intl_req'} );
            &write_log("Writing WCTP recipient: $phone \n");

            $recip_xml .= "<wctp-Recipient recipientID=\"$phone\" />\n";
        }
    }

    if ( $c == 0 ) {

        &write_log("No valid recipients, unable to continue\n", 1);
        $self->{'err_msg'} = "No valid recipients, unable to continue";

        return undef;
    }

    my $subject = HTML::Entities::encode_entities( $params->{'subject'} );
    my $message = HTML::Entities::encode_entities( $params->{'message'} );

    &write_log("Setting SMS subject: $subject\n");
    &write_log("Setting SMS message: $message\n");

    my $xml = <<XML;
<?xml version="1.0" ?>
<!DOCTYPE wctp-Operation SYSTEM "http://dtd.wctp.org/wctp-dtd-v1r1.dtd">
<wctp-Operation wctpVersion="wctp-dtd-v1r3">
    <wctp-SendMsgMulti>
        <wctp-MsgMultiHeader submitTimestamp="$gmt_time">
            <wctp-Originator senderID="$wctp_user" $wctp_pass />
            <wctp-MsgMultiControl messageID="$msg_id" allRecipsRequired="false" />
            $recip_xml
        </wctp-MsgMultiHeader>
        <wctp-Payload>
            <wctp-Alphanumeric>$subject: $message</wctp-Alphanumeric>
        </wctp-Payload>
    </wctp-SendMsgMulti>
</wctp-Operation>
XML

    &write_log("Writing XML content: $xml\n") if ( $self->{'debug'} );
    $request->content( $xml );

    &write_log("Initiating HTTP request\n");
    my $response = $ua->request( $request );

    if ( $response->status_line eq '200 OK' ) {

        &write_log("HTTP Request successful (" . $response->status_line . ")\n");
        &write_log("XML Response: " . $response->content . "\n") if ( $self->{'debug'} );

        my $content = $response->content;
        if ( $content =~ m/<!DOCTYPE/ ) {

            &write_log("Removing DOCTYPE declaration from XML response\n");
            $content =~ s/(<!DOCTYPE .*?>)//;
        }

        my $xp = XML::XPath->new(
            'xml'   =>  $content
        );

        my ($resp_code, $resp_text, $result, $valid);
        my $failed_rcp = [];

		if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure") || $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success") ) {

		    $valid = 1;
		    if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure") ) {

		        undef $result;
		        $resp_code = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure/\@errorCode");
		        $resp_text = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Failure/\@errorText");

		    } else {

		        $result = 1;
		        $resp_code = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success/\@successCode");
		        $resp_text = $xp->findvalue("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-Success/\@successText");

		    }

		    if ( $xp->exists("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-FailedRecipient") ) {

		        $result = -1 if ( defined $result );

		        my $nodeset = $xp->findnodes("/wctp-Operation/wctp-SendMsgMultiResponse/wctp-FailedRecipient");
		        foreach my $node ( $nodeset->get_nodelist ) {

		            push( @{ $failed_rcp }, {
		                'recipient'     =>      $node->getAttribute('recipientID'),
		                'errCode'       =>      $node->getAttribute('errorCode'),
		                'errText'       =>      $node->getAttribute('errorText')
		            } );
		        }
		    }
		}

		if ( $valid ) {

            &write_log("Valid WCTP response returned\n");

            if ( defined $result ) {

                my $feedback = "WCTP request successful " . ( $result == -1 ? "with failed recipient(s) " : undef ) . "($resp_code) $resp_text \n";
                $self->{'err_msg'} = $feedback if ( $result == -1 );

                &write_log( $feedback );

            } else {

	            $self->{'err_msg'} = "WCTP request unsuccessful ($resp_code) $resp_text \n";
	            &write_log( $self->{'err_msg'} );

            }

            if ( @$failed_rcp ) {

                foreach my $_i ( @{ $failed_rcp } ) {

	                $self->{'err_msg'} .= "    Failed Recipient: $_i->{recipient} ($_i->{errCode}) $_i->{errText} \n";
	                &write_log("    Failed Recipient: $_i->{recipient} ($_i->{errCode}) $_i->{errText} \n");
                }
            }

            return ( defined $result ? 1 : undef );
		}

    } else {

        &write_log("HTTP request unsuccessful (" . $response->status_line . ")\n");
        &write_log("Headers: " . $response->headers_as_string . "\n") if ( $self->{'debug'} );

        $self->{'err_msg'} = "WCTP Processing Error - Host [ $params->{hostname} ] HTTP Request Error: HTTP " . $response->status_line;
        $self->{'response'} = $self->{'err_msg'};

        return undef;
    }


}

sub sms_sendSNPP
{
    my $self = shift;
    my $params = shift;

    &write_log("WCTP delivery service started\n");

}

sub sms_sendTAP
{
    my $self = shift;
    my $params = shift;

    &write_log("TAP delivery service started\n");
}

sub rss_feed
{
    my $self = shift;
    my $params = shift;

    &write_log("RSS service started\n");

    my $args = {
        'inc_no'    =>  $params->{'inc_no'},
        'area'      =>  $params->{'area'},
        'units'     =>  $params->{'units'},
        'location'  =>  $params->{'location'},
        'callGroup' =>  $params->{'callGroup'},
        'callType'  =>  $params->{'callType'},
        'typeName'  =>  $params->{'typeName'},
        'text'      =>  $params->{'text'}
    };

    &write_log("Setting RSS value IncNo: $params->{inc_no}\n");
    &write_log("Setting RSS value Area: $params->{area}\n");
    &write_log("Setting RSS value Units: $params->{units}\n");
    &write_log("Setting RSS value Location: $params->{location}\n");
    &write_log("Setting RSS value CallGroup: $params->{callGroup}\n");
    &write_log("Setting RSS value CallType: $params->{typeCode}\n");
    &write_log("Setting RSS value TypeName: $params->{typeName}\n");
    &write_log("Setting RSS value Inc Text: $params->{text}\n");

    &write_log("Checking rss table for incident # $args->{inc_no}\n");

    my ($sth, %row);
    if ( $sth = $self->{'dbh'}->prepare("SELECT area, units, location, callGroup, callType, callTypeName, text
                                         FROM rss
                                         WHERE license_no = ? AND inc_no = ?")
    ) {

        if ( $sth->execute( $self->{'license'}, $args->{'inc_no'} ) ) {

            $sth->bind_columns( \( @row{ @{$sth->{NAME} } } ) );

            if ( $sth->fetch ) {

                &write_log("Prior incident found, updating incident with RSS arguments\n");

                my $sth_2;
                unless (
                    $self->{'dbh'}->prepare("UPDATE rss
                                             SET area = ?, units = ?, location = ?, callGroup = ?, callType = ?, callTypeName = ?, text = ?
                                             WHERE license_no = ? AND inc_no = ?")->execute( ( $args->{'area'} && $args->{'area'} ne $row{'area'} ? $args->{'area'} : $row{'area'} ), $args->{'units'}, $args->{'location'}, ( $args->{'callGroup'} && $args->{'callGroup'} ne $row{'callGroup'} ? $args->{'callGroup'} : $row{'callGroup'} ), ( $args->{'callType'} && $args->{'callType'} ne $row{'callType'} ? $args->{'callType'} : $row{'callType'} ), ( $args->{'typeName'} && $args->{'typeName'} ne $row{'typeName'} ? $args->{'typeName'} : $row{'typeName'} ), $args->{'text'}, $self->{'license'}, $args->{'inc_no'} )
                ) {

                    &write_log("Database update error: $DBI::errstr\n");
                    $self->{'response'} = "Server error. Err102#" . __LINE__;
                    return undef;
                }

            } else {

                &write_log("No prior incident found, preparing database insert\n");

                unless (
                    $self->{'dbh'}->prepare("INSERT INTO rss VALUES ( NULL, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, ? ) ")
                                  ->execute( $self->{'license'}, $args->{'inc_no'}, $args->{'area'}, $args->{'units'}, $args->{'location'}, $args->{'callGroup'}, $args->{'callType'}, $args->{'typeName'}, $args->{'text'})
                ) {

                    &write_log("Database insert error: $DBI::errstr\n");
                    $self->{'response'} = "Server error. Err102#" . __LINE__;
                    return undef;
                }

            }
        } else {

            &write_log("Database execute error: $DBI::errstr\n");
            $self->{'response'} = "Server error. Err102#" . __LINE__;
            return undef;
        }

    } else {

        &write_log("Database prepare error: $DBI::errstr\n");
        $self->{'response'} = "Server error. Err102#" . __LINE__;
        return undef;
    }

    &write_log("RSS update service completed successfully\n");
    return 1;
}

sub write_log
{
    my $msg = shift;
    my $level = shift;
    my ($package, $file, $line) = caller;

	$level = E_INFO if ! $level;

	$msg =~ s/\n\s*$//;
    $msg = "[$package:$line] $msg ($$)";

	$log->$level($msg) if defined $log;
	print STDERR "$msg \n" unless defined $log;
}

sub trim
{
    my $string = shift;
    if ( $string ) {
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
    }
}

sub update_printout
{
    my $self = shift;
    my $params = shift;

    $self->{'subject'}      =   $params->{'subject'};
    $self->{'message'}      =   $params->{'message'};
    $self->{'debug'}        =   $params->{'debug'};
    $self->{'recip'}        =   $params->{'recip'};
    $self->{'data'}         =   $params->{'data'};
    $self->{'ulink_pw'}     =   $params->{'ulink_pw'};
    $self->{'inc_no'}       =   $params->{'inc_no'};

    my $location = $params->{'location'};
    my $q_location = $params->{'q_location'};
    my $geocodeRegexAddr = $params->{'geocodeRegexAddr'};
    my $geocodeRegexLoc = $params->{'geocodeRegexLoc'};

    $self->{'response'} = "Loc: $location - Inc No: $self->{inc_no}";return undef;

    my ($prev_inc, $symlink);

    if ( $self->{'inc_no'} && $q_location ) {

        my $file_path = "/var/www/firehousewatchman.com-cgi/i/$self->{license}";
        &write_log("Preparing to write incident $self->{inc_no} data to $file_path\n") if $self->{'data'};

        if ( $self->{'data'} && ! -d $file_path ) {

            &write_log("License directory does not exist, creating...\n");
            mkdir( $file_path );
        }

        # Insert the link to google
        my ($address, $cross, $city, $q_link, $url_redirect);
        if ( $q_location ) {

            &write_log("Creating Google Maps html link\n");

            $address = URI::Escape::uri_escape( &trim( $q_location ) );

            my ($content, $uri_str);
            if ( $address ) {

                $uri_str = $address;
                $uri_str =~ s/%20/+/g;

                # Connect to the Google Map API and validate the address
                &write_log("Validating address [ $uri_str ] against Google Maps Geocoding API\n");
                $content = LWP::Simple::get("http://maps.google.com/maps/api/geocode/xml?address=$uri_str&sensor=false");
            }

            if ( $content ) {

                my $xp = XML::XPath->new(
                    xml => $content
                );

                my $stat = $xp->findvalue("//status");
                if ( $stat eq 'OK' ) {

                    my ($address, $lat, $lng, $filtered);
                    my $results = $xp->find("//result");

                    &write_log("Address validation was successful, " . $results->size . " result(s) returned\n");

                    if ( $results->size > 1 && $self->{'regex_county'} ) {

                        &write_log("Filtering multi-row result set\n");
                        my $i;
                        for ( $i = 1; $i <= $results->size; $i++ ) {

                            if ( $xp->findvalue("/GeocodeResponse/result[$i]/address_component[type/text()='administrative_area_level_2']/long_name") =~ /$self->{regex_county}/i ) {

                                $address = $xp->findvalue("//result[$i]/formatted_address/text()");
                                $lat = $xp->findvalue("//result[$i]//location/lat");
                                $lng = $xp->findvalue("//result[$i]//location/lng");
                                $filtered = 1;

                                last;
                            }
                        }
                    }

                    my $map_link;

                    if ( $results->size == 1 || ! $filtered ) {

                        &write_log("Unable to identify valid address from multi-result set, defaulting to first result\n", 1) if ( $results->size > 1 );

                        $address = $xp->findvalue("//result[1]/formatted_address/text()");
                        $lat = $xp->findvalue("//result[1]//location/lat");
                        $lng = $xp->findvalue("//result[1]//location/lng");
                    }

                    if ( $lat && $lng ) {

                        &write_log("Assigning geocode address: $address\n");
                        &write_log("Assigning geocode Lat/Long coords: $lat, $lng\n");

                        $uri_str = "$lat,$lng";
                        $map_link = "http://maps.google.com/?q=$uri_str&f=q&hl=en&ie=UTF8";

                        if ( $self->{'data'} && $geocodeRegexLoc && $geocodeRegexAddr ) {

                            $location =~ s/$geocodeRegexAddr/<a href="$map_link">$location<\/a>/;

                            &write_log("Writing map hyperlink $map_link into incident location\n");
                            $self->{'data'} =~ s/$geocodeRegexLoc/LOCATION: $location/ms;

                        }

                        &write_log("Unable to write map hyperlink into incident location: " . ( ! $geocodeRegexAddr ? "Missing geocode address regex modifier. " : undef ) . ( ! $geocodeRegexLoc ? "Missing geocode location regex modifier. " : undef ) . "\n", 1) if ( ! $geocodeRegexAddr || ! $geocodeRegexLoc);

                        # Create the URL redirector
                        my $url_key;
                        &write_log("Creating URL redirector to Google map reference\n");

                        my $sth = $self->{'dbh'}->prepare( qq{
                            SELECT ( MIN(url_key) + 1 ) AS f
                            FROM (
                                SELECT DISTINCT t0.url_key, t1.url_key AS number_plus_one
                                FROM url_redirect AS t0
                                LEFT JOIN url_redirect AS t1 ON ( t0.url_key + 1 ) = t1.url_key
                            ) AS temp1
                            WHERE ISNULL( number_plus_one )
                        } );

                        if ( $sth->execute ) {

                            my $array_ref = $sth->fetchall_arrayref( [ 0 ] );

                            $url_key = @{ $array_ref }[0]->[0] if ( @$array_ref );
                            $url_key = 0 if ( ! $url_key );

                        }

                        if ( defined $url_key && $url_key >= 0 ) {

                            $url_redirect = "http://fhwm.net/r/$url_key";

                            my $sth = $self->{'dbh'}->prepare(  qq{
                                INSERT INTO url_redirect
                                VALUES( ?, ?, NOW(), ?, ? )
                            } );

                            unless ( $sth->execute( $url_redirect, $url_key, $self->{'license'}, $map_link ) ) {

                                &write_log("Database Insert Error: $DBI::errstr \n");
                                undef $url_redirect;
                            }

                            &write_log("URL redirector created $url_redirect \n") if ( $url_redirect );
                        }

                        # Delete from the url redirect table older than archive_days
                        &write_log("Purging redirector table of rows older than $self->{archive_days} days\n");

                        my $sth = $self->{'dbh'}->prepare( qq{
                            DELETE FROM url_redirect
                            WHERE DATEDIFF( NOW(), url_redirect.datetime ) >= ?
                        } )->execute( $self->{'archive_days'} );
                    }

                } else {

                    &write_log("Unable to validate address, no results found\n") if ( $stat eq 'ZERO_RESULTS' );
                    &write_log("Malformed or missing address, request was invalid\n", 1) if ( $stat eq 'INVALID_REQUEST' );
                    &write_log("Client connection abuse reported by Google API, aborting\n", 1) if ( $stat eq '620' );
                }

            } else {

                &write_log("HTTP request failed, unable to map incident location", 1);
            }
        }

        if ( $self->{'data'} ) {

            &write_log("Looking up incident $self->{inc_no} for previous symlink\n");

            my $sth = $self->{'dbh'}->prepare(qq{
                SELECT symlink
                FROM notification
                WHERE license_no = ? AND inc_no = ?
            });

            if ( $sth->execute( $self->{'license'}, $self->{'inc_no'} ) ) {

                my $array_ref = $sth->fetchall_arrayref( [ 0 ] );

                $symlink = @{ $array_ref }[0]->[0] if ( @$array_ref );

                if ( ! $symlink ) {

                    &write_log("No previous incidents found, generating symlink\n");

                    $symlink = 0;
                    do {
                        $symlink++;
                    } until ( ! -f "$file_path/$symlink" );

                } else {

                    &write_log("Previous incident found\n");
                    $prev_inc = 1;
                }

                &write_log("Assigning symlink: $symlink => $self->{inc_no} \n");
            }

            &write_log("Writing incident data to file $self->{inc_no}\n");
            if ( open(FH, ">" . $file_path . '/' . $self->{'inc_no'} ) ) {

                print FH $self->{'data'};
                close FH;

                my $symlink_res;

                if ( $symlink ) {

                    if ( -f "$file_path/$symlink" ) {

                        $symlink_res = 1;
                        &write_log("Symlink exists from previous incident - Assigning symlink $symlink \n");

                        my $link = "http://fhwm.net/$self->{uri}/$symlink";

                        &write_log("Appending SMS link [ $link ] to SMTP message\n");
                        $self->{'message'} .= " $link";

                    } else {

                        &write_log("Writing SMS web view symlink [ $file_path/$symlink ] \n");
                        my $symlink_res = eval { symlink( "$file_path/$self->{inc_no}", "$file_path/$symlink" ); 1 };
                        if ( $symlink_res ) {

                            my $link = "http://fhwm.net/$self->{uri}/$symlink";

                            &write_log("Appending SMS link [ $link ] to SMTP message\n");
                            $self->{'message'} .= " $link";
                        }
                        &write_log("Error writing symlink: $@ \n", 1) if ( ! $symlink_res );
                    }
                }

                my $cmd = "find $file_path/* -mtime +$self->{archive_days} -exec rm {} \\;";
                my $out = `$cmd`;

                &write_log("Removing incident files older than $self->{archive_days} days old [ $cmd ] \n");
                &write_log("Command output was: $out \n") if $DEBUG;
                &write_log("Error removing old incident files. Command return code was: $? \n", 1) if ( $? != 0 );

            } else {

                &write_log("Error writing to file: $@\n");
            }

        }

        if ( $url_redirect ) {

            &write_log("Appending URL redirect to message\n");
            $self->{'message'} .= " $url_redirect";
        }
    }

    return 1;
}

sub hostsync
{
    my $self = shift;
    my $params = shift;

    &write_log("Initializing Watchman HostSync service for client $self->{license}\n");

    my $client_ip = '1.2.3.4';
    my $client_node;

    my $sth = $self->{'dbh'}->prepare( qq{
        SELECT
            county_code,
            required_ipaddr,
            required_nodename
        FROM hostsync_control
        WHERE license_no = ?
    } );

    if ( $sth->execute( $self->{'license'} ) ) {

        if ( my $ref = $sth->fetchrow_hashref ) {

            my $county_code = $$ref{'county_code'};
            my $required_ipaddr = $$ref{'required_ipaddr'};
            my $required_nodename = $$ref{'required_nodename'};

			if ( ( $required_ipaddr && $required_ipaddr ne $client_ip ) || ( $required_nodename && $required_nodename ne $client_node ) ) {

				&write_log("Client IP/Nodename mismatch. Client connection not authorized.\n");
				return undef;
			}

            if ( $county_code ) {

            	&write_log("Starting HostSync update for " . ( $#{ $params->{'incident'} } + 1 ) . " incidents in county code $county_code \n");

				foreach my $_i ( @{ $params->{'incident'} } ) {

	                unless (
	                    $self->{'dbh'}->prepare( qq{
	                        REPLACE INTO incidentpoll
	                        VALUES
	                        (
	                            ?,
	                            ?,
	                            ?,
	                            ?,
	                            ?,
	                            ?,
	                            UNIX_TIMESTAMP(),
	                            ?,
	                            ?,
	                            ?,
	                            ?,
	                            ?,
	                            ?
	                        )
	                    } )->execute(
	                        $self->{'license'},
	                        $client_ip,
	                        $county_code,
	                        $_i->{'cno'},
	                        ( $_i->{'inc'} ? $_i->{'inc'} : undef ),
	                        ( $_i->{'dat'} ? $_i->{'dat'} : POSIX::strftime("%Y-%m-%d", localtime) ),
	                        $_i->{'tim'},
	                        $_i->{'ope'},
	                        ( $_i->{'clo'} ? $_i->{'clo'} : undef ),
	                        $_i->{'typ'},
	                        ( $_i->{'box'} ? $_i->{'box'} : undef ),
	                        $_i->{'loc'}
	                    )
	                ) {

	                    &write_log("HostSync host database insert error: (" . $DBI::errstr . ") " . $DBI::errstr . "\n", 1);
	                    $self->__response("HostSync host database insert error on line " . __LINE__ . ": (" . $DBI::errstr . ") " . $DBI::errstr);

	                    return undef;
	                }
				}

                &write_log("HostSync service completed successfully\n");
                return 1;
            }

	        &write_log("Failed to lookup licensee county identifier for hostsync update\n", 1);
	        $self->__response("Failed to lookup licensee county identifier for hostsync update");

	        return undef;
        }

        &write_log("Unable to lookup licensee information for hostsync update\n", 1);
        $self->__response("Unable to lookup licensee information for hostsync update");

        return undef;

    } else {

	    &write_log("Licensed user not permitted to update hostsync incidentpoll table");
	    $self->__response("Licensed user not permitted to update hostsync incidentpoll table");

	    return undef;
    }
}

sub testsoap
{
    my $self = shift;
    my $params = shift;

    &write_log("Watchman SOAP test service request\n");

	if ( $params ) {

		$self->__response("Watchman SOAP test service called with params: ");
		for my $_i ( keys %{ $params } ) {
			$self->__response("$_i => $params->{ $_i } ");
		}
	} else {

		$self->__response("Watchman SOAP test service called with no params ");
	}

	return undef;
}

sub __response
{
	my $self = shift;

    $self->{'response'} .= ( $self->{'response'} ? ", " : undef ) . $_[1];
}

1;