# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..8\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tie::TextDir;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

sub report_result {
	my $ok = shift;
	$TEST_NUM ||= 2;
	print "not " unless $ok;
	print "ok $TEST_NUM\n";
	print "@_\n" if (not $ok and $ENV{TEST_VERBOSE});
	$TEST_NUM++;
}

my $dir = "data";


{
	my $val = "one line\ntwo lines\nbad stuff\003\005\n";
	
	# 2: open a database
	&report_result( tie(%hash, 'Tie::TextDir', $dir, 'rw'), $! );

	# 3: store a value
	$hash{'key'} = $val;
	&report_result( $hash{'key'} eq $val, "value is '$hash{'key'}" );

	untie %hash;
	
	# 4: retie the hash
	&report_result( tie (%hash, 'Tie::TextDir', $dir), $! );

	# 5: check the stored value
	&report_result($hash{'key'} eq $val, "value is '$hash{'key'}'");

	# 6: check whether the empty key exists()
	&report_result(not exists $hash{''});
	
	# 7: check whether the . key exists()
	&report_result(not exists $hash{'.'});
	
	# 8: check whether the .. key exists()
	&report_result(not exists $hash{'..'});
	
	untie %hash;
}
