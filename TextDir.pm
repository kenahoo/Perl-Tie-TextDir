package Tie::TextDir;

use strict;
use FileHandle;
use Carp;
use vars qw($VERSION);

$VERSION = '0.03';


sub TIEHASH {
	my $self = shift @_;
	my $path = shift @_;
	my $mode = shift @_;

	if (@_) {
		croak ("usage: tie(\%hash, \$path, [mode])");
	}

	# Nice-ify $path:
	$path =~ s#/$##;

	# Can we make changes to the database?
	my $clobber = ($mode eq 'rw' ? 1 : 0);

	unless (-e $path  and  -d $path) {
		if ($clobber) {
			# Create the directory if it doesn\'t exist
			unless (mkdir($path, 0775)) {
				croak("can't create $path: $!");
			}
		} else {
			croak("$path does not exist");
		}
	}

	# Get a filehandle and open the directory:
	my $fh = new FileHandle;
	opendir($fh, $path)  or croak("can't opendir $path: $!");		

	my $node = {
		PATH		=> $path,
		CLOBBER	=> $clobber,
		HANDLE	=> $fh
	};

	return bless $node, $self;
}



sub FETCH {
	my $self	= shift;
	my $key	= shift;
	my $file	= $self->{PATH}."/$key";

	return if !&_key_okay($key);

	return unless -e $file;

	my $fh;
	unless ($fh = new FileHandle($file)) {
		carp ("Can't open $file: $!");
		return;
	}
	
	local $/ = undef;
	return scalar <$fh>;
}


sub STORE {
	my $self = shift @_;
	my $key	= shift @_;
	my $value= shift @_;
	my $file	= $self->{PATH} . "/$key";

	if ( !&_key_okay($key) ) {
		carp ("Bad key '$key'");
		return;
	}

	unless ($self->{CLOBBER}) {
		carp ("no write access for $self->{'PATH'}");
		return;
	}

	my $fh;
	unless ($fh = new FileHandle(">$file")) {
		croak ("can't open $file: $!");
	}

	print $fh $value;
	close $fh;
}


sub DELETE {
	my $self = shift @_;
	my $key	= shift @_;
	my $file	= $self->{PATH} . "/$key";
	
	if ( not &_key_okay($key) ) {
		carp ("Bad key '$key'");
		return;
	}
	
	unless ($self->{CLOBBER}) {
		carp ("no write access for key=$key");
		return;
	}
	
	unless (unlink $file) {
		carp ("Couldn't delete key $self->{PATH}/$key: $!");
		return;
	}
}

sub CLEAR {
	croak ("textdir::CLEAR is not implemented.");
}

sub EXISTS {
	my $self = shift;
	my $key	= shift;
	
	return undef if not &_key_okay($key);
	return (-e "$self->{PATH}/$key");
}


sub DESTROY {
	closedir(shift()->{HANDLE});
}


sub FIRSTKEY {
	my $self = shift;
	my $entry;

	rewinddir($self->{HANDLE});
	while (defined ($entry = readdir($self->{HANDLE}))) {
		return $entry unless ($entry eq '.' or $entry eq '..');
	}
	return;
}


sub NEXTKEY {
	return readdir (shift()->{HANDLE});
}

sub _key_okay {
	return 0 if $_[0] =~ /^\.{0,2}$/;
	return 1;
}

1;

__END__

=head1 NAME

Tie::TextDir - interface to directory of files

=head1 SYNOPSIS

 use Tie::TextDir;
 tie (%hash, 'Tie::TextDir', '/some_directory', 'rw');  # Open in read/write mode
 $hash{'one'} = "some text";         # Creates file /some_directory/one
                                     # with contents "some text"
 untie %hash;
 
 tie (%hash, 'Tie::TextDir', '/etc');    # Defaults to read-only mode
 print $hash{'passwd'};  # Prints contents of /etc/passwd

=head1 DESCRIPTION

This is the Tie::TextDir module.  It is a TIEHASH interface which lets you
tie a Perl hash to a directory of textfiles.

To use it, tie a hash to a directory:

 tie (%hash, "/some_directory", 'rw');  # Open in read/write mode

If you pass 'rw' as the third parameter, you'll be in read/write mode,
and any changes you make to the hash will create or modify files in the
given directory.  If you don't open in read/write mode you'll be in 
read-only mode, and any changes you make to the hash won't have any effect
in the given directory.

=head1 LIMITATIONS

You may not use the empty string, '.', or '..' as a key in a hash, because 
they would all cause integrity problems in the directory.

This has only been tested on the UNIX platform, and some of the shadier
techniques probably won't work right on MacOS or DOS.

=head1 CAUTIONS

Strange characters can cause problems when used as the keys in a hash.
For instance, if you accidentally store '../../f' as a key, you'll
probably mess something up.  If you knew what you were doing, you're
probably okay.  I'd like to add an optional (by default on)
"safe" mode that URL-encodes keys (I've lost the name of the person who
suggested this, but thanks!).

=head1 AUTHOR

Ken Williams (ken@forum.swarthmore.edu)

=head1 COPYRIGHT

Copyright (c) 1998 Ken Williams/Swarthmore College.  All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1).

=cut
