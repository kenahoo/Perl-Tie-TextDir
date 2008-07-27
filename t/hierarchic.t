use strict;
use Test;
use Tie::TextDir;
use File::Spec;
use File::Path;

plan tests => 19;
ok 1;

my $dir = "data";

# Just to be sure the dir is empty
rmtree($dir);

{
  my $val = "one line\ntwo lines\nbad stuff\003\005\n";
  
  # 2: open a database
  my %hash;
  ok tie(%hash, 'Tie::TextDir', $dir, 'rw', undef, 1);
  
  # 3: store a value
  $hash{'key'} = $val;
  ok $hash{'key'}, $val;
  
  untie %hash;
  
  # 4: retie the hash
  ok tie(%hash, 'Tie::TextDir', $dir, undef, undef, 1);
  
  # 5: check the stored value
  ok $hash{'key'}, $val;
  
  local $^W;  # Don't generate superfluous warnings here
  
  # 6: check whether the empty key exists()
  ok exists $hash{''}, '';
  
  # 7: check whether the . key exists()
  ok exists $hash{'.'}, '';
  
  # 8: check whether the .. key exists()
  ok exists $hash{'..'}, '';
  
  untie %hash;
  
  # Clean up
  ok tie(%hash, 'Tie::TextDir', $dir, 'rw', undef, 1);
  delete $hash{$_} foreach keys %hash;
  ok keys %hash, 0;
  
  rmdir $dir;
  ok -e $dir, undef;
}

# Make sure our test environment is sane
rmtree($dir);
{
  my $val = "one line\ntwo lines\nbad stuff\003\005\n";
  
  # 12. open a database
  my %hash;
  ok tie(%hash, 'Tie::TextDir', $dir, 'rw', undef, 2);
  
  # 13, 14. store a lot of values
  for (qw!cow frog!) {
    $hash{$_} = $val;	
  }

  for (qw!cow frog!) {
    ok $hash{$_}, $val;	
  }

  # 15, 16 store two smaller keys
  for (qw!f oo!) {
    $hash{$_} = $val;	
  }
	
  for (qw!f oo!) {
    ok $hash{$_}, $val;	
  }

  untie %hash;
  
  # 17..19: Cleanup
  ok tie(%hash, 'Tie::TextDir', $dir, 'rw', undef, 2);
  delete $hash{$_} foreach keys %hash;
  ok keys %hash, 0;
  
  rmdir $dir;
  ok -e $dir, undef;
}

