#!/bin/bash
ref=$1
base_dir="mccortexF1"
ref_base_name=$(basename $ref .fa)
ref_base_name=$(basename $ref_base_name .fasta)

for k in 31
do
	
	~/install/mccortex/scripts/cortex_print_flanks.sh $base_dir/k$k/bubbles_plain/joint.bub.gz > $base_dir/k$k/bubbles_plain/joint.bub.gz.flanks
	
	bwa mem -t 56 $ref $base_dir/k$k/bubbles_plain/joint.bub.gz.flanks > $base_dir/k$k/bubbles_plain/joint.bub.gz.TO.$ref_base_name.sam
	
	mccortex31 calls2vcf -F $base_dir/k$k/bubbles_plain/joint.bub.gz.TO.$ref_base_name.sam -o $base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.vcf $base_dir/k$k/bubbles_plain/joint.bub.gz $ref
	
	~/install/mccortex/libs/biogrok/vcf-sort $base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.vcf >$base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.sort.vcf
	
	bin/bcftools-1.5/bcftools norm --fasta-ref $ref -d any $base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.sort.vcf | ~/install/mccortex/libs/biogrok/vcf-rename | ./vcf_norm_cleanup.pl >$base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.norm.vcf
	
done
	
