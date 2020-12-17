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
	if($line=~m/^##/){
	}
        elsif($line=~m/^#CHROM/){
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
    	    my $out = join ("\t", $chrom, $pos, @fields);
	    print "$out\n";
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


            
            my $p1 = shift @fields;
            my $p2 = shift @fields;
            my @p1fields = split /:/, $p1;
            my @p2fields = split /:/, $p2;
            my $p1_gt = $p1fields[0];
            my $p2_gt = $p2fields[0];

	    my @outfields = ($chrom, $pos, "1", "2");

	    foreach(@fields){
		my @subfields = split /:/, "$_";
		my $gt = $subfields[0];
		if($gt eq "0/1"){
			push @outfields, "3";
		}
		elsif($gt eq $p1_gt){
			push @outfields, "1";
		}
		elsif($gt eq $p2_gt){
			push @outfields, "2";
		}
		else{
			push @outfields, "n";
		}
	    }
	    my $out = join("\t", @outfields);
	    print "$out\n";
        }
    }
}


