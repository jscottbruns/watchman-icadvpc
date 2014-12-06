package Listener::SMTP_Monroeville;

BEGIN
{
	push @INC, '/usr/local/watchman-icad/lib';

	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
	use constant DEBUG_DIR	=> '/usr/local/watchman-icad/tmp';
}

sub new
{
    my $this = shift;
	my $params = shift;

	my $class = ref($this) || $this;

	my $Dest = $params->{'Dest'};
	my $Data = $params->{'Data'};
	my $Subj = $params->{'Subj'};

	&main::log("Initiating SMTP Event Listener Module for Monroeville, PA ($Dest)");

    my ($DBH, $SQS);
	my $Config = $::Config;
	my $DEBUG = $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'Debug'};
	my $Timezone = $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'Timezone'} || $Config->{'icad'}->{'listener'}->{'Timezone'} || 'US/Eastern';

	&main::log("Opening iCAD database connection to => [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]");

	unless ( $DBH = &main::init_dbConnection( $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'DB_Name'} ) )
	{
		&main::log("Database connection error - Can't connect to iCAD database [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]", E_CRIT);
		return undef;
	}

	&main::log("Initiating SQS Queue Object");

	unless ( $SQS = new Amazon::SQS::Simple($Config->{'icad'}->{'dispatcher'}->{'sqs_access'}, $Config->{'icad'}->{'dispatcher'}->{'sqs_secret'}) )
	{
		&main::log("SQS Connection Error - Can't connect to SQS Queue [$Config->{icad}->{dispatcher}->{sqs_uri}]", E_CRIT);
		return undef;
	}

	&main::log("Fetching icad-dispatcher queue [$Config->{icad}->{dispatcher}->{sqs_uri}]");

	my $SQS_Queue = $SQS->GetQueue($Config->{'icad'}->{'dispatcher'}->{'sqs_uri'});

	my ($dt, $unixtime, $utctime, $inc_data, $inc_header, $inc_units, $inc_meta, $STH_1, $STH_2);

	if ( $DEBUG )
	{
		my ($fh, $filename) = tempfile(
			'smtpevent_XXXXXX',
			DIR		=> DEBUG_DIR,
			SUFFIX	=> '.txt'
		);

		&log("Writing SMTP event stream to temp file => $filename ", E_DEBUG);
		print $fh $Data;
		close $fh;
	}

	my $dispatch = [];

	if ( $Data =~ /^ALRM LVL/ )
	{
        &main::log("Event data match, checking for valid incident data");
        &main::log("Raw message dump: $eventdata", E_DEBUG) if $DEBUG;

        # Main parsing regex rule
		if ( $Data =~ /^ALRM LVL:\s([0-9])\nLOC:\s(.*?)\nBTWN:\s(.*?)\s&\s(.*?)\n(.*?)CT:\s?\n(.*)$/s )
        {
        	$inc_data = {
        		'IncNo'		=> undef,
        		'Agency'	=> '195',
        		'Pri'		=> &main::trim( $1 ),
        		'Location'	=> &main::trim( $2 ),
        		'Address'	=> undef,
        		'CityCode'	=> undef,
        		'Type'		=> undef,
        		'Nature'	=> undef,
	        	'XStreet1'	=> undef,,
	        	'XStreet2'	=> undef,
	        	'Comment'	=> &main::trim( $5 ),
			    'DispId'	=> &main::trim( $6 )
        	};

        	if ( $3 && $4 )
        	{
        		$inc_data->{'CrossSt'} = "btwn " . &main::trim( $3 ) ." and " . &main::trim( $4 );
        	}
        	elsif ( $3 || $4 )
        	{
        		$inc_data->{'CrossSt'} = "near " . &main::trim( $3 ) || &main::trim( $4 );
        	}

		    $inc_units = [ 'STA5' ];

		    if ( $inc_data->{'Location'} =~ /^(.*?),\n(.*?)\n?(.*)?$/s )
		    {
			    $inc_data->{'Location'} = &main::trim( $1 );
			    $inc_data->{'Address'} = &main::trim( $2 );
			    $inc_data->{'CityCode'} = &main::trim( $3 );
		    }

		    $inc_data->{'Address'} = "$inc_data->{Address}, $inc_data->{CityCode}" if $inc_data->{'CityCode'};

		    if ( $inc_data->{'Comment'} =~ /^(.*?)\n{1,}COM:\n(.*)$/s )
		    {
		    	$inc_data->{'Comment'} = &main::trim( $1 ) . ' - ' . &main::trim( $2 );
		    }

		    if ( $Subj =~ /^\(Alert:\s(.*?)\)$/ )
		    {
		    	$inc_data->{'Type'} = $inc_data->{'Nature'} = &main::trim( $1 );
		    }

            &main::log("Valid incident event data found in message body");
            &main::log("Formatted message dump: [Subject] => $Subj [EventData] => $Data", E_DEBUG) if $DEBUG;

			&main::log("Adding call event: [CallNo] => $inc_data->{IncNo} [EventType] => " . ( @{ $inc_units } ? 'DISP' : 'ENTRY' ) . " [CallType] => [Nature] => $inc_data->{Type} [Nature] => $inc_data->{Nature} [Location] => $inc_data->{Location} [Address] => $inc_data->{Address} [CrossSts] => $inc_data->{CrossSt} [Dist] => $inc_data->{Dist} [BoxArea] => $inc_data->{Box} [UTCTime] => $inc_data->{UTCTime} [EpochTime] => $inc_data->{UnixTime} [Comment] => $inc_data->{Narr}");

			&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert") if $DEBUG;

			eval {
				$STH_1 = $DBH->run( sub {
					return $_->prepare( qq{
						INSERT INTO CALLEVENT
						VALUES (
							NULL, # CallNo
							CURRENT_TIMESTAMP(), # CreatedTimestamp
							NULL, # Timestamp
							CURRENT_TIMESTAMP(), # EventTime
							1, # EventType
							?, # Agency
	                        ?, # DispatchId
							?, # Type
							?, # Nature
							?, # Priority
							?, # Location
							?, # LocationAddress
							?, # CrossStreets
							?, # District
							?, # Box
							?, # RadioId
							?, # GPSLat
							?, # GPSLng
							?  # Comment
						)

					} );
				} )
			};

			if ( my $ex = $@ )
			{
				&main::log("[$inc_data->{IncNo}] Database exception received while preparing statement for call event entry " . &ex( $ex ), E_CRIT);
			}
        }
        else
        {
            &main::log("Failed to parse message body, unable to parse incident values [$eventdata]", E_CRIT);
            return undef;
        }

		if ( $STH_1 )
		{
			&main::log("Inserting new call event: [CallNo] => $inc_data->{IncNo} [EventTime] => $inc_data->{UTCTime}");

			eval {
			    $STH_1->execute(
					$inc_data->{'Agency'},
                    $inc_data->{'DispId'},
					$inc_data->{'Type'},
					$inc_data->{'Nature'},
					$inc_data->{'Pri'},
					$inc_data->{'Location'},
					$inc_data->{'Address'},
					$inc_data->{'CrossSt'},
					$inc_data->{'Dist'},
					$inc_data->{'Box'},
					$inc_data->{'RadioId'},
					$inc_data->{'GPSLat'},
					$inc_data->{'GPSLng'},
					$inc_data->{'Narr'}
				)
			};

			if ( my $ex = $@ )
			{
				&main::log("[$inc_data->{IncNo}] iCAD database exception received during call event execution " . &ex( $ex ), E_CRIT);
			}

			if ( my $_incno = $DBH->selectrow_hashref("SELECT LAST_INSERT_ID() AS NotifyId") )
			{
				$inc_data->{'IncNo'} = $_incno->{'NotifyId'};

				my $_inctime = $DBH->selectrow_hashref("SELECT EventTime FROM CALLEVENT WHERE CallNo = $inc_data->{'IncNo'}");
				$inc_data->{'EventTime'} = $_inctime->{'EventTime'};
			}
		}
		else
		{
			&main::log("[$inc_data->{IncNo}] Unable to execute new event insert without sth handle", E_CRIT);
		}

        if ( @{ $inc_units } )
        {
		    &main::log("Adding (" . scalar @{ $inc_units } . ") new call unit event(s) for [CallNo] => $inc_data->{IncNo}");

			&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert") if $DEBUG;

			eval {
				$STH_2 = $DBH->run( sub {
					return $_->prepare( qq{
						INSERT INTO CALLUNITEVENT
						VALUES (
							?, # CallNo
							?, # UnitId
							CURRENT_TIMESTAMP(), # CreatedTimestamp
							NULL, # Timestamp
							?, # DispatchTime
							NULL  # AlertTrans
						)
					} );
				} )
			};

			if ( my $ex = $@ )
			{
				&main::log("[$inc_data->{IncNo}] Database exception received while preparing statement for call unit event insert " . &ex( $ex ), E_ERROR);
			}

			if ( $STH_2 )
			{
                foreach my $_u ( @{ $inc_units } )
                {
                    &main::log("Inserting call unit event [CallNo] => $inc_data->{IncNo} [UnitID] => " . &main::trim( $_u ) . " [DispTime] => $inc_data->{UTCTime}");

			        eval
			        {
				        $STH_2->execute(
					        $inc_data->{'IncNo'},
					        &main::trim( $_u ),
                            $inc_data->{'EventTime'}
				        );

				        push @{ $dispatch }, {
				        	EventNo		=> '',
				        	IncNo		=> $inc_data->{'IncNo'},
				        	DispTime	=> $inc_data->{'EventTime'},
				        	Unit		=> &main::trim( $_u )
				        } if $STH_2->rows == 1;
			        };

			        if ( my $ex = $@ )
			        {
				        &main::log("[$inc_data->{IncNo}] iCAD database exception received during call unit event execution " . &ex( $ex ), E_CRIT);
			        }
                }

				eval {
					$DBH->run( sub {
						$_->commit;
					} )
				};

				if ( my $ex = $@ )
				{
					&main::log("iCAD database exception received during unit detail commit " . &main::ex( $ex ), E_CRIT);
					eval { $DBH->rollback };
				}
            }
		    else
		    {
		    	&main::log("[$inc_data->{IncNo}] Unable to execute new call unit event insert without sth handle", E_CRIT);
		    }
        }

		&main::log("Finished processing incident call event");
		return 1;
	}
    else
	{
        &main::log("Unable to parse message payload, failed to perform regexp check", E_CRIT);
        return undef;
    }

    return 1;
}

sub ex
{
    my $ex = shift;
    my $err = $ex->error;
    my $state = $ex->state;

    $err =~ s/\n//g;
    $err =~ s/\s{3,}/ /g;

    return ( $ex->can('error') ? "($state) $err" : $ex );
}
1;