use Test;
use Tie::TextDir;

plan tests => 8;
ok 1;

my $dir = "data";


{
	my $val = "one line\ntwo lines\nbad stuff\003\005\n";
	
	# 2: open a database
	ok tie(%hash, 'Tie::TextDir', $dir, 'rw');

	# 3: store a value
	$hash{'key'} = $val;
	ok $hash{'key'}, $val, "value is '$hash{'key'}";

	untie %hash;
	
	# 4: retie the hash
	ok tie(%hash, 'Tie::TextDir', $dir);

	# 5: check the stored value
	ok $hash{'key'}, $val, "value is '$hash{'key'}'";

	local $^W;  # Don't generate superfluous warnings here

	# 6: check whether the empty key exists()
	ok exists $hash{''}, '';
	
	# 7: check whether the . key exists()
	ok exists $hash{'.'}, '';
	
	# 8: check whether the .. key exists()
	ok exists $hash{'..'}, '';
	
	untie %hash;
}
