#!/usr/bin/perl
#================================================
# Filter::Swears example by Paul Wilson.
#================================================

  use strict;
  use CGI qw/:header/;
  use Filter::Swears;

#================================================

  my $string = 'Hooray for boobies!';
  my $filter = Filter::Swears->new( { char   => '*', 
                                      string => $string, 
	                                strict => 1 } );

  print header();
  print $filter->parse( ['boobies'] );


