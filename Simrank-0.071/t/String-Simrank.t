# Before `make install' is performed, this script should be able to run with
# `make test'. After `make install' it should work as `perl String-Simrank.t'
# also test with: prove -Ilib t/String-Simrank.t
#########################

use Test::More tests => 15;
BEGIN { use_ok('String::Simrank') };  #          this is counted as test #1

#########################

# Insert your test code below, the Test::More module is used here so read
# its man page ( perldoc Test::More ) for help editing this test script.

my $sr = new String::Simrank( { data => 'test_data/db.fasta'
                              });

#############
### don't do this here, do it at the use statement above.
## doing it here caused the "You tried to run a test without a plan at.."
# error.
# plan tests => 3;
############

## test the InlineC connections
ok( String::Simrank::add(2,5) == 7, 'simple add InlineC');              #2
ok( String::Simrank::subtract(9,4) == 5, 'simple subtract InlineC');    #3

my $numseqs = $sr->formatdb( { 
                                wordlen => 7,
                                } );

ok($numseqs == 12, 'formatted the entire db');                          #4

my $matches = $sr->match_oligos({ query => 'test_data/query.fasta' });
ok( scalar(keys %{$matches}) == 1, 'match_oligos returns a hash ref' ); #5


##### more precise testing for simrank values
$sr = new String::Simrank( { data => 'test_data/mini_db.fasta'
                              });

$numseqs = $sr->formatdb( { 
                    wordlen => 4,
		    pre_subst => 2,
		    minlen => 4,
                           } );

ok($numseqs == 6, 'formatted the entire mini_db');                     #6

$matches = $sr->match_oligos({ query => 'test_data/mini_db.fasta',
                    silent => 0,
		    pre_subst => 2,
                   });
ok( scalar(keys %{$matches}) == 6, 'match_oligos returns data for multiple query' );  #7
ok( $matches->{stringF}[0][1] == 100, 'test stringF matched itself 100.00%' );        #8
ok( $matches->{stringF}[1][1] == 90, 'test stringF matched stringM 90.00%' );         #9
ok( $matches->{stringF}[2][1] == 84.38, 'test stringF matched stringW 84.38%' );      #10


## now test ability to create output file
unlink('test_data/mini_db.simout') if (-e 'test_data/mini_db.simout');
## so I'm calling it in void context
$sr->match_oligos({ query => 'test_data/mini_db.fasta',
                    silent => 0,
		    pre_subst => 2,
		    outfile => 'test_data/mini_db.simout',
                   });
ok( -s 'test_data/mini_db.simout' == 314, 'created outfile of expected size');      #11


### now test the ability to sense and respond to long string identifiers:
$sr = new String::Simrank( { data => 'test_data/long_names.fasta'
                              });
$numseqs = $sr->formatdb( { 
                    wordlen => 7,
		    minlen => 7,
                           } );
ok($numseqs == 11, 'formatted the entire long_names.fasta file');                   #12
$matches = $sr->match_oligos({ query => 'test_data/long_names.fasta',
                    	       silent => 0,
			     });
ok( $matches->{E4B88ZC01B3AC1}[1][1] == 97.45, 
    'long ids: E4B88ZC01B3AC1 matched E4B88ZC01B3AC2 at 97.45%' );                  #13		  


## now test valid_character functions ####
$sr = new String::Simrank( { data => 'test_data/invalid_chars.fasta'
                              });
$numseqs = $sr->formatdb( { 
	   	    silent => 0,
                    wordlen => 7,
		    minlen => 7,
		    valid_chars => 'ACGT',
                           } );
print STDOUT "\n UNIQUE KMER COUNT:" . $sr->{unique_kmer_count} . "\n";
(ok $sr->{unique_kmer_count} == 2835, 'passed constrained valid_chars test');                     #14

$numseqs = $sr->formatdb( { 
	   	    silent => 0,
                    wordlen => 7,
		    minlen => 7,
		    valid_chars => undef,
                           } );
print STDOUT "\n UNIQUE KMER COUNT:" . $sr->{unique_kmer_count} . "\n";
(ok $sr->{unique_kmer_count} == 3052, 'passed undef valid_chars test');                     #15
1;