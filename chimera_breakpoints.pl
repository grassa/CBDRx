#!/usr/bin/perl
use warnings;
use strict;

my %candidate_breaks = ();
while(<STDIN>){
    my $line = "$_";
    chomp $line;
    my @fields = split /\t/, "$line";
    my $ctg           = $fields[0];
    my $class         = $fields[3];
    print "$class\n";
    my $feature_range = "$fields[1]"."-"."$fields[2]";
    my $search_range  = "$fields[11]"."-"."$fields[5]";
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{start}                 = $fields[1];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{end}                   = $fields[2];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{search_up_start}       = $fields[5];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{search_up_end}         = $fields[6];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{search_down_start}     = $fields[10];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{search_down_end}       = $fields[11];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{feature_distance_up}   = $fields[9];
    $candidate_breaks{$ctg}{$search_range}{$class}{$feature_range}{feature_distance_down} = $fields[14];
}

my @chimeric_contigs = keys %candidate_breaks;
foreach(@chimeric_contigs){
    my $ctg = $_;
    #print "$ctg\n";
    my @search_ranges = keys %{$candidate_breaks{$ctg}};
    foreach(@search_ranges){
        my $search_range = $_;
        #print "$search_range\n";
        if(exists $candidate_breaks{$ctg}{$search_range}{lowdepth}){
            my @feature_ranges = keys %{$candidate_breaks{$ctg}{$search_range}{lowdepth}};
            foreach(@feature_ranges){
                my $feature_range = $_;
                my $start = $candidate_breaks{$ctg}{$search_range}{lowdepth}{$feature_range}{start};
                my $end = $candidate_breaks{$ctg}{$search_range}{lowdepth}{$feature_range}{end};
                print "$ctg\t$start\t$end\tlowdepth\n";
            }
        }
        elsif(exists $candidate_breaks{$ctg}{$search_range}{repeat}){
            my @feature_ranges = keys %{$candidate_breaks{$ctg}{$search_range}{repeat}};
            my $max_repeat_length = -1;
            my $max_repeat;
            my $max_in_bounds_repeat_length = -1;
            my $max_in_bounds_repeat;
            foreach(@feature_ranges){
                my $feature_range = $_;
                my $fstart = $candidate_breaks{$ctg}{$search_range}{repeat}{$feature_range}{start};
                my $fend = $candidate_breaks{$ctg}{$search_range}{repeat}{$feature_range}{end};
                my $search_up_end = $candidate_breaks{$ctg}{$search_range}{repeat}{$feature_range}{search_up_end};
                my $search_down_start = $candidate_breaks{$ctg}{$search_range}{repeat}{$feature_range}{search_down_start};
                my $repeat_length = $fend - $fstart;
                if($repeat_length > $max_repeat_length){
                    $max_repeat = $feature_range;
                    $max_repeat_length = $repeat_length;
                }
                else{}
                if(($search_up_end < $fstart) && ($fend < $search_down_start)){
                    if( $repeat_length > $max_in_bounds_repeat_length){
                        $max_in_bounds_repeat = $feature_range;
                        $max_in_bounds_repeat_length = $repeat_length;
                    }
                    else{
                    }
                
                }
            }
            my $start;
            my $end;
            if($max_in_bounds_repeat_length >= 0){
                $start = $candidate_breaks{$ctg}{$search_range}{repeat}{$max_in_bounds_repeat}{start};
                $end = $candidate_breaks{$ctg}{$search_range}{repeat}{$max_in_bounds_repeat}{end};
            }
            else{
                $start = $candidate_breaks{$ctg}{$search_range}{repeat}{$max_repeat}{start};
                $end = $candidate_breaks{$ctg}{$search_range}{repeat}{$max_repeat}{end};
            }
            print "$ctg\t$start\t$end\trepeat\n";
        }
    }
}

