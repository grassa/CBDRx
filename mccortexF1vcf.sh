#!/bin/bash

###19### #~/install/mccortex/scripts/cortex_print_flanks.sh mccortexF1/k19/bubbles_plain/joint.bub.gz > mccortexF1/k19/bubbles_plain/joint.bub.gz.flanks
###19### #bwa mem -t 56 ref/mg_0.22.fasta mccortexF1/k19/bubbles_plain/joint.bub.gz.flanks > mccortexF1/k19/bubbles_plain/joint.bub.gz.sam
###19### #mccortex31 calls2vcf -F mccortexF1/k19/bubbles_plain/joint.bub.gz.sam -o mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.vcf mccortexF1/k19/bubbles_plain/joint.bub.gz ref/mg_0.22.fasta
###19### #~/install/mccortex/libs/biogrok/vcf-sort mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.vcf >mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.sort.vcf
###19### #bin/bcftools-1.5/bcftools norm --fasta-ref ref/mg_0.22.fasta -d any mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.sort.vcf | ~/install/mccortex/libs/biogrok/vcf-rename >mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.norm.vcf
###19### #
###19### #mccortex31 vcfcov -r ref/mg_0.22.fasta mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.norm.vcf mccortexF1/k19/graphs/F1.raw.ctx >mccortexF1/k19/vcfcov/F1.raw.joint.bub.gz.TO.mg_0.22.norm.cov.vcf
###19### #
###19### #mccortex31 build -m 100G -t 56 -k 19 -s parentCD1 -2 cleandata/parentCD1.1.fastq.gz:cleandata/parentCD1.2.fastq.gz mccortexF1/k19/graphs/parentCD1.raw.ctx 2>mccortexF1/k19/graphs/parentCD1.raw.ctx.log
###19### #mccortex31 build -m 100G -t 56 -k 19 -s parentCF2 -2 cleandata/parentCF2.1.fastq.gz:cleandata/parentCF2.2.fastq.gz mccortexF1/k19/graphs/parentCF2.raw.ctx 2>mccortexF1/k19/graphs/parentCF2.raw.ctx.log
###19### #ls bam/*.dedup.bam | tr '/' '\t' | tr '.' '\t' | cut -f 2 | sort | uniq | parallel -j 7 "mccortex31 build -m 25G -t 8 -k 19 -s {} -i bam/{}.dedup.bam mccortexF1/k19/graphs/{}.raw.ctx 2>mccortexF1/k19/graphs/{}.raw.ctx.log"
###19### #ls mccortexF1/k19/graphs/*.raw.ctx | parallel -j 8 "mccortex31 view {} 1>{}.view 2>{}.view.log"
###19### #mccortex31 vcfcov -m 50G -r ref/mg_0.22.fasta mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.norm.vcf mccortexF1/k19/graphs/parentCD1.raw.ctx mccortexF1/k19/graphs/parentCF2.raw.ctx mccortexF1/k19/graphs/F1.raw.ctx >mccortexF1/k19/vcfcov/parentsF1.raw.joint.bub.gz.TO.mg_0.22.norm.cov.vcf
###19### #mccortex31 vcfgeno -C 33,32,175 -P 2 -l mccortexF1/k19/vcfcov/parentsF1.raw.joint.bub.gz.TO.mg_0.22.norm.cov.vcf 1>mccortexF1/k19/vcfcov/parentsF1.raw.joint.bub.gz.TO.mg_0.22.norm.geno.vcf 2>mccortexF1/k19/vcfcov/parentsF1.raw.joint.bub.gz.TO.mg_0.22.norm.geno.vcf.log
###19### #ls mccortexF1/k19/graphs/*.raw.ctx | parallel -j 8 "mccortex31 vcfcov -m 20G -r ref/mg_0.22.fasta mccortexF1/vcfs/joint.bub.gz.TO.mg_0.22.norm.vcf {} 1>{}.cov.vcf 2>{}.cov.vcf.log"
###19### 
###19### column10s=""
###19### coveragelist=""
###19### 
###19### for file in $(ls mccortexF1/k19/graphs/*.raw.ctx | grep parent ); do echo "$file"; column10s+="$file.cov.vcf.c10 "; coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}'); coveragelist+="$coverage "; done
###19### for file in $(ls mccortexF1/k19/graphs/*.raw.ctx | grep "F1.raw.ctx" ); do echo "$file"; column10s+="$file.cov.vcf.c10 "; coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}'); coveragelist+="$coverage "; done
###19### for file in $(ls mccortexF1/k19/graphs/*.raw.ctx | grep -v parent | grep -v "F1.raw.ctx"); do echo "$file"; column10s+="$file.cov.vcf.c10 "; coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}'); coveragelist+="$coverage "; done
###19### coveragelist=$(echo "$coveragelist" | tr ' ' ',' | sed -e "s/,$//")
###19### 
###19### ls mccortexF1/k19/graphs/*.raw.ctx.cov.vcf | parallel -j 54 "grep -v '^##' <{} | cut -f 10 >{}.c10"
###19### grep "^##" mccortexF1/k19/graphs/F1.raw.ctx.cov.vcf | grep -v "mean_read_length" >mccortexF1/k19/vcfcov/POP.cov.vcf
###19### cat mccortexF1/k19/graphs/*.raw.ctx.cov.vcf | grep "^##" | grep "mean_read_length" >>mccortexF1/k19/vcfcov/POP.cov.vcf
###19### 
###19### grep -v "^##" mccortexF1/k19/graphs/F1.raw.ctx.cov.vcf | cut -f 1-9 >mccortexF1/k19/graphs/F1.raw.ctx.cov.vcf.c1_9
###19### paste mccortexF1/k19/graphs/F1.raw.ctx.cov.vcf.c1_9 $column10s >>mccortexF1/k19/vcfcov/POP.cov.vcf
###19### mccortex31 vcfgeno -C $coveragelist -P 2 mccortexF1/k19/vcfcov/POP.cov.vcf > mccortexF1/k19/vcfcov/POP.geno.vcf
for k in 25 31
do
ls bam/*.dedup.bam | tr '/' '\t' | tr '.' '\t' | cut -f 2 | sort | uniq | parallel -j 5 "mccortex31 build -m 40G -t 12 -k $k -s {} -i bam/{}.dedup.bam mccortexF1/k$k/graphs/{}.raw.ctx 2>mccortexF1/k$k/graphs/{}.raw.ctx.log"
mccortex31 build -m 100G -t 56 -k "$k" -s parentCD1 -2 cleandata/parentCD1.1.fastq.gz:cleandata/parentCD1.2.fastq.gz mccortexF1/k"$k"/graphs/parentCD1.raw.ctx 2>mccortexF1/k"$k"/graphs/parentCD1.raw.ctx.log
mccortex31 build -m 100G -t 56 -k "$k" -s parentCF2 -2 cleandata/parentCF2.1.fastq.gz:cleandata/parentCF2.2.fastq.gz mccortexF1/k"$k"/graphs/parentCF2.raw.ctx 2>mccortexF1/k"$k"/graphs/parentCF2.raw.ctx.log
done

for k in 47
do
ls bam/*.dedup.bam | tr '/' '\t' | tr '.' '\t' | cut -f 2 | sort | uniq | parallel -j 5 "mccortex63 build -m 40G -t 12 -k $k -s {} -i bam/{}.dedup.bam mccortexF1/k$k/graphs/{}.raw.ctx 2>mccortexF1/k$k/graphs/{}.raw.ctx.log"
mccortex63 build -m 100G -t 56 -k "$k" -s parentCD1 -2 cleandata/parentCD1.1.fastq.gz:cleandata/parentCD1.2.fastq.gz mccortexF1/k"$k"/graphs/parentCD1.raw.ctx 2>mccortexF1/k"$k"/graphs/parentCD1.raw.ctx.log
mccortex63 build -m 100G -t 56 -k "$k" -s parentCF2 -2 cleandata/parentCF2.1.fastq.gz:cleandata/parentCF2.2.fastq.gz mccortexF1/k"$k"/graphs/parentCF2.raw.ctx 2>mccortexF1/k"$k"/graphs/parentCF2.raw.ctx.log
done

