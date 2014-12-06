package Controller::TiburonCARS;

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

	&main::log("Initiating Tiburon CARS/DW iCAD module");

    my $class = ref($this) || $this;
	my $self = {};

	$self = {
		sth			=> {
			eoc1		=> {
				inc_recents		=> undef
			},
			eoc2		=> {
				inc_detail		=> undef,
				inc_unit		=> undef,
				inc_narrative	=> undef
			},
			icad		=> {
				inc_detail		=> undef,
				inc_unit		=> undef,
				inc_narrative	=> undef
			},
		},
		Config		=> $::Config,
		DEBUG		=> $::DEBUG,
		DB_ICAD		=> $::DB_ICAD,
		dbh			=> {
			icad		=> undef,
			eoc1		=> undef,
			eoc2		=> undef,
		},
		DATAMAP		=> {
			Incident	=> {},
			Unit		=> {},
			Narrative	=> {}
		},
		sync_count	=> 0,
		eoc_timezone	=> $::Config->{'icad'}->{'controller'}->{'Timezone'} || 'UTC'
	};

	&main::log("Initiating iCAD database connection [$self->{Config}->{db_link}->{db_icad}->{dsn}]");

	unless ( ( $self->{'dbh'}->{'icad'} = &main::init_dbConnection('db_icad', $self->{'Config'}->{'icad'}->{'controller'}->{'DB_Flags'}) ) )
	{
		&main::log("Database connection error - Can't connect to iCAD database [$self->{Config}->{db_link}->{db_icad}->{dsn}]", E_CRIT);
		return undef;
	}

	&main::log("Initiating EOC/911 database connection (Inst#1) [$self->{Config}->{db_link}->{db_eoc}->{dsn}]");

	unless ( ( $self->{'dbh'}->{'eoc1'} = &main::init_dbConnection('db_eoc') ) )
	{
		&main::log("Database connection error - Can't connect to EOC/911 database (Inst#1) [$self->{Config}->{db_link}->{db_eoc}->{dsn}]", E_CRIT);
		return undef;
	}

	&main::log("Initiating EOC/911 database connection (Inst#2) [$self->{Config}->{db_link}->{db_eoc}->{dsn}]");

	unless ( ( $self->{'dbh'}->{'eoc2'} = &main::init_dbConnection('db_eoc') ) )
	{
		&main::log("Database connection error - Can't connect to EOC/911 database (Inst#2) [$self->{Config}->{db_link}->{db_eoc}->{dsn}]", E_CRIT);
		return undef;
	}

	&main::log("Timestamps from EOC/911 data will be converted to UTC from timezone [$self->{eoc_timezone}]");

	bless $self, $class;

	return $self;
}

sub IncidentSync
{
	my $self = shift;

	unless ( $self->{'sth'}->{'eoc1'}->{'inc_recents'} )
	{
		&main::log("[EOC1] Preparing recent incident lookup statement") if $self->{'DEBUG'};

		$self->sth_prepare( {
			'db_id'		=> 'eoc1',
			'sth_id'	=> 'inc_recents',
			'sql'		=> $self->{'Config'}->{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'RecentIncidents'}
		} );
	}

	&main::log("[EOC911] Executing Recent Incident Lookup Statement") if $self->{'DEBUG'};

	unless ( $self->{'sth'}->{'eoc1'}->{'inc_recents'} )
	{
		&main::log("[EOC911-1] Recent incident lookup statement handler returned false, unable to fetch recent incidents", E_CRIT);

		$self->{'sth'}->{'eoc1'}->{'inc_recents'} = undef;
		$self->{'dbh'}->{'eoc1'}->disconnect;

		return undef;
	}

	my ($sth_count, $sqs_dispatcher, $sqs_notifier);

	if ( $self->{'sth'}->{'eoc1'}->{'inc_recents'}->execute )
	{
		while( my $incref = $self->{'sth'}->{'eoc1'}->{'inc_recents'}->fetchrow_hashref )
		{
			my $CallKey = $incref->{'CALLKEY'};
			my $NewestEntry = $incref->{'NEWEST_ENTRY'};

			$self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastEntry'} = 0 unless $self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastEntry'}; # New Incident, not previously sync'd
			$self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastSync'} = time;

			&main::log("[$CallKey] Checking active incident entry [$NewestEntry] against last sync entry [$self->{DATAMAP}->{Incident}->{ $CallKey }->{LastEntry}]") if $self->{'DEBUG'};

			if ( $NewestEntry > $self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastEntry'} )
			{
				&main::log("[$CallKey] Recent Incident Activity Found [$NewestEntry]");

				$sth_count = 0;

				EOC_DETAIL:
				$self->sth_prepare( {
					'db_id'		=> 'eoc2',
					'sth_id'	=> 'inc_detail',
					'sql'		=> $self->{'Config'}->{'db_link'}->{'db_eoc'}->{'table'}->{'incident'}->{'sql'}->{'select'}->{'IncidentDetail'}
				} ) unless $self->{'sth'}->{'eoc2'}->{'inc_detail'};

				unless ( $self->{'sth'}->{'eoc2'}->{'inc_detail'} )
				{
					$sth_count++;
					&main::log("[EOC911-2] Incident detail lookup statement handler returned false, unable to fetch incident detail", E_CRIT);

					$self->{'sth'}->{'eoc2'}->{'inc_detail'} = undef;
					$self->{'dbh'}->{'eoc2'}->disconnect;

					if ( $sth_count < 3 )
					{
						&main::log("[EOC911-2] Retrying incident detail lookup after $sth_count unsuccessful attempt(s)", E_ERROR);
						goto EOC_DETAIL;
					}

					goto UNIT_SYNC;
				}

				if ( $self->{'sth'}->{'eoc2'}->{'inc_detail'}->execute( $CallKey ) )
				{
					$self->sth_prepare( {
						'db_id'		=> 'icad',
						'sth_id'	=> 'inc_detail',
						'sql'		=> qq{
							INSERT INTO $self->{DB_ICAD}.CARSCALL
							VALUES
							(
								?, # CALLKEY
								?, # SQL Server TS
								CURRENT_TIMESTAMP(),
								?, # AGENCY
								?, # SERVICE
								?, # CALL_NO
								?, # DUPLICATED_TO_CALL_NO
								?, # POLICE_ASSC_CALL_NO
								?, # FIRE_ASSC_CALL_NO
								?, # EMS_ASSC_CALL_NO
								?, # REPORT_NO
								?, # CALL_TYPE_ORIG
								?, # CALL_TYPE_ORIG_D
								?, # CALL_TYPE_FINAL
								?, # CALL_TYPE_FINAL_D
								?, # PRIORITY
								?, # DISPOSITION
								?, # PRIMARY_UNIT
								?, # BEAT_OR_STATION
								?, # CURR_DGROUP
								?, # GEOGRAPHIC_AREA
								?, # REP_DIST
								?, # LOCATION
								?, # LOCATION_ADDRESS
								?, # LOCATION_INFO
								?, # XCOORD
								?, # YCOORD
								?, # APARTMENT
								?, # CITY_CODE
								?, # CITY_NAME
								?, # COMP_NAME
								?, # COMP_PHONE
								?, # COMP_ADDRESS
								?, # MAP_PAGE
								?, # HAZARD
								?, # PRIORS
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_CREATED_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_ENTRY_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_DISPATCH_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_ENROUTE_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_ONSCENE_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_CLOSE_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # CALL_GEOXCOORD
								ConvertEocTime(?, '$self->{eoc_timezone}') # CALL_GEOYCOORD
							)
							ON DUPLICATE KEY UPDATE
								AGENCY = ?,
								DUPLICATED_TO_CALL_NO = ?,
								POLICE_ASSC_CALL_NO = ?,
								FIRE_ASSC_CALL_NO = ?,
								EMS_ASSC_CALL_NO = ?,
								REPORT_NO = ?,
								CALL_TYPE_ORIG = ?,
								CALL_TYPE_ORIG_D = ?,
								CALL_TYPE_FINAL = ?,
								CALL_TYPE_FINAL_D = ?,
								PRIORITY = ?,
								DISPOSITION = ?,
								PRIMARY_UNIT = ?,
								BEAT_OR_STATION = ?,
								CURR_DGROUP = ?,
								GEOGRAPHIC_AREA = ?,
								REP_DIST = ?,
								LOCATION = ?,
								LOCATION_ADDRESS = ?,
								LOCATION_INFO = ?,
								XCOORD = ?,
								YCOORD = ?,
								APARTMENT = ?,
								CITY_CODE = ?,
								CITY_NAME = ?,
								COMP_NAME = ?,
								COMP_PHONE = ?,
								COMP_ADDRESS = ?,
								MAP_PAGE = ?,
								HAZARD = ?,
								PRIORS = ?,
								CALL_ENTRY_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								CALL_DISPATCH_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								CALL_ENROUTE_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								CALL_ONSCENE_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								CALL_CLOSE_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								CALL_GEOXCOORD = ?,
								CALL_GEOYCOORD = ?
						}
					} ) unless $self->{'sth'}->{'icad'}->{'inc_detail'};

					$sqs_notifier = [];

					while ( my $ref = $self->{'sth'}->{'eoc2'}->{'inc_detail'}->fetchrow_hashref )
					{
						&main::log("[$CallKey] Running iCAD Incident Sync on Incident [$ref->{CALL_NO}] [$ref->{LOCATION}] [$ref->{CALL_TYPE_ORIG}]");

						eval
						{
							$self->{'sth'}->{'icad'}->{'inc_detail'}->execute(
								$CallKey,
								$ref->{'CURR_TS'},
								( defined $ref->{'AGENCY'} ? $ref->{'AGENCY'} : undef ),
								( defined $ref->{'SERVICE'} ? $ref->{'SERVICE'} : undef ),
								( defined $ref->{'CALL_NO'} ? $ref->{'CALL_NO'} : undef ),
								( defined $ref->{'DUPLICATED_TO_CALL_NO'} ? $ref->{'DUPLICATED_TO_CALL_NO'} : undef ),
								( defined $ref->{'POLICE_ASSC_CALL_NO'} ? $ref->{'POLICE_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'FIRE_ASSC_CALL_NO'} ? $ref->{'FIRE_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'EMS_ASSC_CALL_NO'} ? $ref->{'EMS_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'REPORT_NO'} ? $ref->{'REPORT_NO'} : undef ),
								( defined $ref->{'CALL_TYPE_ORIG'} ? $ref->{'CALL_TYPE_ORIG'} : undef ),
								( defined $ref->{'CALL_TYPE_ORIG_D'} ? $ref->{'CALL_TYPE_ORIG_D'} : undef ),
								( defined $ref->{'CALL_TYPE_FINAL'} ? $ref->{'CALL_TYPE_FINAL'} : undef ),
								( defined $ref->{'CALL_TYPE_FINAL_D'} ? $ref->{'CALL_TYPE_FINAL_D'} : undef ),
								( defined $ref->{'PRIORITY'} ? $ref->{'PRIORITY'} : undef ),
								( defined $ref->{'DISPOSITION'} ? $ref->{'DISPOSITION'} : undef ),
								( defined $ref->{'PRIMARY_UNIT'} ? $ref->{'PRIMARY_UNIT'} : undef ),
								( defined $ref->{'BEAT_OR_STATION'} ? $ref->{'BEAT_OR_STATION'} : undef ),
								( defined $ref->{'CURR_DGROUP'} ? $ref->{'CURR_DGROUP'} : undef ),
								( defined $ref->{'GEOGRAPHIC_AREA'} ? $ref->{'GEOGRAPHIC_AREA'} : undef ),
								( defined $ref->{'REP_DIST'} ? $ref->{'REP_DIST'} : undef ),
								( defined $ref->{'LOCATION'} ? $ref->{'LOCATION'} : undef ),
								( defined $ref->{'LOCATION_ADDRESS'} ? $ref->{'LOCATION_ADDRESS'} : undef ),
								( defined $ref->{'LOCATION_INFO'} ? $ref->{'LOCATION_INFO'} : undef ),
								( defined $ref->{'XCOORD'} ? $ref->{'XCOORD'} : undef ),
								( defined $ref->{'YCOORD'} ? $ref->{'YCOORD'} : undef ),
								( defined $ref->{'APARTMENT'} ? $ref->{'APARTMENT'} : undef ),
								( defined $ref->{'CITY_CODE'} ? $ref->{'CITY_CODE'} : undef ),
								( defined $ref->{'CITY_NAME'} ? $ref->{'CITY_NAME'} : undef ),
								( defined $ref->{'COMP_NAME'} ? $ref->{'COMP_NAME'} : undef ),
								( defined $ref->{'COMP_PHONE'} ? $ref->{'COMP_PHONE'} : undef ),
								( defined $ref->{'COMP_ADDRESS'} ? $ref->{'COMP_ADDRESS'} : undef ),
								( defined $ref->{'MAP_PAGE'} ? $ref->{'MAP_PAGE'} : undef ),
								( defined $ref->{'HAZARD'} ? $ref->{'HAZARD'} : undef ),
								( defined $ref->{'PRIORS'} ? $ref->{'PRIORS'} : undef ),
								$ref->{'CALL_CREATED_INT'},
								( defined $ref->{'CALL_ENTRY_INT'} ? $ref->{'CALL_ENTRY_INT'} : 0 ),
								( defined $ref->{'CALL_DISPATCH_INT'} ? $ref->{'CALL_DISPATCH_INT'} : 0 ),
								( defined $ref->{'CALL_ENROUTE_INT'} ? $ref->{'CALL_ENROUTE_INT'} : 0 ),
								( defined $ref->{'CALL_ONSCENE_INT'} ? $ref->{'CALL_ONSCENE_INT'} : 0 ),
								( defined $ref->{'CALL_CLOSE_INT'} ? $ref->{'CALL_CLOSE_INT'} : 0 ),
								( defined $ref->{'CALL_GEOXCOORD'} ? $ref->{'CALL_GEOXCOORD'} : undef ),
								( defined $ref->{'CALL_GEOYCOORD'} ? $ref->{'CALL_GEOYCOORD'} : undef ),
								( defined $ref->{'AGENCY'} ? $ref->{'AGENCY'} : undef ),
								( defined $ref->{'DUPLICATED_TO_CALL_NO'} ? $ref->{'DUPLICATED_TO_CALL_NO'} : undef ),
								( defined $ref->{'POLICE_ASSC_CALL_NO'} ? $ref->{'POLICE_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'FIRE_ASSC_CALL_NO'} ? $ref->{'FIRE_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'EMS_ASSC_CALL_NO'} ? $ref->{'EMS_ASSC_CALL_NO'} : undef ),
								( defined $ref->{'REPORT_NO'} ? $ref->{'REPORT_NO'} : undef ),
								( defined $ref->{'CALL_TYPE_ORIG'} ? $ref->{'CALL_TYPE_ORIG'} : undef ),
								( defined $ref->{'CALL_TYPE_ORIG_D'} ? $ref->{'CALL_TYPE_ORIG_D'} : undef ),
								( defined $ref->{'CALL_TYPE_FINAL'} ? $ref->{'CALL_TYPE_FINAL'} : undef ),
								( defined $ref->{'CALL_TYPE_FINAL_D'} ? $ref->{'CALL_TYPE_FINAL_D'} : undef ),
								( defined $ref->{'PRIORITY'} ? $ref->{'PRIORITY'} : undef ),
								( defined $ref->{'DISPOSITION'} ? $ref->{'DISPOSITION'} : undef ),
								( defined $ref->{'PRIMARY_UNIT'} ? $ref->{'PRIMARY_UNIT'} : undef ),
								( defined $ref->{'BEAT_OR_STATION'} ? $ref->{'BEAT_OR_STATION'} : undef ),
								( defined $ref->{'CURR_DGROUP'} ? $ref->{'CURR_DGROUP'} : undef ),
								( defined $ref->{'GEOGRAPHIC_AREA'} ? $ref->{'GEOGRAPHIC_AREA'} : undef ),
								( defined $ref->{'REP_DIST'} ? $ref->{'REP_DIST'} : undef ),
								( defined $ref->{'LOCATION'} ? $ref->{'LOCATION'} : undef ),
								( defined $ref->{'LOCATION_ADDRESS'} ? $ref->{'LOCATION_ADDRESS'} : undef ),
								( defined $ref->{'LOCATION_INFO'} ? $ref->{'LOCATION_INFO'} : undef ),
								( defined $ref->{'XCOORD'} ? $ref->{'XCOORD'} : undef ),
								( defined $ref->{'YCOORD'} ? $ref->{'YCOORD'} : undef ),
								( defined $ref->{'APARTMENT'} ? $ref->{'APARTMENT'} : undef ),
								( defined $ref->{'CITY_CODE'} ? $ref->{'CITY_CODE'} : undef ),
								( defined $ref->{'CITY_NAME'} ? $ref->{'CITY_NAME'} : undef ),
								( defined $ref->{'COMP_NAME'} ? $ref->{'COMP_NAME'} : undef ),
								( defined $ref->{'COMP_PHONE'} ? $ref->{'COMP_PHONE'} : undef ),
								( defined $ref->{'COMP_ADDRESS'} ? $ref->{'COMP_ADDRESS'} : undef ),
								( defined $ref->{'MAP_PAGE'} ? $ref->{'MAP_PAGE'} : undef ),
								( defined $ref->{'HAZARD'} ? $ref->{'HAZARD'} : undef ),
								( defined $ref->{'PRIORS'} ? $ref->{'PRIORS'} : undef ),
								( defined $ref->{'CALL_ENTRY_INT'} ? $ref->{'CALL_ENTRY_INT'} : 0 ),
								( defined $ref->{'CALL_DISPATCH_INT'} ? $ref->{'CALL_DISPATCH_INT'} : 0 ),
								( defined $ref->{'CALL_ENROUTE_INT'} ? $ref->{'CALL_ENROUTE_INT'} : 0 ),
								( defined $ref->{'CALL_ONSCENE_INT'} ? $ref->{'CALL_ONSCENE_INT'} : 0 ),
								( defined $ref->{'CALL_CLOSE_INT'} ? $ref->{'CALL_CLOSE_INT'} : 0 ),
								( defined $ref->{'CALL_GEOXCOORD'} ? $ref->{'CALL_GEOXCOORD'} : undef ),
								( defined $ref->{'CALL_GEOYCOORD'} ? $ref->{'CALL_GEOYCOORD'} : undef )
							);

							if ( $self->{'sth'}->{'icad'}->{'inc_detail'}->rows > 0 && ! $ref->{'CALL_DISPATCH_INT'} )
							{
								push @{ $sqs_notifier }, {
									EventNo		=> $CallKey,
									EventTime	=> $ref->{'CALL_ENTRY_INT'},
									EventType	=> $self->{'sth'}->{'icad'}->{'inc_detail'}->rows # 1=New Incident 2=Incident Update
								};
							}
						};

						if ( my $ex = $@ )
						{
							&main::log("[$CallKey] iCAD database exception received during incident detail sync " . &main::ex( $ex ), E_CRIT);
						}
					}

					eval
					{
						&main::log("Committing database transaction for incident [$CallKey]", E_DEBUG) if $self->{'DEBUG'};

						$self->{'dbh'}->{'icad'}->commit;
					};

					if ( my $ex = $@ )
					{
						&main::log("iCAD database exception received during incident detail commit " . &main::ex( $ex ), E_CRIT);
					}

					if ( @{ $sqs_notifier } )
					{
						my $msg_id = &main::sqs_send(
							'notifier',
							{
								EventNo		=> $CallKey,
								EventRef	=> $sqs_notifier
							}
						) or &main::log("Errors received during SQS message processing", E_CRIT);

						&main::log("Submitted incident [$CallKey] to SQS notifier queue - MSG_ID => [$msg_id]") if $msg_id;
					}
				}

				$sth_count = 0;

				UNIT_SYNC:
				$self->sth_prepare( {
					'db_id'		=> 'eoc2',
					'sth_id'	=> 'inc_unit',
					'sql'		=> $self->{'Config'}->{'db_link'}->{'db_eoc'}->{'table'}->{'units'}->{'sql'}->{'select'}->{'UnitDetail'}
				} ) unless $self->{'sth'}->{'eoc2'}->{'inc_unit'};

				unless ( $self->{'sth'}->{'eoc2'}->{'inc_unit'} )
				{
					$sth_count++;
					&main::log("[EOC911-2] Unit detail lookup statement handler returned false, unable to fetch unit detail", E_CRIT);

					$self->{'sth'}->{'eoc2'}->{'inc_unit'} = undef;
					$self->{'dbh'}->{'eoc2'}->disconnect;

					if ( $sth_count < 3 )
					{
						&main::log("[EOC911-2] Retrying unit detail lookup after $sth_count unsuccessful attempt(s)", E_ERROR);
						goto UNIT_SYNC;
					}

					goto NARRATIVE_SYNC;
				}

				&main::log("[$CallKey] Fetching Incident Unit Data") if $self->{'DEBUG'};

				if ( $self->{'sth'}->{'eoc2'}->{'inc_unit'}->execute( $CallKey ) )
				{
					$self->sth_prepare( {
						'db_id'		=> 'icad',
						'sth_id'	=> 'inc_unit',
						'sql'		=> qq{
							INSERT INTO $self->{DB_ICAD}.CARSCALLUNIT
							VALUES
							(
								?, # CALLKEY
								DEFAULT,
								?, # UNITKEY
								?, # UNIT_ID
								?, # CALL_NO
								ConvertEocTime(?, '$self->{eoc_timezone}'), # UNIT_DISPATCH_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # UNIT_ENROUTE_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # UNIT_ONSCENE_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'), # UNIT_PREEMPT_INT
								ConvertEocTime(?, '$self->{eoc_timezone}'),  # UNIT_CLEAR_INT
								DEFAULT
							)
							ON DUPLICATE KEY UPDATE
								UNIT_ID = ?,
								CALL_NO = ?,
								UNIT_ENROUTE_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								UNIT_ONSCENE_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								UNIT_PREEMPT_INT = ConvertEocTime(?, '$self->{eoc_timezone}'),
								UNIT_CLEAR_INT = ConvertEocTime(?, '$self->{eoc_timezone}')
						}
					} ) unless $self->{'sth'}->{'icad'}->{'inc_unit'};

					$sqs_dispatcher = [];
					$sqs_notifier = [];

					while( my $unitref = $self->{'sth'}->{'eoc2'}->{'inc_unit'}->fetchrow_hashref )
					{
						&main::log("[$CallKey] Running iCAD Unit Sync on Unit [$unitref->{UNITKEY}] [$unitref->{UNIT_ID}] ");

						eval {

							$self->{'sth'}->{'icad'}->{'inc_unit'}->execute(
								$CallKey,
								$unitref->{'UNITKEY'},
								( $unitref->{'UNIT_ID'} ? $unitref->{'UNIT_ID'} : undef ),
								( $unitref->{'CALL_NO'} ? $unitref->{'CALL_NO'} : undef ),
								$unitref->{'UNIT_DISPATCH_INT'},
								( $unitref->{'UNIT_ENROUTE_INT'} ? $unitref->{'UNIT_ENROUTE_INT'} : 0 ),
								( $unitref->{'UNIT_ONSCENE_INT'} ? $unitref->{'UNIT_ONSCENE_INT'} : 0 ),
								( $unitref->{'UNIT_PREEMPT_INT'} ? $unitref->{'UNIT_PREEMPT_INT'} : 0 ),
								( $unitref->{'UNIT_CLEAR_INT'} ? $unitref->{'UNIT_CLEAR_INT'} : 0 ),
								( $unitref->{'UNIT_ID'} ? $unitref->{'UNIT_ID'} : undef ),
								( $unitref->{'CALL_NO'} ? $unitref->{'CALL_NO'} : undef ),
								( $unitref->{'UNIT_ENROUTE_INT'} ? $unitref->{'UNIT_ENROUTE_INT'} : 0 ),
								( $unitref->{'UNIT_ONSCENE_INT'} ? $unitref->{'UNIT_ONSCENE_INT'} : 0 ),
								( $unitref->{'UNIT_PREEMPT_INT'} ? $unitref->{'UNIT_PREEMPT_INT'} : 0 ),
								( $unitref->{'UNIT_CLEAR_INT'} ? $unitref->{'UNIT_CLEAR_INT'} : 0 )
							);

							if ( $self->{'sth'}->{'icad'}->{'inc_unit'}->rows == 1 && $unitref->{'UNIT_DISPATCH_INT'} )
							{
								push @{ $sqs_dispatcher }, {
									EventTime	=> $unitref->{'UNIT_DISPATCH_INT'},
									UnitId		=> $unitref->{'UNIT_ID'}
								};
								push @{ $sqs_notifier }, {
									EventTime	=> $unitref->{'UNIT_DISPATCH_INT'},
									UnitId		=> $unitref->{'UNIT_ID'},
									EventType	=> 3
								};
							}
						};

						if ( my $ex = $@ )
						{
							&main::log("[$CallKey] iCAD database exception received during unit sync [$unitref->{UNITKEY}] " . &main::ex( $ex ), E_CRIT);
						}
					}

					eval
					{
						&main::log("Committing database transaction for incident [$CallKey]", E_DEBUG) if $self->{'DEBUG'};

						$self->{'dbh'}->{'icad'}->commit;
					};

					if ( my $ex = $@ )
					{
						&main::log("iCAD database exception received during unit detail commit " . &main::ex( $ex ), E_CRIT);
					}

					if ( @{ $sqs_dispatcher } )
					{
						my $msg_id = &main::sqs_send(
							'dispatcher',
							{
								EventNo		=> $CallKey,
								EventRef	=> $sqs_dispatcher
							}
						) or &main::log("Errors received during SQS message processing", E_CRIT);

						&main::log("Submitted incident [$CallKey] to SQS dispatcher queue - MSG_ID => [$msg_id]") if $msg_id;
					}

					if ( @{ $sqs_notifier } )
					{
						my $msg_id = &main::sqs_send(
							'notifier',
							{
								EventNo		=> $CallKey,
								EventRef	=> $sqs_notifier
							}
						) or &main::log("Errors received during SQS message processing", E_CRIT);

						&main::log("Submitted incident [$CallKey] to SQS notifier queue - MSG_ID => [$msg_id]") if $msg_id;
					}
				}

				$sth_count = 0;

				NARRATIVE_SYNC:
				$self->sth_prepare( {
					'db_id'		=> 'eoc2',
					'sth_id'	=> 'inc_narrative',
					'sql'		=> $self->{'Config'}->{'db_link'}->{'db_eoc'}->{'table'}->{'narrative'}->{'sql'}->{'select'}->{'NarrativeDetail'}
				} ) unless $self->{'sth'}->{'eoc2'}->{'inc_narrative'};

				unless ( $self->{'sth'}->{'eoc2'}->{'inc_narrative'} )
				{
					$sth_count++;
					&main::log("[EOC911-2] Narrative detail lookup statement handler returned false, unable to fetch narrative detail", E_CRIT);

					$self->{'sth'}->{'eoc2'}->{'inc_narrative'} = undef;
					$self->{'dbh'}->{'eoc2'}->disconnect;

					if ( $sth_count < 3 )
					{
						&main::log("[EOC911-2] Retrying narrative detail lookup after $sth_count unsuccessful attempt(s)", E_ERROR);
						goto NARRATIVE_SYNC;
					}

					goto DATAMAP;
				}

				&main::log("[$CallKey] Fetching Incident Narrative Data w/Sequence Counter [$self->{DATAMAP}->{Incident}->{ $CallKey }->{LastEntry}]") if $self->{'DEBUG'};

				if ( $self->{'sth'}->{'eoc2'}->{'inc_narrative'}->execute( $CallKey, $self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastEntry'} ) )
				{
					$self->sth_prepare( {
						'db_id'		=> 'icad',
						'sth_id'	=> 'inc_narrative',
						'sql'		=> qq{
							INSERT INTO $self->{DB_ICAD}.CARSSEGMENTS
							VALUES
							(
								?, # CALLKEY
								CURRENT_TIMESTAMP(),
								?, # SEGMENT_NAME
								?, # SEGMENT_SEQ_CTRL
								?, # SEGMENT_CASE_NO
								?, # SEGMENT_INT
								?, # SEGMENT_TRUE_INT
								?, # SEGMENT_CALL_NO
								?, # SEGMENT_UNIT
								?, # SEGMENT_OPERATOR
								?, # SEGMENT_LOCATION
								?, # SEGMENT_CALLTYPE
								?, # SEGMENT_CALLDESC
								?, # SEGMENT_LOCINFO
								?, # SEGMENT_RP_NAME
								?, # SEGMENT_ADDRESS
								?, # SEGMENT_PHONE
								?, # SEGMENT_SOURCE
								?, # SEGMENT_CONTACT
								?, # SEGMENT_DISPOSITION *
								?, # SEGMENT_GROUP
								?, # SEGMENT_AREA
								?, # SEGMENT_PRIORITY
								?, # SEGMENT_AGENCY
								?, # SEGMENT_SERVICE *
								?, # SEGMENT_LINC_CALL *
								?, # SEGMENT_911_PHONE
								?, # SEGMENT_911_LOCATION
								?, # SEGMENT_911_CALLER
								?, # SEGMENT_911_SOURCE
								?, # SEGMENT_911_LATITUDE *
								?, # SEGMENT_911_LONGITUDE *
								?, # SEGMENT_GEOXCOORD
								?, # SEGMENT_GEOYCOORD
								?, # SEGMENT_MAPPAGE
								?, # SEGMENT_DISTRICT
								?, # SEGMENT_CROSS_STS
								?, # SEGMENT_PROQA_CLASS
								?, # SEGMENT_OPERID_LIST *
								?, # SEGMENT_OPERNAMES *
								?, # SEGMENT_INCIDENT_COMMANDER
								?, # SEGMENT_NOTIFIED
								? # SEGMENT_NARRATIVE
							)
							ON DUPLICATE KEY UPDATE
								TIMESTAMP = NOW()
						}
					} ) unless $self->{'sth'}->{'icad'}->{'inc_narrative'};

					while ( my $noteref = $self->{'sth'}->{'eoc2'}->{'inc_narrative'}->fetchrow_hashref )
					{
						&main::log("[$CallKey] Running iCAD Narrative Sync on Segment [$noteref->{SEGMENT_SEQ_CTRL}] [$noteref->{SEGMENT_NAME}] ");

						eval {
							$self->{'sth'}->{'icad'}->{'inc_narrative'}->execute(
								$CallKey,
								( $noteref->{'SEGMENT_NAME'} ? $noteref->{'SEGMENT_NAME'} : undef ),
								$noteref->{'SEGMENT_SEQ_CTRL'},
								( $noteref->{'SEGMENT_CASE_NO'} ? $noteref->{'SEGMENT_CASE_NO'} : undef ),
								( $noteref->{'SEGMENT_INT'} ? $noteref->{'SEGMENT_INT'} : 0 ),
								( $noteref->{'SEGMENT_TRUE_INT'} ? $noteref->{'SEGMENT_TRUE_INT'} : 0 ),
								( $noteref->{'SEGMENT_CALL_NO'} ? $noteref->{'SEGMENT_CALL_NO'} : undef ),
								( $noteref->{'SEGMENT_UNIT'} ? $noteref->{'SEGMENT_UNIT'} : undef ),
								( $noteref->{'SEGMENT_OPERATOR'} ? $noteref->{'SEGMENT_OPERATOR'} : undef ),
								( $noteref->{'SEGMENT_LOCATION'} ? $noteref->{'SEGMENT_LOCATION'} : undef ),
								( $noteref->{'SEGMENT_CALLTYPE'} ? $noteref->{'SEGMENT_CALLTYPE'} : undef ),
								( $noteref->{'SEGMENT_CALLDESC'} ? $noteref->{'SEGMENT_CALLDESC'} : undef ),
								( $noteref->{'SEGMENT_LOCINFO'} ? $noteref->{'SEGMENT_LOCINFO'} : undef ),
								( $noteref->{'SEGMENT_RP_NAME'} ? $noteref->{'SEGMENT_RP_NAME'} : undef ),
								( $noteref->{'SEGMENT_ADDRESS'} ? $noteref->{'SEGMENT_ADDRESS'} : undef ),
								( $noteref->{'SEGMENT_PHONE'} ? $noteref->{'SEGMENT_PHONE'} : undef ),
								( $noteref->{'SEGMENT_SOURCE'} ? $noteref->{'SEGMENT_SOURCE'} : undef ),
								( $noteref->{'SEGMENT_CONTACT'} ? $noteref->{'SEGMENT_CONTACT'} : undef ),
								( $noteref->{'SEGMENT_DISPOSITION'} ? $noteref->{'SEGMENT_DISPOSITION'} : undef ),
								( $noteref->{'SEGMENT_GROUP'} ? $noteref->{'SEGMENT_GROUP'} : undef ),
								( $noteref->{'SEGMENT_AREA'} ? $noteref->{'SEGMENT_AREA'} : undef ),
								( $noteref->{'SEGMENT_PRIORITY'} ? $noteref->{'SEGMENT_PRIORITY'} : undef ),
								( $noteref->{'SEGMENT_AGENCY'} ? $noteref->{'SEGMENT_AGENCY'} : undef ),
								( $noteref->{'SEGMENT_SERVICE'} ? $noteref->{'SEGMENT_SERVICE'} : undef ),
								( $noteref->{'SEGMENT_LINC_CALL'} ? $noteref->{'SEGMENT_LINC_CALL'} : undef ),
								( $noteref->{'SEGMENT_911_PHONE'} ? $noteref->{'SEGMENT_911_PHONE'} : undef ),
								( $noteref->{'SEGMENT_911_LOCATION'} ? $noteref->{'SEGMENT_911_LOCATION'} : undef ),
								( $noteref->{'SEGMENT_911_CALLER'} ? $noteref->{'SEGMENT_911_CALLER'} : undef ),
								( $noteref->{'SEGMENT_911_SOURCE'} ? $noteref->{'SEGMENT_911_SOURCE'} : undef ),
								( $noteref->{'SEGMENT_911_LATITUDE'} ? $noteref->{'SEGMENT_911_LATITUDE'} : undef ),
								( $noteref->{'SEGMENT_911_LONGITUDE'} ? $noteref->{'SEGMENT_911_LONGITUDE'} : undef ),
								( $noteref->{'SEGMENT_GEOXCOORD'} ? $noteref->{'SEGMENT_GEOXCOORD'} : undef ),
								( $noteref->{'SEGMENT_GEOYCOORD'} ? $noteref->{'SEGMENT_GEOYCOORD'} : undef ),
								( $noteref->{'SEGMENT_MAPPAGE'} ? $noteref->{'SEGMENT_MAPPAGE'} : undef ),
								( $noteref->{'SEGMENT_DISTRICT'} ? $noteref->{'SEGMENT_DISTRICT'} : undef ),
								( $noteref->{'SEGMENT_CROSS_STS'} ? $noteref->{'SEGMENT_CROSS_STS'} : undef ),
								( $noteref->{'SEGMENT_PROQA_CLASS'} ? $noteref->{'SEGMENT_PROQA_CLASS'} : undef ),
								( $noteref->{'SEGMENT_OPERID_LIST'} ? $noteref->{'SEGMENT_OPERID_LIST'} : undef ),
								( $noteref->{'SEGMENT_OPERNAMES'} ? $noteref->{'SEGMENT_OPERNAMES'} : undef ),
								( $noteref->{'SEGMENT_INCIDENT_COMMANDER'} ? $noteref->{'SEGMENT_INCIDENT_COMMANDER'} : undef ),
								( $noteref->{'SEGMENT_NOTIFIED'} ? $noteref->{'SEGMENT_NOTIFIED'} : undef ),
								( $noteref->{'SEGMENT_NARRATIVE'} ? $noteref->{'SEGMENT_NARRATIVE'} : undef )
							)
						};

						if ( my $ex = $@ )
						{
							&main::log("[$CallKey] iCAD database exception received during narrative sync [$noteref->{SEGMENT_SEQ_CTRL}] " . &main::ex( $ex ), E_CRIT);
						}
					}

					eval {
						$self->{'dbh'}->{'icad'}->commit;
					};

					if ( my $ex = $@ )
					{
						&main::log("iCAD database exception received during narrative detail commit " . &main::ex( $ex ), E_CRIT);
					}
				}

				DATAMAP:
				&main::log("[$CallKey] Setting Datamap Sequence Value [$NewestEntry] ") if $self->{'DEBUG'};
				$self->{'DATAMAP'}->{'Incident'}->{ $CallKey }->{'LastEntry'} = $NewestEntry;
			}
		}

		if ( $self->{'sync_count'} * $self->{'Config'}->{'interval'} >= 300 )
		{
			&main::log("Purging stale incidents from data map") if $self->{'DEBUG'};

			for my $_i ( keys %{ $self->{'DATAMAP'}->{'Incident'} } )
			{
				if ( time - $self->{'DATAMAP'}->{'Incident'}->{ $_i }->{'LastSync'} > 1800 )
				{
					&main::log("Purging stale incident [$_i] after inactivity " . ( time - $self->{'DATAMAP'}->{'Incident'}->{ $_i }->{'LastSync'} ) . " seconds");
					delete $self->{'DATAMAP'}->{'Incident'}->{ $_i };
				}
			}

			$self->{'sync_count'} = 0;
		}

		$self->{'sync_count'}++;
		return 1;
	}
	else
	{
		&main::log("[EOC911-1] Recent incident lookup statement execution returned false, unable to fetch recent incidents", E_CRIT);

		$self->{'sth'}->{'eoc1'}->{'inc_recents'} = undef;
		$self->{'dbh'}->{'eoc1'}->disconnect;

		return undef;
	}

	return undef;
}

sub sth_prepare
{
	my $self = shift;
	my $params = shift;

	my $sql = $params->{'sql'};
	my $sth_id = $params->{'sth_id'};
	my $db_id = $params->{'db_id'} || 'eoc1';

	eval {
		$self->{'sth'}->{$db_id}->{$sth_id} = $self->{'dbh'}->{$db_id}->run( sub
		{
			&main::log("[" . uc( $db_id ). "] Preparing Database Handle Statement [" . uc( $sth_id ) . "] ") if $self->{'DEBUG'};
			return $_->prepare( $sql );
		} )
	};

	if ( my $ex = $@ )
	{
		&main::log("[" . uc( $db_id ) . "] *ERROR* Database exception received while preparing statement " . &main::ex( $ex ), E_ERROR);
		$self->{'dbh'}->{$db_id}->disconnect;

		return undef;
	}
}




















































1;