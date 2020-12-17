#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
my $min_parent_depth = 10;

while(<STDIN>){
    if(eof()){
    	print "\n";	
    }
    else{
    	my $line = "$_";
    	chomp $line;
        if($line=~m/^#/){
    	    print "$line\n";
        }
        else{
            my @fields = split /\t/,$line;
            my $chrom =  shift @fields;
            my $pos =    shift @fields;
            my $id =     shift @fields;
            my $ref =    shift @fields;
            my $alt =    shift @fields;
            my $qual =   shift @fields;
            my $filter = shift @fields;
            my $info =   shift @fields;
            my $format = shift @fields;

            $format =~ s/K\d+R:K\d+A/AD/;

            my $meta = "$chrom\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$format";
            
            my $p1 = shift @fields;
            my $p2 = shift @fields;
            my $f1 = shift @fields;
            $p1 =~ s/\./0/g;
            $p2 =~ s/\./0/g;
            $f1 =~ s/\./0/g;
            my @p1fields = split /:/, $p1;
            my @p2fields = split /:/, $p2;
            my @f1fields = split /:/, $f1;
            my $p1_dp = $p1fields[1] + $p1fields[2];
            my $p2_dp = $p2fields[1] + $p2fields[2];
            my $f1_dp = $f1fields[1] + $f1fields[2];
            my $p1_gt;
            my $p1_gq;
            if(( $p1fields[1] > 0 ) && ( $p1fields[2] > 0 )){
                $p1_gt = "0/1";
                $p1_gq = 1;
            }
            elsif(( $p1fields[1] > 0 ) && ( $p1fields[2] == 0 )){
                $p1_gt = "0/0";
                $p1_gq = 1;
            }
            elsif(( $p1fields[1] == 0 ) && ( $p1fields[2] > 0 )){
                $p1_gt = "1/1";
                $p1_gq = 1;
            }
            else{
                $p1_gt = "./.";
            }
            my $p2_gt;
            my $p2_gq;
            if(( $p2fields[1] > 0 ) && ( $p2fields[2] > 0 )){
                $p2_gt = "0/1";
                $p2_gq = 1;
            }
            elsif(( $p2fields[1] > 0 ) && ( $p2fields[2] == 0 )){
                $p2_gt = "0/0";
                $p2_gq = 1;
            }
            elsif(( $p2fields[1] == 0 ) && ( $p2fields[2] > 0 )){
                $p2_gt = "1/1";
                $p2_gq = 1;
            }
            else{
                $p2_gt = "./.";
            }
            my $f1_gt;
            my $f1_gq;
            if(( $f1fields[1] > 0 ) && ( $f1fields[2] > 0 )){
                $f1_gt = "0/1";
                $f1_gq = 1;
            }
            elsif(( $f1fields[1] > 0 ) && ( $f1fields[2] == 0 )){
                $f1_gt = "0/0";
                $f1_gq = 1;
            }
            elsif(( $f1fields[1] == 0 ) && ( $f1fields[2] > 0 )){
                $f1_gt = "1/1";
                $f1_gq = 1;
            }
            else{
                $f1_gt = "./.";
            }

            if(    ( $p1_gt eq "0/0" || $p1_gt eq "1/1" )
                && ( $p2_gt eq "0/0" || $p2_gt eq "1/1" )
                && ( $p1_gt ne $p2_gt )
                && ( $f1_gt eq "0/1" )
                && ( $p1_dp >= $min_parent_depth )
                && ( $p2_dp >= $min_parent_depth )
                && ( $f1_dp >= $min_parent_depth )
            ){
                my $p1out = $p1_gt.":".$p1fields[1].",".$p1fields[2].":2";
                my $p2out = $p2_gt.":".$p2fields[1].",".$p2fields[2].":2";
                my $f1out = $f1_gt.":".$f1fields[1].",".$f1fields[2].":2";
                my @outfields = ($meta, $p1out, $p2out, $f1out);
                foreach(@fields){
                    my @f2fields = split /:/, "$_";
                    my $f2_gt;
                    my $f2_gq;
                    if(( $f2fields[1] > 0 ) && ( $f2fields[2] > 0 )){
                        $f2_gt = "0/1";
                        $f2_gq = 1;
                    }
                    elsif(( $f2fields[1] > 0 ) && ( $f2fields[2] == 0 )){
                        $f2_gt = "0/0";
                        $f2_gq = 1;
                    }
                    elsif(( $f2fields[1] == 0 ) && ( $f2fields[2] > 0 )){
                        $f2_gt = "1/1";
                        $f2_gq = 1;
                    }
                    else{
                        $f2_gt = "./.";
                        $f2_gq = ".";
                    }
                    my $f2out = $f2_gt.":".$f2fields[1].",".$f2fields[2].":".$f2_gq;
                    push @outfields, $f2out;
                }
                my $out = join "\t", @outfields;
                print "$out\n";
            }
            else{
            }
        }
    }
}


