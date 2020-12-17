#!/bin/bash
prefix=$1
indir="cleandata"
reads1="$indir/$prefix.1.fastq.gz"
reads2="$indir/$prefix.2.fastq.gz"
#fragment_size 285
#Lread1+Lread2 250
# sep           35
reads_mean=35
reads_stddev=86
outdir="tadpole"
echo "reads_mean:$reads_mean reads_stddev:$reads_stddev"
#reads1=$(ls cleandata/"$prefix"*.1.fastq  | tr '\n' ',' | sed -e "s/,$//")
#reads2=$(echo $reads1 | sed -e "s/\.1\.fastq/\.2\.fastq/g")
#reads1=$(ls cleandata/"$prefix".1.fastq  | tr '\n' ',' | sed -e "s/,$//")
#reads2=$(echo $reads1 | sed -e "s/\.1\.fastq/\.2\.fastq/g")

/usr/local/bin/ErrorCorrectReads.pl                   \
    PHRED_ENCODING=33 READS_OUT="$outdir/$prefix.EC"  \
    MAX_MEMORY_GB=200                                 \
    PAIRED_READS_A_IN="$reads1"                       \
    PAIRED_READS_B_IN="$reads2"                       \
    PAIRED_SEP="$reads_mean"                          \
    PAIRED_STDEV="$reads_stddev" PLOIDY=2 THREADS=56  \
    REMOVE_DODGY_READS=1                              \
    KEEP_KMER_SPECTRA=1                               \
1>$outdir/$prefix.EC.stdout 2>$outdir/$prefix.EC.stderr

