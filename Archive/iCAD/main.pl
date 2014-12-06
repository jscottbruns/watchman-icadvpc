#!/usr/bin/perl -w

use strict;
use Date::Format;

$| = 1;

BEGIN
{
    push(@INC, "./lib");      
}
    
use DBI;
use Config::IniFiles;

&main::write_log("Initiating CAD Connector Interface");

my $cfg = Config::IniFiles->new( 
	-file => "./cad.ini"
) or die "Error parsing INI file from /etc/watchman/cad-connector/cad.ini";
	
my $dbh;

unless ( 
	$dbh = &main::dbh_connect(
		'db_host'	=>	$cfg->val( 'database', 'db_host'),
		'db_port'	=>	$cfg->val( 'database', 'db_port'),
		'db_name'	=>	$cfg->val( 'database', 'db_name'),
		'db_user'	=>	$cfg->val( 'database', 'db_user'),
		'db_pass'	=>	$cfg->val( 'database', 'db_pass')
	)
) {
	
	&main::write_log("Fatal error encountered when attempting to open MSSQL database connection: ($DBI::err) $DBI::errstr\n");
	exit;	
}
	
my $interval = $cfg->val( 'system', 'interval') || 5;

&main::write_log("Beginning main loop at $interval second interval");

while ( 1 ) {

	my $last_timestamp;

    my $sth = $dbh->prepare( qq{
        SELECT
	        t1.IncidentNo,
	        t2.unit
        FROM tblActiveFireCalls t1
        LEFT JOIN tblActiveTrucks t2 ON t2.incidentNo = t1.incidentNo
        WHERE t1.incident_no = ?
    } );

	if ( $sth->execute( $last_timestamp ) ) {

		while ( my $href = $sth->fetchrow_hashref ) {
			
		}
	}
	
	# Write XML file to remote site
	#system("nc -w 1 $ip_addr $remote_port < $niem_xml");

	sleep $interval;	
}

sub dbh_connect
{
	my %params = @_;
	my $data_src = q/dbi:ODBC:Cambria_CAD/;	
		
	my $_dbh = DBI->connect(
		$data_src,
		$params{'db_user'},
		$params{'db_pass'},
		{
			PrintError	=>	0,
			AutoCommit	=>	1
		}
	);
	
	if ( ! $_dbh ) 
	{
	
		&main::write_log("Failed to establish database connection, returning undef");
		return undef;	
	}

	return $_dbh;
}	
	

#
# Function:     db_sql
# Description:  Passes a SQL statement to the server and checks for an error response from the server
# Arguments:    $sql - SQL Statement to process
# Returns:      $sth - SQL Statement Handle
#
sub db_sql
{
	my ($sql, $sth, $rc);

	$sql = shift;

	if ( ! ($sql) ) {

		&main::write_log("SQL query not provided, returning false");
		return 0;
	}

	#
	# Verify that we are connected to the database
	#
	if ( ! ($dbh) || ! ( $sth = $dbh->prepare("GO") ) ) {
		
		#
		# Attempt to reconnect to the database
		#
		if ( ! dbh_connect() ) {
			
			&main::write_log("Unable to connect to database");
			exit;   # Unable to reconnect, exit the script gracefully
		}
	} else {
		
		$sth->execute;      # Execute the "GO" statement
		$sth->finish;       # Tell the SQL server we are done
	}

	$sth = $dbh->prepare($sql);     # Prepare the SQL statement passed to db_sql

	#
	# Check that the statement prepared successfully
	#
	if( ! defined($sth) || ! ( $sth ) ) {
		
		&main::write_log("Failed to prepare SQL statement: $DBI::errstr");

		#
		# Check for a connection error -- should not occur
		#
		if ( $DBI::errstr =~ /Connection failure/i ) {
			
			if ( ! dbh_connect() ) {
			
				&main::write_log("Unable to connect to database");
				exit;       # Exit gracefully
				
			} else {
				
				&main::write_log("Database connection re-established, attempting to prepare again.");
			
				$sth = $dbh->prepare($sql);
			}
		}
		
		#
		# Check to see if we recovered
		#
		if ( ! defined( $sth ) || ! ($sth) ) {
			
			&main::write_log("Unable to prepare SQL statement: [ $sql ]");
			return 0;
		}
	}

	#
	# Attempt to execute our prepared statement
	#
	$rc = $sth->execute;
	
	if ( ! defined( $rc ) ) {
		
		#
		# We failed, print the error message for troubleshooting
		#
		
		print "Unable to execute prepared SQL statement:\n";
		print "$DBI::errstr\n";
		print "$sql\n";
		
		return 0;
	}

	#
	# All is successful, return the statement handle
	#
	
	return $sth;
}

sub retrieve_rows
{
	my ($sth, $href);
	
	#
	# Check that we received a statement handle
	#
	if ( ! ($sth) ) {
		
		&main::write_log("Unable to retrieve statement handle");
		return 0;
	}
	
	#
	# Retrieve the rows from the SQL server
	#
	while( $href = $sth->fetchrow_hashref ) {
		
		print "ID: " . $$href{"ID"} . "\n";
		print "FOO: " . $$href{"FOO"} . "\n";
		print "BAR: " . $$href{"BAR"} . "\n";
		print "\n";
	}
	
	return 1;
}


sub write_log
{
    my $msg = shift;
    my $err = shift;
    my ($package, $file, $line) = caller;

    $msg =~ s/\n$//;
    $msg .= " (" . $$ . ")" if substr($$, 0, 1) eq '-';
    $msg = "[" . Date::Format::time2str('%C', time) . "] [" . $package . ":" . $line . "] " . ($err ? "[error] " : undef) . " $msg\n";

    print STDOUT $msg;
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