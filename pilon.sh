#!/bin/bash

#ref="miniasm/cbdrx_all_nanopore.Rc2s1000.racon.3.fa"
ref="racon/rp5b.fasta.9.fasta"
#bwa index $ref
#samtools faidx $ref

#for lib in "MJ-2lib"
#do
#	read1="cleandata/$lib.EC.paired.A.fastq.gz"
#	read2="cleandata/$lib.EC.paired.B.fastq.gz"
#	bampre="bam/$lib.TO.rp5b.fasta.9"
#	bam="$bampre.bam"
#
#	bwa mem -t 56 -M $ref \
#	$read1 $read2 \
#	| samtools view -SubT $ref - \
#	| samtools sort -@8 -m 20G - $bampre
#
#	samtools index $bam
#done
#bedtools makewindows -g racon/rp5b.fasta.9.fasta.fai -w 4000000 -s 3999000 >pilon/rp5b.fasta.9.windows

cat pilon/rp5b.fasta.9.windows | awk '{print $1":"$2"-"$3}' | parallel -j 54 "./pilon.par.sh $ref {}"
ls -thor pilon/parts/*/pilon.fasta | tr '\/' '\t' | awk '{print $10}' >pilon/parts.success ; ls -thor pilon/parts/*/pilon.out | tr '\/' '\t' | awk '{print $10}' >pilon/parts.all ; cat pilon/parts.all pilon/parts.success | sort | uniq -c | awk '$1<2 {print $2}' >pilon/parts.fail

cat pilon/rp5b.fasta.9.windows | awk '{print $1":"$2"-"$3}' | parallel -j 54 "./pilon.par.sh $ref {}"

cat pilon/parts.fail | grep ":0" | grep -v M | grep -v P | sed -e "s/:0/:1/" | parallel -j 56 "./pilon.par.sh racon/rp5b.fasta.9.fasta {}" ; cat pilon/parts.fail | grep -v ":0" | parallel -j 6 "./pilon.par.bigmem.sh racon/rp5b.fasta.9.fasta {}" ; echo "M:1-412422 P:1-152080" | tr ' ' '\n' | parallel -j 2 "./pilon.par.bigmem.sh racon/rp5b.fasta.9.fasta {}" ;

seq -w 1 10 | tr ' ' '\n' | parallel -j 10 "./order_pilon_out.sh {}"


#./cat_pilon.sh $ref.fai "pilon/scaffolds_FINAL.racon11.pilon.fasta"

	
