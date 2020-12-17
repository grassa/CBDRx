#!/usr/bin/perl
use warnings;
use strict;

my $lm = shift;
my $fasta = shift;

my %directions = ();
my %sequence = ();
open LM,"<", $lm or die;
while($lm=<LM>){
    my $line = $lm;
    chomp $line;
    my @fields = split /\s+/, $line;
    my $contig = $fields[0];
    my $slope = $fields[2];
    my $direction;
    if(($slope eq "nan") || ($slope==0)){
        my $rand = int(rand(2));
        if($rand == 1){
            $direction = "n+";
        }
        else{
            $direction = "n-";
        }
    }
    else{
        if($slope > 0){
            $direction = "+";
        }
        else{
            $direction = "-";
        }
    }
    $directions{$contig} = $direction;
}
close LM;
my $header;
open FASTA,"<", $fasta;
while($fasta=<FASTA>){
    my $line = $fasta;
    chomp $line;
    if($line =~ m/^>(\S+)/){
        $header = $1;
    }
    else{
        $sequence{$header} .= $line;
    }
}
close FASTA;

my %seen = ();
my $bp = 0;
my $lg = "n";
while(<STDIN>){
    my $line = $_;
    chomp $line;
    my @fields = split /\t/, $line;
    my $contig = $fields[0];
    if(exists $seen{$contig}){
    
    }
    else{
        if($fields[3] ne $lg){
            print ">$fields[3]\n";
            $lg = $fields[3];
            $bp = 0;
        }
        else{
        }
        my $direction = $directions{$contig};
        my $seq = $sequence{$contig};
        if($direction =~ /\-/){
            $seq = &rev_comp($seq);
        }
        else{
        }
        print "$seq"."nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn\n";
        my $start = $bp;
        my $end = $start + length($seq);
        print STDERR "$lg\t$contig\t$direction\t$start\t$end\n";
        $bp = $end + 100;
        $seen{$contig} = 1;
    }
}
my @all_contigs = keys %sequence;
foreach(@all_contigs){
    my $contig = $_;
    if(exists $seen{$contig} ){
    }
    else{
        my $seq = $sequence{$contig};
        print ">$contig\n$seq\n";         
    }
}

sub rev_comp{
  my ($seq) = @_;

  my $r_seq = reverse($seq);
  $r_seq =~ tr/acgtACGT/tgcaTGCA/;
 # print join(" ",$seq,$r_seq),"\n";
  return $r_seq;
}

