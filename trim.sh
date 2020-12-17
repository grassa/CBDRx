#!/bin/bash
prefix="$1"
echo "$prefix"
## TRIM READS
java -jar bin/Trimmomatic-0.32/trimmomatic-0.32.jar \
PE \
-threads 16 \
-phred33 \
rawdata/$prefix.1.fastq.gz \
rawdata/$prefix.2.fastq.gz \
cleandata/$prefix.1.fastq.gz \
cleandata/$prefix.unpaired.1.fastq.gz \
cleandata/$prefix.2.fastq.gz \
cleandata/$prefix.unpaired.2.fastq.gz \
ILLUMINACLIP:IlluminaContaminants.fa:2:30:10 \
LEADING:3 \
TRAILING:3 \
SLIDINGWINDOW:4:10 \
MINLEN:36 
	
