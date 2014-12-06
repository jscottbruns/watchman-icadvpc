package Listener::SMTP_PGMD;

BEGIN
{
	use constant E_ERROR	=> 'error';
	use constant E_WARN		=> 'warn';
	use constant E_CRIT		=> 'critical';
	use constant E_DEBUG	=> 'debug';
	use constant E_INFO		=> 'info';
}

sub new
{
    my $this = shift;
	my $params = shift;

	my $class = ref($this) || $this;

	my $Dest = $params->{'Dest'};
	my $Data = $params->{'Data'};

	&main::log("Initiating SMTP Event Listener Module for Prince George's County, MD ($Dest)");
    
    my $DBH;
	my $Config = $::Config;
	my $Debug = $::DEBUG;
	my $Timezone = $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'Timezone'} || $Config->{'icad'}->{'listener'}->{'Timezone'} || 'US/Eastern';
	
	&main::log("Initiating iCAD database connection to => [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]");
	
	unless ( $DBH = &main::init_dbConnection( $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'DB_Name'} ) )
	{
		&main::log("Database connection error - Can't connect to iCAD database [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]", E_CRIT);
		return undef;		
	}
	
	my ($dt, $unixtime, $utctime, $inc_data, $inc_header, $inc_units, $inc_meta, $STH_1, $STH_2);
	
	if ( $Data =~ /^(.*):\s+(.*?),\s+(.*?),(?:\s+([a-zA-Z]{2}),)?(?:\s+((?:at|btwn\s+)?.*?),)?\s+(T[ABCDEGL|1234567890]*),\s+([0-9A-Z]{2,}),\s+Unit(?:s)?:(.*)/ )
	{
		$inc_data = {
			'Agency'	=> undef,
			'DispId'	=> undef,
			'IncNo'		=> &main::trim($1),
			'Nature'	=> &main::trim($2),
			'Pri'		=> undef,
			'Address'	=> &main::trim($3),
			'Apt'		=> undef,
			'Location'	=> &main::trim($5),
			'CrossSt'	=> undef,
			'CityCode'	=> &main::trim($4),
			'RadioId'	=> &main::trim($6),
			'Box'		=> &main::trim($7),
			'District'	=> undef,
			'GPSLat'	=> undef,
			'GPSLng'	=> undef,
			'Narr'		=> undef			
		};
		
		$inc_units = [ split ',', &main::trim($8) ];
	
		if ( $inc_data->{'Address'} =~ /^(.*?)\s?#(.*)$/ )
		{
			$inc_data->{'Apt'} = &main::trim( $2 );	
		} 
		
	    if ( $inc_data->{'Location'} =~ /^(btwn\s.*?\sand\s.*)$/ )
	    {
	    	$inc_data->{'Location'} = $inc_data->{'Address'};
	        $inc_data->{'CrossSt'} = &main::trim($1);
	    }                        		

		&main::log("[$inc_data->{IncNo}] Adding new call event NATURE => [$inc_data->{Nature}] ADDR => [$inc_data->{Address}] APT => [$inc_data->{Apt}] LOC => [$inc_data->{Location}] XSTREET => [$inc_data->{CrossSt}] BOX => [$inc_data->{Box}] UNITS => [" . join(',', @{ $inc_units }) . "]");  
				
		&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert");
				
		eval {
			$STH_1 = $DBH->run( sub {
				return $_->prepare( qq{
					INSERT INTO CALLEVENT
					VALUES (
						?, # CallNo
						CURRENT_TIMESTAMP(), # CreatedTimestamp
						NULL, # Timestamp
						CURRENT_TIMESTAMP(), # EventTime
						?, # EventType
						?, # Agency
                        ?, # DispatchId
						?, # Type
						?, # Nature
						?, # Priority
						?, # Location
						?, # LocationAddress
						?, # CityCode
						?, # CrossStreets
						?, # District
						?, # Box
						?, # RadioId
						?, # GPSLat
						?, # GPSLng
						?  # Comment
					)
					ON DUPLICATE KEY UPDATE
						Type = ?,
						Nature = ?,
						Location = ?,
						LocationAddress = ?,
						CrossStreets = ?,
						Box = ?,
						RadioId = ?
				} );
			} )
		};
				
		if ( my $ex = $@ )
		{
			&main::log("[$inc_data->{IncNo}] Database exception received while preparing statement for call event entry " . &ex( $ex ), E_CRIT);	
		}	 
				   					    					
		if ( $STH_1 )
		{
			&main::log("[$inc_data->{IncNo}] Inserting new call event w/event time => [$inc_data->{UTCTime}]");
		    
			eval {
			    $STH_1->execute(
					$inc_data->{'IncNo'},
					( @{ $inc_units } ? 1 : 0 ),
					$inc_data->{'Agency'},
                    $inc_data->{'DispId'},
					$inc_data->{'Nature'},
					$inc_data->{'Nature'},
					$inc_data->{'Pri'},
					$inc_data->{'Location'},
					$inc_data->{'Address'},
					$inc_data->{'CityCode'},
					$inc_data->{'CrossSt'},
					$inc_data->{'Dist'},
					$inc_data->{'Box'},
					$inc_data->{'RadioId'},
					$inc_data->{'GPSLat'},
					$inc_data->{'GPSLng'},
					$inc_data->{'Narr'},
					$inc_data->{'Nature'},
					$inc_data->{'Nature'},
					$inc_data->{'Location'},
					$inc_data->{'Address'},
					$inc_data->{'CrossSt'},
					$inc_data->{'Box'},
					$inc_data->{'RadioId'}					
				)
			};
			
			if ( my $ex = $@ )
			{
				&main::log("[$inc_data->{IncNo}] iCAD database exception received during call event execution " . &ex( $ex ), E_CRIT);
			}								
		}
		else
		{
			&main::log("[$inc_data->{IncNo}] Unable to execute new event insert without sth handle", E_CRIT);
		}
				
		if ( @{ $inc_units } )
		{
			&main::log("[$inc_data->{IncNo}] Adding (" . scalar @{ $inc_units } . ") new call unit event(s)");
				
			&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert");
						
			eval {
				$STH_2 = $DBH->run( sub {
					return $_->prepare( qq{
						INSERT INTO CALLUNITEVENT
						VALUES (
							?, # CallNo
							?, # UnitId
							CURRENT_TIMESTAMP(), # CreatedTimestamp
							CURRENT_TIMESTAMP(), # Timestamp						
							CURRENT_TIMESTAMP(), # DispatchTime
							NULL  # AlertTrans					
						)
						ON DUPLICATE KEY UPDATE
							Timestamp = CURRENT_TIMESTAMP()
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
					&main::log("[$inc_data->{IncNo}] Inserting new call unit event UnitID => [" . &main::trim( $_u ) . "] DispTime => [$inc_data->{UnixTime}] UTCTime => [$inc_data->{UTCTime}]");

					eval {
						$STH_2->execute(
							$inc_data->{'IncNo'},
							&main::trim( $_u )
						)
					};
					        
					if ( my $ex = $@ )
					{
						&main::log("[$inc_data->{IncNo}] iCAD database exception received during call unit event execution " . &ex( $ex ), E_CRIT);
					}
				}
			}
			else
		    {
		    	&main::log("[$inc_data->{IncNo}] Unable to execute new call unit event insert without sth handle", E_CRIT);	
			}
		}
		
		&main::log("Finished processing call event");
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