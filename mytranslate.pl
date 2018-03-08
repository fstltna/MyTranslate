#!/usr/bin/perl
use DBI;
use WWW::Google::Translate;

# Settings
my $DATABASE="phpbb3";
my $DBTABLE="phpbb_arcade_games";
my $DBUSER="root";
my $SOURCE_LANG="hu";
my $DEST_LANG="en";
my $KEYFILE = "/root/.translate_key";

# Run code below here
my $BuildLine = "";
my $GameId = "";
my $lang = "";

if (! -f $KEYFILE)
{
	print "Unable to open key file - paste your google key into $KEYFILE\n";
	exit 1;
}
open MYKEYFILE, "<$KEYFILE" or die "Couldn't open file $! for reading";
my $READKEY = <MYKEYFILE>;
chop $READKEY;
close (MYKEYFILE);

# Get the dbadmin's password
print "Enter the SQL users password: ";
my $DBPASSWD = <STDIN>;
chomp $DBPASSWD;

# Create DB objects
my $dbh = DBI->connect("DBI:mysql:$DATABASE", $DBUSER, $DBPASSWD) || die "ERROR: $DBI::errstr";
my $query = "select * from $DBTABLE";
my $sth = $dbh->prepare($query);
$sth->execute();

my $wgt = WWW::Google::Translate->new(
      {   key            => $READKEY,
          default_source => $SOURCE_LANG,
          default_target => $DEST_LANG,
      }
);

# Start looping for records in the table
my $KeepWorking=-1;
my $AcceptAll=0;
my $AcceptEng=0;

while ($KeepWorking && (@row = $sth->fetchrow_array))
{
	$GameId = $row[0];
	$GameDesc = $row[3];
	$GameName = $row[9];
	my $NewText="";
	my $UserChoice="";


	print "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n";
	my $detectedlang = $wgt->detect( { q => $GameDesc } );
	$lang = $detectedlang->{data}->{detections}->[0]->[0]->{language};
	print "Detected language = '$lang'\n";
	my $r = $wgt->translate( { q => $GameDesc } );
	$BuildLine = "";
	for my $trans_rh (@{ $r->{data}->{translations} })
	{
		$NewText = $trans_rh->{translatedText};
		chomp ($NewText);
		if ($BuildLine eq "")
		{
			$BuildLine = $NewText;
		}
		else
		{
			$BuildLine = "$BuildLine $NewText";
		}
	}
	# Convert EOL to spaces
	$BuildLine =~ tr{\n}{ };
	print "| $GameName\n";
	print "| $GameDesc\n";
	print "| $BuildLine\n";
	if (($AcceptAll == 0) && (($AcceptEng == 0) || (($AcceptEng != 0) && ($lang ne "en"))))
	{
		print "Keep this translation? ";
		$UserChoice = <STDIN>;
		chop($UserChoice);
		if ($UserChoice eq "y")
		{
			print "Keeping translation\n";
			MarkTranslate();
		}
		elsif ($UserChoice eq "a")
		{
			print "Accepting All\n";
			$AcceptAll = -1;
			MarkTranslate();
		}
		elsif ($UserChoice eq "e")
		{
			print "Accepting All English\n";
			$AcceptEng = -1;
			MarkTranslate();
		}
		elsif ($UserChoice eq "q")
		{
			print "Quiting\n";
			$KeepWorking = 0;
		}
		else
		{
			print "Discarding translation\n";
		}
	}
	else
	{
		if ($AcceptAll == 0)
		{
			print "Auto Accepting English\n";
		}
		else
		{
			print "Auto Accepted\n";
		}
		MarkTranslate();
	}
	print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
}

sub MarkTranslate
{
	$dbh->do("UPDATE $DBTABLE SET game_desc = ? WHERE game_id = ?",
		undef,
		$BuildLine,
		$GameId);
}

$sth->finish();
$dbh->disconnect();

exit 0;

