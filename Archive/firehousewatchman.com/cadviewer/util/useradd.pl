#!/usr/bin/perl
use Getopt::Long;
use DBI;

my($uname, $fullname, $license, $email, $help);

#$| = 1;

usage() if (
	! GetOptions(
		"user=s"	=>	\$uname,
		"name=s"	=>	\$fullname,
		"license=s"	=>	\$license,
		"email=s"	=>	\$email,
		"help|?"	=>	\$help
	) || defined $help || ! defined $uname || ! defined $fullname || ! defined $license || ! defined $email
);

my ($pwdconfirm, $pwd);

$pwd = promptUser("Enter Password: ");
$pwdconfirm = promptUser("Confirm Password: ");

if ( $pwd ne $pwdconfirm ) {

	print "Passwords do not match\n";
	exit;
}

my $dbhost = 'db2.dealer-choice.com';
my $dbname = 'watchman';
my $dbuser = 'watchman';
my $dbpass = 'Q830GKAhq73ywjrCNgCD';

unless (
	$dbi = DBI->connect(
		"DBI:mysql:$dbname:$dbhost",
		$dbuser,
		$dbpass,
		{
		   PrintError => 0
		}
) ) {

	print "Can't connect to MySQL DB: $DBI::errstr\n";
	exit;
}

my $pwdhash = `php print_pwd_hash.php $pwd`;

unless (
	$dbi->prepare( qq{
		INSERT INTO hostsync_client
		(
			id_hash,
			timestamp,
			license,
			user_name,
			pwd_hash,
			full_name,
			email
		)
		VALUES
		(
			SUBSTRING(MD5(RAND()) FROM 1 FOR 32),
			UNIX_TIMESTAMP(),
			?,
			?,
			?,
			?,
			?
		)
	} )->execute(
		$license,
		$uname,
		$pwdhash,
		$fullname,
		$email
	)
) {

	print "MySQL error preparing hostsync replace into query: ($DBI::err) $DBI::errstr \n";
	exit;
}

sub promptUser
{
	local($promptString, $defaultValue) = @_;

	if ( $defaultValue ) {
		print $promptString, "[", $defaultValue, "]: ";
	} else {
		print $promptString, ": ";
	}

	$| = 1;
	$_ = <STDIN>;

	chomp;

	if ( "$defaultValue" ) {
		return $_ ? $_ : $defaultValue;
	} else {
		return $_;
	}
}


sub usage
{
	print "Unknown option: @_\n" if ( @_ );
	print "usage: $0 [--user USERNAME] [--name FULLNAME] [--license LICENSE] [--email EMAIL] [--help|-?]\n";
	exit;
}
