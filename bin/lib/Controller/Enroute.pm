package Controller::Enroute;

sub new
{
    my $this = shift;

	&main::log("Initiating Enroute iCAD module");

    my $class = ref($this) || $this;
	my $self = {};
	
	$self = {
		Config		=> $::Config,
		DEBUG		=> $Config->{'debug'},
		DB_ICAD		=> $::DB_ICAD,
		pop3		=> undef,		
		dbh			=> {
			icad		=> &main::init_dbConnection('icad')
		}
	};
	
	bless $self, $class;
		
	return $self;
}	