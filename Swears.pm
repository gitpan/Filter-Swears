package Filter::Swears;
#================================================
# Filter::Swears by Paul Wilson.
# http://www.wiredon.net/
# pwilson@wiredon.net
#================================================

  use strict;
  use Carp;
  use vars qw/$VERSION/; $VERSION = '1.01';

#================================================

sub Version { $VERSION; }

sub new {
#------------------------------------------------
# Create a new filter object.

    my ($self, $args) = @_;
	my ($default)     = { strict => 0, char => '*', string => undef };

	if (ref $args ne 'HASH') {
		Carp::croak "Argument to Filter::Swears->new method must be a hash reference";
	}
    elsif ($args->{string} =~ /^\s*$/) {
		Carp::croak "Cannot parse a blank string";
	}

# Create a blessed reference with either our defaults or user defined options.
	my %$tmp = map { 
		             $_ => (
						      defined $args->{$_} ? $args->{$_} : $default->{$_} ) } keys %$default;

	return bless $tmp, $self;
}

sub parse {
#------------------------------------------------
# Parse out any naughties.
# Accepts one arg: An arrayref of words or the path to a word file.

    my ($self, $bad) = @_;
	my ($string)     = $self->{string};
	my (@words);

	if (ref $bad eq 'ARRAY') {
        return $self->naughty( $string, $bad );
	}
	elsif (not ref $bad) {

# Make sure the bad words file is readable, and is a text file.
		if (-r $bad and -T _ and -s _) {
			open (FH, $bad) or Carp::croak "Cannot read swears file: $!";
			while (<FH>) {
				chomp;
				push @words, $_;
			}
			close(FH);
			return $self->naughty( $string, \@words);
		}
		else {
			Carp::croak "Cannot read file '$bad'. Is not readable,is not a text file or is empty";
		}
	}
	else {
		Carp::croak "Unrecognized argument passed to \$obj->parse";
	}

	return $string;
}

sub naughty {
#------------------------------------------------
# Parse out the bad words.

    my ($self, $string, $bad) = @_;

# Do the actual substitution. The regex is built in the regex() method.
    for my $s (@$bad) {
	    my $clean = $self->regex($s);
	    $string =~ s/$clean/$self->{char} x length($s)/egi;
    }
	return $string;
}

sub regex {
#------------------------------------------------
# Construct the regex.

    my ($self, $s) = @_;

# Using strict filtering will match practically anything.
# Non-strict filtering will ignore bad words spread over multiple lines or spaced out.
	return $self->{strict} == 1 ? join("([ \n]+|[^ \n]*?)", split //, $s) : join("[^ \n]*?", split //, $s);
}

__END__

=head1 NAME

Filter::Swears will filter words or phrases from a string.

=head1 SYNOPSIS

 use Filter::Swears;

 my $string = 'Hooray for boobies!';
 my $filter = Filter::Swears->new( { char   => '*', 
                                     string => $string, 
	                                 strict => 1 } );

 print "Content-type: text/html\n\n";
 print $filter->parse( ['boobies'] );

=head1 DESCRIPTION

The Filter::Swears module will filter words or phrases from a string.

The new() method accepts a hashref of options.

char   - The character to substitute filtered words with.
string - The string to filter.
strict - Set to 1 for strict filtering or 0 for gentle filtering.

You may pass in an arrayref of words or phrases to the parse() method or a system file path.
The file should contain one word or phrase per line to filter out.

Using non strict filtering would filter the following (amongst other combinations)...

boobies
b.o.o.b.i.e.s
b_o_o_b_i_e_s
bboooobbiieess

..and any other combination of characters between the letters.

Strict spacing would catch:

b
o
o
b
i
e
s

or b o o b i e s

=head1 BUGS

Please report any strange occurances to paul@cpan.org

=head1 AUTHOR

Written by Paul Wilson.

=head1 COPYRIGHT

Copyright (c) 2002 Paul Wilson.  All Rights Reserved.
http://www.wiredon.net/

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 VERSION

Revision: $Id: Swears.pm,v 1.01 2002/05/02 12:40:33 paul Exp $

=cut

1;