#!/usr/bin/perl
use warnings;
use strict;
my $pattern1 = shift;
my $pattern2 = shift;

my %refpatterns = ();
my %querypatterns = ();
my $pattern1cm;
my $pattern2cm;
if($pattern1 =~ m/([0-9\.]+)\-(\S+)/){
    $pattern1cm = $1;
    my $pattern = $2;
    $refpatterns{$pattern} = 1;
}
else{
    die "error\n";
}
if($pattern2 =~ m/([0-9\.]+)\-(\S+)/){
    $pattern2cm = $1;
    my $pattern = $2;
    $refpatterns{$pattern} = 1;
}
else{
    die "error\n";
}
my $expected_between = sprintf("%.0f", (($pattern2cm - $pattern1cm) / 0.52));
#print "EXPECTED: $expected_between\n";
my @testpatterns;
while(<STDIN>){
    my $line = $_;
    chomp $line;
    my @fields = split /\-/, $line;
    my $id = $fields[0];
    my $pattern = $fields[1];
    if(exists $refpatterns{$pattern}){
    }
    elsif(exists $querypatterns{$pattern}){
    }
    else{
        $querypatterns{$pattern} = 1;
        push @testpatterns, $line;
    }
}
my @inpatterns = ($pattern1, $pattern2);
my @inpatterninfo = &count_recombinants(@inpatterns);
my $inpattern_dist = $inpatterninfo[0];
#print "$inpattern_dist recombinants between inpatterns\n";
my @between;
#print "PATTERN1: $pattern1\n";
foreach(@testpatterns){
    my $testpattern = $_;
    my @testbtwninpatterns = ($pattern1, $testpattern, $pattern2);
    my @testpattern_info = &count_recombinants(@testbtwninpatterns);
    my $testpattern_dist = $testpattern_info[0];
    if($testpattern_dist == $inpattern_dist){
        #print "BETWEEN: $testpattern\n";
        push @between, $testpattern;
    }
    else{}

}
my $n_found_between = scalar(@between);
my @out_list;
my $toomany = 0;
if($n_found_between > $expected_between){
    $toomany = 1;
    print STDERR "TOOMANY: ($n_found_between-$expected_between)\n";
}
else{}
if($n_found_between == 0){
    print STDERR "found 0\n";
}
elsif($n_found_between == 1){
    my @newpattern_list;
    push @newpattern_list, $pattern1;
    my $newmarker = $between[0];
    push @newpattern_list, $newmarker;
    push @newpattern_list, $pattern2;
    my @out_list = &count_list_recombinants(@newpattern_list);
    
    my $out_recombinants = $out_list[1];
    my @fields = split / /, $out_recombinants;
    my $outcm = sprintf("%.2f", ($pattern1cm + (0.52 * $fields[1])));
    my $out = join("-", $outcm, $fields[2]);
    print STDERR "FOUND: 1\n";
    print "$out\n";
}
else{
    my @newpattern_list = ($pattern1, @between, $pattern2);
    my @out_list;
    my @newpattern_list_ordered = &findpath(@newpattern_list);
    my @ordered_list = &count_list_recombinants(@newpattern_list_ordered);
    
    my $first_ordered = shift @ordered_list;
    pop @ordered_list;
    my $last_ordered = pop @newpattern_list_ordered;
    my $cm = $pattern1cm;
    if($last_ordered eq $pattern2){
        foreach(@ordered_list){
            my $item = $_;
            my @itemfields = split / /, $item;
            my $cm_out = sprintf("%.2f", ($cm + (0.52 * $itemfields[1])));
            my $pattern_out = $itemfields[2];
            push @out_list, "$cm_out"."-"."$pattern_out";
            $cm = $cm_out;
        }
        if($toomany == 1){
            my $out = join("\n", @out_list);
            print STDERR "TOOMANY\n";
            print STDERR "$pattern1\n";
            print STDERR "$out\n";
            print STDERR "$pattern2\n";
            print STDERR "TOOMANY\n";
        }
        elsif($cm < $pattern2cm){
            my $out = join("\n", @out_list);
            print "$out\n";
        }
        else{
            my $out = join("\n", @out_list);
            print STDERR "between notfound: $cm > $pattern2cm\n";
            print STDERR "CMINCREASE\n";
            print STDERR "$pattern1\n";
            print STDERR "$out\n";
            print STDERR "$pattern2\n";
            print STDERR "CMINCREASE\n";
        }
    
    }
    else{
    
            print STDERR "between notfound: $last_ordered ne $pattern2 \n";
    }

}

sub findpath {
    my @search_patterns = @_;
    my @ordered_patterns;
    my $n_search = scalar(@search_patterns);
    my @search_graph;
    push @search_graph, $n_search;
    my $i = 1;
    my %seen = ();
    foreach(@search_patterns){
        my $patternA = $_;
        my $j = 1;
        foreach(@search_patterns){
            my $patternB = $_;
            if($i==$j){
            }
            elsif(exists $seen{$i}{$j}){
            }
            elsif(exists $seen{$j}{$i}){
            }
            else{
                my @testbtwninpatterns = ($patternA, $patternB);
                my @testpattern_info = &count_recombinants(@testbtwninpatterns);
                my $testpattern_dist = $testpattern_info[0];
                push @search_graph, "$i $j $testpattern_dist";
                $seen{$i}{$j} = 1;
            }
            ++$j;
        }
        ++$i;
    }
    open OUTTMP,">", "find_path_between_patterns.tmp";
    foreach(@search_graph){
        print OUTTMP "$_\n";
    }
    close OUTTMP;
    system("./bin/greedy04 -D 1 find_path_between_patterns.tmp | grep -v '^\$' | tail -n $n_search | sort -k3,3n | awk '{print \$1}' >find_path_between_patterns.tmp2");
    my $intmp = "find_path_between_patterns.tmp2";
    open INTMP, "<", $intmp or die "error\n";
    while($intmp=<INTMP>){
        my $line = $intmp;
        chomp $line;
        my $index = ($line - 1);
        my $search_pattern = $search_patterns[$index];
        push @ordered_patterns, "$search_pattern";
    }
    close INTMP;
    system("rm find_path_between_patterns.tmp2");
    system("rm find_path_between_patterns.tmp");
    return(@ordered_patterns);
}
#print "PATTERN2: $pattern2\n";
sub count_recombinants{
    my @inlines = @_;
    my $line1 = 1;
    my $homA = "A";
    my $homB = "B";
    my $het  = "H";
    my $unknown = "n";
    my @population_recombinations = ();
    my @previous_pattern = ();
    my $sum_recombinations = 0;
    foreach(@inlines){
        my $line = "$_";
        chomp $line;
        my @id_pattern = split /-/, "$line";
        my @current_pattern = split //, $id_pattern[1];
        my $marker_id = $id_pattern[0];    
        if($line1 == 1){
            @previous_pattern = @current_pattern;
            $line1 = 0;
        }   
        else{}
    
        my $current_population_recombinations = 0;
        my $i = 0;
        foreach(@current_pattern){
            
            my $current_genotype = "$_";
            my $previous_genotype = $previous_pattern[$i];
            
            my $current_individual_recombinations = 0;
            if("$current_genotype" eq "$previous_genotype"){
                $current_individual_recombinations = 0;
            }
            elsif(("$current_genotype" eq "$unknown" ) || ("$previous_genotype" eq "$unknown" )){
                $current_individual_recombinations = 0;
            }
            elsif(   (  ( "$current_genotype" eq "$homA")
                      &&("$previous_genotype" eq "$homB")
                     )
                  || (  ( "$current_genotype" eq "$homB") 
                      &&("$previous_genotype" eq "$homA")
                     )
                 ){
    
                $current_individual_recombinations = 2;
            }
            else{
                $current_individual_recombinations = 1;
            }
            
            $current_population_recombinations += $current_individual_recombinations;
            $population_recombinations[$i]     += $current_individual_recombinations;
            ++$i;
        }
        $sum_recombinations += $current_population_recombinations;
        #my $out = join(" ", $marker_id, $current_population_recombinations, @current_pattern);
        #print "$out\n";
        @previous_pattern = @current_pattern;
    }
    
    my @summary = ($sum_recombinations, @population_recombinations);
    return (@summary);
}

sub count_list_recombinants{
    my @inlines = @_;
    my @returnout;
    my $line1 = 1;
    my $homA = "A";
    my $homB = "B";
    my $het  = "H";
    my $unknown = "n";
    my @population_recombinations = ();
    my @previous_pattern = ();
    my $sum_recombinations = 0;
    foreach(@inlines){
        my $line = "$_";
        chomp $line;
        my @id_pattern = split /-/, "$line";
        my @current_pattern = split //, $id_pattern[1];
        my $marker_id = $id_pattern[0];    
        if($line1 == 1){
            @previous_pattern = @current_pattern;
            $line1 = 0;
        }   
        else{}
    
        my $current_population_recombinations = 0;
        my $i = 0;
        foreach(@current_pattern){
            
            my $current_genotype = "$_";
            my $previous_genotype = $previous_pattern[$i];
            
            my $current_individual_recombinations = 0;
            if("$current_genotype" eq "$previous_genotype"){
                $current_individual_recombinations = 0;
            }
            elsif(("$current_genotype" eq "$unknown" ) || ("$previous_genotype" eq "$unknown" )){
                $current_individual_recombinations = 0;
            }
            elsif(   (  ( "$current_genotype" eq "$homA")
                      &&("$previous_genotype" eq "$homB")
                     )
                  || (  ( "$current_genotype" eq "$homB") 
                      &&("$previous_genotype" eq "$homA")
                     )
                 ){
    
                $current_individual_recombinations = 2;
            }
            else{
                $current_individual_recombinations = 1;
            }
            
            $current_population_recombinations += $current_individual_recombinations;
            $population_recombinations[$i]     += $current_individual_recombinations;
            ++$i;
        }
        $sum_recombinations += $current_population_recombinations;
        my $out = join(" ", $marker_id, $current_population_recombinations, join("",@current_pattern));
        push @returnout, "$out";
        @previous_pattern = @current_pattern;
    }
    
    #my @summary = ($sum_recombinations, @population_recombinations);
    return (@returnout);
}



