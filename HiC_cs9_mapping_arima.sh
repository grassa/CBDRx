#! /bin/bash

##########################################
# ARIMA GENOMICS MAPPING PIPELINE 100617 #
##########################################

#Below find the commands used to map HiC data. 

#Replace the variables at the top with the correct paths for the locations of files/programs on your system. 

#This bash script will map one paired end HiC dataset (read1 & read2 fastqs). Feel to modify and multiplex as you see fit to work with your volume of samples and system. 

##########################################
# Commands #
##########################################

SRA='sunrise_001_S3HiC'
LABEL='HiC_cs9'
BWA='/usr/local/bin/bwa'
SAMTOOLS='/home/cg/marigene/bin/samtools-1.4.1/samtools'
IN_DIR='/home/cg/cannabis_genome/goldenpath2/rawdata/'
REF='/home/cg/cannabis_genome/goldenpath2/ref/9.pilon.fasta'
FAIDX="$REF.fai"
RAW_DIR='/home/cg/cannabis_genome/goldenpath2/bam_cs9/raw'
FILT_DIR='/home/cg/cannabis_genome/goldenpath2/bam_cs9/filt'
FILTER='/home/cg/cannabis_genome/goldenpath2/bin/filter_five_end.pl'
COMBINER='/home/cg/cannabis_genome/goldenpath2/bin/two_read_bam_combiner.pl'
PICARD='/home/cg/.linuxbrew/Cellar/picard-tools/2.5.0/share/java/picard.jar'
TMP_DIR='/home/cg/cannabis_genome/goldenpath2/tmp_cs9'
PAIR_DIR='/home/cg/cannabis_genome/goldenpath2/bam_cs9/pair'
REP_DIR='/home/cg/cannabis_genome/goldenpath2/bam_cs9/rep'
REP_LABEL=$LABEL\_rep1
MERGE_DIR='/home/cg/cannabis_genome/goldenpath2/bam_cs9/merge'
MAPQ_FILTER=10


echo "### Step 0: Check output directories exist & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR

echo "### Step 1.A: FASTQ to BAM (1st)"
$BWA mem -t 56 -B 6 $REF $IN_DIR/$SRA\_R1.fastq.gz | $SAMTOOLS view -Sb - > $RAW_DIR/$SRA\_1.bam

echo "### Step 1.B: FASTQ to BAM (2nd)"
$BWA mem -t 56 -B 6 $REF $IN_DIR/$SRA\_R2.fastq.gz | $SAMTOOLS view -Sb - > $RAW_DIR/$SRA\_2.bam

echo "### Step 2.A: Filter 5' end (1st)"
$SAMTOOLS view -h $RAW_DIR/$SRA\_1.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_1.bam

echo "### Step 2.B: Filter 5' end (2nd)"
$SAMTOOLS view -h $RAW_DIR/$SRA\_2.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_2.bam

echo "### Step 3A: Pair reads & mapping quality filter"
perl $COMBINER $FILT_DIR/$SRA\_1.bam $FILT_DIR/$SRA\_2.bam $SAMTOOLS $MAPQ_FILTER | $SAMTOOLS view -bS -t $FAIDX - | $SAMTOOLS sort -o $TMP_DIR/$SRA.bam -

echo "### Step 3.B: Add read group"
java -Xmx2g -jar $PICARD AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none

###############################################################################################################################################################
###                                           How to Accommodate Technical Replicates                                                                       ###
### This pipeline is currently built for processing a single sample with one read1 and read2 fastq file.                                                    ###
### Technical replicates (eg. one library split across multiple lanes) should be merged before running the MarkDuplicates command.                          ###
### If this step is run, the names and locations of input files to subsequent steps will need to be modified in order for subsequent steps to run correctly.###          
### The code below is an example of how to merge technical replicates.                                                                                      ###
###############################################################################################################################################################
#       REP_NUM=X #number of the technical replicate set e.g. 1
#       REP_LABEL=$LABEL\_rep$REP_NUM
#       INPUTS_TECH_REPS=('bash' 'array' 'of' 'bams' 'from' 'replicates') #BAM files you want combined as technical replicates
#   example bash array - INPUTS_TECH_REPS=('INPUT=A.L1.bam' 'INPUT=A.L2.bam' 'INPUT=A.L3.bam')
#       java -Xms4G -Xmx4G -jar $PICARD MergeSamFiles $INPUTS_TECH_REPS OUTPUT=$TMP_DIR/$REP_LABEL.bam USE_THREADING=TRUE ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT

echo "### Step 4: Mark duplicates"
java -Xms24G -XX:-UseGCOverheadLimit -Xmx24G -jar $PICARD MarkDuplicates INPUT=$PAIR_DIR/$SRA.bam OUTPUT=$REP_DIR/$REP_LABEL.bam METRICS_FILE=$REP_DIR/metrics.$REP_LABEL.txt TMP_DIR=$TMP_DIR ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE

$SAMTOOLS index $REP_DIR/$REP_LABEL.bam 

echo "Finished Mapping Pipeline"

#########################################################################################################################################
###                                       How to Accommodate Biological Replicates                                                    ###
### This pipeline is currently built for processing a single sample with one read1 and read2 fastq file.                              ###
### Biological replicates (eg. multiple libraries made from the same sample) should be merged before proceeding with subsequent steps.###
### The code below is an example of how to merge biological replicates.                                                               ###
#########################################################################################################################################
#
#       INPUTS_BIOLOGICAL_REPS=('bash' 'array' 'of' 'bams' 'from' 'replicates') #BAM files you want combined as biological replicates
#   example bash array - INPUTS_BIOLOGICAL_REPS=('INPUT=A_rep1.bam' 'INPUT=A_rep2.bam' 'INPUT=A_rep3.bam')
#
#       java -Xms4G -Xmx4G -jar $PICARD MergeSamFiles $INPUTS_BIOLOGICAL_REPS OUTPUT=$MERGE_DIR/$LABEL.bam USE_THREADING=TRUE ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT
#
#       $SAMTOOLS index $MERGE_DIR/$LABEL.bam



