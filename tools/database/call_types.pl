	#!/usr/bin/perl
	use DBI;
	
	my $dbh = DBI->connect('dbi:mysql:ICAD_MASTER;host=icad-rds;port=3306', 'admin', 'aci123Ava');
	
	my $sth = $dbh->prepare("SELECT CallType FROM Incident WHERE Agency = '231' GROUP BY CallType") or die "Can't prepare statement: $DBI::errstr";
	my $sth2 = $dbh->prepare("SELECT Nature FROM Incident WHERE Agency = '231' AND CallType = ? GROUP BY Nature");
	my $sth_insert = $dbh->prepare("INSERT INTO CallType VALUES (?, ?, ?, ?)");
	
	if ( $sth->execute )
	{
		while ( my $ref = $sth->fetchrow_hashref )
		{
			my $type = $ref->{'CallType'};
			print "Checking Call Type: $type\n";
			
			
			
			if ( $sth2->execute( $type ) )
			{
				while ( my $ref2 = $sth2->fetchrow_hashref )
				{
					my $nature = $ref2->{'Nature'};
					print "  -- $nature\n";
					
					$sth_insert->execute($type, 'FIRE', $nature, $nature) or die "Insert error: $DBI::errstr\n";
				}
			}	
		}	
	}