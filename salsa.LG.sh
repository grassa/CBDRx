#!/bin/bash
lg=$1
ref="ref/scaffolds_FINAL.racon11.pilon.breakchimera.fa"
map="gmap/all_scaffold_chimera_slayed_placements.bed"
unplaced="gmap/unplaced.list"
ALIGNMENTSGLOBAL="bam_chimeraslay/rep/HiC_chimeraslay_rep1.bed"

mkdir salsaLG/$lg
cat $map | awk -v L="$lg" '$4==L {print $1}' | sort | uniq >salsaLG/$lg/placedscaffolds.list
join <(cat "salsaLG/$lg/placedscaffolds.list" "$unplaced" | cut -f 1 | sort -k 1b,1 ) \
     <(cat $ref.fai | sort -k1b,1 ) \
| awk '{print $1"\t1\t"$2}' >salsaLG/$lg/scaffolds.bed
cut -f 1 salsaLG/$lg/scaffolds.bed >salsaLG/$lg/scaffolds.list
cat $ref | grepFasta salsaLG/$lg/scaffolds.list >salsaLG/$lg/scaffolds.fasta
samtools faidx salsaLG/$lg/scaffolds.fasta
bedtools intersect -a "$ALIGNMENTSGLOBAL" -b salsaLG/$lg/scaffolds.bed >salsaLG/$lg/alignments.bed 


size=$(cat salsaLG/$lg/scaffolds.bed | awk '{s+=$3} END {print s}')

cd salsaLG/$lg/
mkdir salsa

ENZYME="GATC"
CONTIGS="scaffolds.fasta"
#GRAPH="gfa/cbdrx_all_nanopore.gfa"
ALIGNMENTS="alignments.bed"
OUT="salsa"

python ~/install/SALSA/run_pipeline.py \
-a $CONTIGS \
-l "$CONTIGS.fai" \
-b $ALIGNMENTS \
-o $OUT \
-e $ENZYME \
-i 3 \
-s $size \
1>$OUT.o \
2>$OUT.e

cd ../..
cat salsaLG/$lg/salsa/scaffolds_FINAL.agp \
| awk '$5 !~ /N/ {print $6"\t"$7"\t"$8"\t"$9"\t"$1"\t"$2"\t"$3"\t"$4"\t"$5}' \
>salsaLG/$lg/salsa/scaffolds_FINAL.agp.bed

bedtools intersect -a gmap/all_scaffold_chimera_slayed_placements.bed \
 -b salsaLG/$lg/salsa/scaffolds_FINAL.agp.bed -wo \
 >salsaLG/$lg/salsa/scaffolds_FINAL.agp.bed.gmap

#usage: run_pipeline.py [-h] -a ASSEMBLY -l LENGTH -b BED [-o OUTPUT]
#                       [-c CUTOFF] [-g GFA] [-u UNITIGS] [-t TENX] [-e ENZYME]
#                       [-i ITER] [-x DUP] [-s EXP] [-m CLEAN] [-p PRNT]
#
#SALSA Iterative Pipeline
#
#optional arguments:
#  -h, --help            show this help message and exit
#  -a ASSEMBLY, --assembly ASSEMBLY
#                        Path to initial assembly
#  -l LENGTH, --length LENGTH
#                        Length of contigs at start
#  -b BED, --bed BED     Bed file of alignments sorted by read names
#  -o OUTPUT, --output OUTPUT
#                        Output directory to put results
#  -c CUTOFF, --cutoff CUTOFF
#                        Minimum contig length to scaffold, default=1000
#  -g GFA, --gfa GFA     GFA file for assembly
#  -u UNITIGS, --unitigs UNITIGS
#                        The tiling of unitigs to contigs in bed format
#  -t TENX, --tenx TENX  10x links tab separated file, sorted by last columnls
#  -e ENZYME, --enzyme ENZYME
#                        Restriction Enzyme used for experiment
#  -i ITER, --iter ITER  Number of iterations to run, default = 3
#  -x DUP, --dup DUP     File containing duplicated contig information
#  -s EXP, --exp EXP     Expected Genome size of the assembled genome
#  -m CLEAN, --clean CLEAN
#                        Set this option to "yes" if you want to find
#                        misassemblies in input assembly
#  -p PRNT, --prnt PRNT  Set this option to "yes" if you want to output the
#                        scaffolds sequence and agp file for each iteration
