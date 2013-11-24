#!/usr/bin/perl -w
use strict;
use Term::ANSIColor qw(:constants);

my @scm_files;
if (scalar(@ARGV)) {
    # tests specified on the command line
    @scm_files = @ARGV;
} else {
    @scm_files = glob("tests/*.scm") or die "Error getting scm files: $!";
}


my @compile_fail;
my @run_fail;
my @output_fail;
my @success;

for my $scm_file (@scm_files) {
    print BOLD, "Running: '$scm_file'\n",RESET;
    # compile
    if (system("./main $scm_file &>/tmp/compile_out") != 0) {
        push(@compile_fail,$scm_file);
        print BOLD, YELLOW, "$scm_file:\n", RESET;
        system("cat /tmp/compile_out");
        next;
    } 
    open(SRC,$scm_file) or die "Error opening scm file: $!";
    my @expected;
    my $should_error = 0;
    while (<SRC>) {
        if (/^;\s*>(\s*)\n$/) {
            # expected vaue contains only whitespace            
            push @expected, $1;
        }
        elsif (/^;\s*>\s*(.*)/){
            push @expected, $1;
        }
        elsif (/^;;\s*error/) {
            $should_error++;
        }
    }

    # run
    my $exec_file = $scm_file;
    $exec_file =~ s/\.scm$//;
    my $res = system("./$exec_file &> /tmp/run_tests.out");
    if (($res != 0 && !$should_error) ||
        ($res == 0 && $should_error)){        
        push(@run_fail, $scm_file);
        print BOLD, YELLOW, "$scm_file:\n", RESET;
        system("cat /tmp/run_tests.out");
        if ($should_error) {
            print BOLD,YELLOW,"Expected to fail\n",RESET;
            pop(@run_fail);
        }
        next;
    }

    # compare output    
    open(RES, "/tmp/run_tests.out");
    my @results = <RES>;
    map(chomp, @results);
    my $diff = 0;
    #print "@results\n";
    #print "@expected\n";
    for (my $i = 0; $i <= $#expected; $i++) {
        if ($results[$i] && $expected[$i] ne $results[$i]) {
            print BOLD, YELLOW, "$scm_file: line $i\n", RESET;
            for (my $j = 0; $j < $i; $j++) {
                print "$results[$j]\n";
            }
            print "'$results[$i]' RECIEVED\n";
            print BOLD, YELLOW, "'$expected[$i]' EXPECTED\n", RESET;
            push(@output_fail,$scm_file);
            $diff = 1;
            last;
        }
    }
    close(RES);
    close(SRC);
    if (!$diff) {
        push(@success,$scm_file);
    }
}

sub show {
    for my $x (@_) { print BOLD,YELLOW,"       $x\n",RESET }
}


my $ncomp = @compile_fail;
my $nrun = @run_fail;
my $nout = @output_fail;
my $nsucc = @success;

if ($ncomp == 0 &&
    $nrun == 0 &&
    $nout == 0) {
    print BOLD, GREEN, "[YAY!]", RESET " All $nsucc tests succeeded!\n";
} else {
   #print BOLD, RED,  "[FAIL]", RESET " $all_failed tests failed\n";
    if ($nsucc) {
        print BOLD, GREEN,"[OK]  ", RESET " $nsucc tests succeeded\n";
	show(@success);
    }
    if ($ncomp) {
        print BOLD, RED,  "[FAIL]", RESET " $ncomp tests failed to compile\n";
        show(@compile_fail);
    }
    if ($nrun) {
        print BOLD, RED,  "[FAIL]", RESET " $nrun tests failed to execute\n";
        show(@run_fail);
        
    }
     if ($nout) {
         print BOLD, RED,  "[FAIL]", RESET " $nout tests with incorrect output\n";
         show(@output_fail);
     }
}
