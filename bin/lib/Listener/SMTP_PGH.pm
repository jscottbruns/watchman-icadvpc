package Listener::SMTP_PGH;

BEGIN
{
	push @INC, '/usr/local/watchman-icad/lib';

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

	&main::log("Initiating SMTP Event Listener Module for Allegheny County, PA ($Dest)");

	my $DBH;
	my $Config = $::Config;
	my $DEBUG = $::DEBUG;

	my $Timezone = $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'Timezone'} || $Config->{'icad'}->{'listener'}->{'Timezone'} || 'US/Eastern';

	&main::log("Opening iCAD database connection to => [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]");

	unless ( $DBH = &main::init_dbConnection( $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'DB_Name'}, $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'DB_Flags'} ) )
	{
		&main::log("Database connection error - Can't connect to iCAD database [$Config->{icad}->{listener}->{destination}->{ $Dest }->{DB_Name}]", E_CRIT);
		return undef;
	}

	my ($dt, $unixtime, $utctime, $inc_data, $inc_header, $inc_units, $inc_meta, $STH_1, $STH_2);

	if ( $Data =~ /^\:(.*)/ )
	{
		my $eventdata = $1;

		&main::log("Event data match, checking for valid incident data");
		&main::log("Raw message dump: $eventdata", E_DEBUG) if $DEBUG;

		if ( $eventdata =~ /^(.*?)(?:Unit(?:s)?:(.*?))?\s-\sFrom\s(.*?)\s(.*?)\s(.*)$/ )
		{
			$inc_header = &main::trim( $1 );
			$inc_units = [ split ',', &main::trim( $2 ) ];
			$inc_data->{'DispId'} = &main::trim( $3 );
			$inc_data->{'IncDate'} = &main::trim( $4 );
			$inc_data->{'IncTime'} = &main::trim( $5 );

			&main::log("Valid incident event data found in message body");
			&main::log("Formatted message dump: [HEAD] => $inc_header [UNIT] => " . join(',', @{ $inc_units }) . " [DATE] => $inc_data->{IncDate} [TIME] => $inc_data->{IncTime} [DISP_ID] => $inc_data->{DispId}", E_DEBUG) if $DEBUG;
		}
		else
		{
			&main::log("Failed to parse message body, unable to parse incident values [$eventdata]", E_CRIT);
			return undef;
		}

		my $ts = "$inc_data->{IncDate} $inc_data->{IncTime}";

		&main::log("Parsing local timestamp [$ts] against timezone [$Timezone]");

		if ( $ts =~ /^([\d]{2})\/([\d]{2})\/([\d]{4})\s([\d]{2}):([\d]{2}):([\d]{2})$/ )
		{
			$dt = DateTime->new(
				year            => $3,
				month           => $1,
				day             => $2,
				hour            => $4,
				minute          => $5,
				second          => $6,
				nanosecond      => 0,
				time_zone       => $Timezone
			);

			$dt->set_time_zone('UTC');

			$unixtime = $dt->epoch();
			$utctime = $dt->datetime();

			&main::log("Setting UTC Timestamp: [UTC]=>$utctime [EPOCH]=>$unixtime") if $DEBUG;
		}
		else
		{
			&main::log("Failed to parse local timestamp [$ts]", E_CRIT);
		}

		my $sqs_notifier = [];
		my $sqs_dispatcher = [];

		if ( $inc_header =~ /^(.*?),\s(.*?),\s(.*?),\s(.*)$/ )
		{
			my $otherinfo = &main::trim( $4 );

			$inc_data = {
				'Type'		=> &main::trim( $1 ),
				'Pri'		=> &main::trim( $2 ),
				'Nature'	=> &main::trim( $3 )
			};

			if ( $otherinfo =~ /^(.*?),\s([A-Z]{3}),\s(?:(at\s.*?)?,\s)?(?:(btwn\s.*?)?,\s)?(CFD[1-4])?,\s(231-[0-9]{2,})?,\s(F[0-9]{9}),\s(.*)$/ )
			{
				$inc_data->{'Agency'} = $Config->{'icad'}->{'listener'}->{'destination'}->{ $Dest }->{'Agency'};
				$inc_data->{'Location'} = &main::trim( $1 );
				$inc_data->{'CityCode'} = &main::trim( $2 );
				$inc_data->{'Address'} = &main::trim( $3 ) || $inc_data->{'Location'};
				$inc_data->{'CrossSt'} = &main::trim( $4 );
				$inc_data->{'Dist'} = &main::trim( $5 );
				$inc_data->{'Box'} = &main::trim( $6 );
				$inc_data->{'IncNo'} = &main::trim( $7 );
				$inc_data->{'Narr'} = &main::trim( $8 );
				$inc_data->{'UnixTime'} = $unixtime;
				$inc_data->{'UTCTime'} = $utctime;

				&main::log("Adding call event: [CallNo] => $inc_data->{IncNo} [EventType] => " . ( @{ $inc_units } ? 'DISP' : 'ENTRY' ) . " [CallType] => [Nature] => $inc_data->{Type} [Nature] => $inc_data->{Nature} [Location] => $inc_data->{Location} [Address] => $inc_data->{Address} [CrossSts] => $inc_data->{CrossSt} [Dist] => $inc_data->{Dist} [BoxArea] => $inc_data->{Box} [UTCTime] => $inc_data->{UTCTime} [EpochTime] => $inc_data->{UnixTime} [Comment] => $inc_data->{Narr}");

				&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert") if $DEBUG;

				$STH_1 = $DBH->run( sub {
					return $_->prepare( qq{
						INSERT INTO CALLEVENT
						VALUES (
							?, # CallKey (Auto increment value unless already defined)
							?, # CallNo
							CURRENT_TIMESTAMP(), # CreatedTimestamp
							DEFAULT, # Timestamp
							?, # EventTime
							?, # EventType
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
						ON DUPLICATE KEY UPDATE
							EventType = ?,
							Type = ?,
							Nature = ?,
							Priority = ?,
							Location = ?,
							LocationAddress = ?,
							CrossStreets = ?,
							District = ?,
							Box = ?,
							RadioId = ?,
							GPSLatitude = ?,
							GPSLongitude = ?,
							Comment = ?

					} );
				} ) unless $STH_1;

				&main::log("Inserting new call event: [CallNo] => $inc_data->{IncNo} [EventTime] => $inc_data->{UTCTime}");

				eval
				{
					$STH_1->execute(
						( defined $inc_data->{'CallKey'} ? $inc_data->{'CallKey'} : undef ),
						$inc_data->{'IncNo'},
						$inc_data->{'UTCTime'},
						( @{ $inc_units } ? 1 : 0 ),
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
						$inc_data->{'Narr'},
						( @{ $inc_units } ? 1 : 0 ),
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
					);

					$inc_data->{'CallKey'} = $DBH->{'mysql_insertid'} unless defined $inc_data->{'CallKey'};

					if ( $STH_1->rows > 0 && ! @{ $inc_units } )
					{
						push @{ $sqs_notifier }, {
							EventNo		=> $inc_data->{'CallKey'},
							EventTime	=> $inc_data->{'UTCTime'},
							EventType	=> $STH_1->rows
						};
					}
				};

				if ( my $ex = $@ )
				{
					&main::log("[$inc_data->{IncNo}] iCAD database exception received during call event processing " . &ex( $ex ), E_CRIT);
				}

				eval
				{
					&main::log("Committing database transaction for incident [$CallKey]", E_DEBUG) if $self->{'DEBUG'};

					$DBH->commit;
				};

				if ( my $ex = $@ )
				{
					&main::log("iCAD database exception received during call event commit " . &main::ex( $ex ), E_CRIT);
				}

				if ( @{ $sqs_notifier } )
				{
					my $msg_id = &main::sqs_send(
						'notifier',
						{
							EventNo		=> $inc_data->{'CallKey'},
							EventRef	=> $sqs_notifier
						}
					) or &main::log("Errors received during SQS message processing", E_CRIT);

					&main::log("Submitted incident [$CallKey] to SQS notifier queue - MSG_ID => [$msg_id]") if $msg_id;
				}

				if ( @{ $inc_units } )
				{
					&main::log("Adding (" . scalar @{ $inc_units } . ") new call unit event(s) for [CallNo] => $inc_data->{IncNo}");

					&main::log("[$inc_data->{IncNo}] Preparing statement handle for CALLEVENT record insert") if $DEBUG;

					$STH_2 = $DBH->run( sub {
						return $_->prepare( qq{
							INSERT INTO CALLUNITEVENT
							VALUES (
								?, # CallKey
								CURRENT_TIMESTAMP(), # CreatedTimestamp
								DEFAULT, # Timestamp
								?, # UnitId
								?, # DispatchTime
								DEFAULT # AlertTrans
							)
							ON DUPLICATE KEY UPDATE
								DispatchTime = ?
						} );
					} ) unless $STH_2;

					foreach my $_u ( @{ $inc_units } )
					{
						$_u = &main::trim( $_u );

						&main::log("Inserting call unit event [CallNo] => $inc_data->{IncNo} [UnitID] => $_u [DispTime] => $inc_data->{UTCTime}");

						eval
						{
							$STH_2->execute(
								$inc_data->{'CallKey'},
								$_u,
								$inc_data->{'UTCTime'},
								$inc_data->{'UTCTime'}
							);

							if ( $STH_2->rows == 1 )
							{
								push @{ $sqs_dispatcher }, {
									EventTime	=> $inc_data->{'UTCTime'},
									UnitId		=> $_u
								};
								push @{ $sqs_notifier }, {
									EventTime	=> $inc_data->{'UTCTime'},
									UnitId		=> $_u,
									EventType	=> 3
								};
							}

						};

						if ( my $ex = $@ )
						{
							&main::log("[$inc_data->{IncNo}] iCAD database exception received during call unit processing " . &ex( $ex ), E_CRIT);
						}
					}

					eval
					{
						&main::log("Committing database transaction for incident [$CallKey]", E_DEBUG) if $self->{'DEBUG'};

						$DBH->commit;
					};

					if ( my $ex = $@ )
					{
						&main::log("iCAD database exception received during call unit commit " . &main::ex( $ex ), E_CRIT);
					}

					if ( @{ $sqs_dispatcher } )
					{
						my $msg_id = &main::sqs_send(
							'dispatcher',
							{
								EventNo		=> $inc_data->{'CallKey'},
								EventRef	=> $sqs_dispatcher
							}
						) or &main::log("Errors received during SQS message processing", E_CRIT);

						&main::log("Submitted incident [$CallKey] to SQS dispatcher queue - MSG_ID => [$msg_id]") if $msg_id;
					}

					if ( @{ $sqs_dispatcher } )
					{
						my $msg_id = &main::sqs_send(
							'notifier',
							{
								EventNo		=> $inc_data->{'CallKey'},
								EventRef	=> $sqs_notifier
							}
						) or &main::log("Errors received during SQS message processing", E_CRIT);

						&main::log("Submitted incident [$CallKey] to SQS notifier queue - MSG_ID => [$msg_id]") if $msg_id;
					}
				}
			}
		}

		&main::log("Finished processing incident call event");
		return 1;
	}
	elsif ( $Data =~ /^MOVE-UP(?:S)?:\s(.*?)\.\s*-\sFrom\s(.*?)\s(.*?)\s(.*)/ ) # Unit Transfers
	{
		my $STH;

		my $moves = &main::trim( $1 );
		my $disp_id = &main::trim( $2 );
		my $date = &main::trim( $3 );
		my $time = &main::trim( $4 );

		&main::log("Non-incident message received (MOVE-UPS), parsing values [$moves $disp_id $date $time]");

		my $ts = "$date $time";

		&main::log("Parsing local timestamp [$ts] against timezone [$Timezone]");

		if ( $ts =~ /^([\d]{2})\/([\d]{2})\/([\d]{4})\s([\d]{2}):([\d]{2}):([\d]{2})$/ )
		{
			$dt = DateTime->new(
				year            => $3,
				month           => $1,
				day             => $2,
				hour            => $4,
				minute          => $5,
				second          => $6,
				nanosecond      => 0,
				time_zone       => $Timezone
			);

			$dt->set_time_zone('UTC');
			$utctime = $dt->datetime();

			&main::log("Setting UTC Timestamp: [UTC]=>$utctime [EPOCH]=>$unixtime") if $DEBUG;
		}
		else
		{
			&main::log("Failed to parse local timestamp", E_CRIT);
		}

		&main::log("Preparing iCAD unit move-up statement") if $DEBUG;

		$STH = $DBH->run( sub {
			return $_->prepare( qq{
				UPDATE StationUnit
				SET
					Station = ?,
					MoveTime = ?,
					MoveId = ?
				WHERE UnitId = ?
			} );
		} ) unless $STH;

				foreach my $_m ( @{ [ split(',', $moves) ] } )
				{
					my ($unit, $loc);
					$_m =~ /^(.*?)\sto\s(.*)$/ and $unit = &trim($1) and $loc = &trim($2);

			if ( $STH )
			{
							&main::log("Updating iCAD unit move-ups: UnitID => [$unit] Location => [$loc]");

						eval {
							$STH->execute(
								$loc,
								$utctime,
												$disp_id,
												$unit
							)
						};

						if ( my $ex = $@ )
						{
							&main::log("Database exception received during unit move-up statement execution " . &ex( $ex ), E_CRIT);
								}
						}
				else
				{
					&main::log("Unable to execute unit move-up statement without sth handle", E_CRIT);
				}
				}

		&main::log("Finished processing unit transfer event");
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