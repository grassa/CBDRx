#!/bin/bash
ref=$1
k=31
base_dir="mccortexF1"
ref_base_name=$(basename $ref .fa)
ref_base_name=$(basename $ref_base_name .fasta)
bubble_vcf="$base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.norm.vcf"
pop_cov_vcf="$base_dir/vcfs/k$k.POP.TO.$ref_base_name.cov.vcf"
pop_geno_vcf="$base_dir/vcfs/k$k.POP.TO.$ref_base_name.geno.vcf"

parent1_ctx="mccortexF1/k$k/graphs/CD1.raw.ctx"
parent2_ctx="mccortexF1/k$k/graphs/CF2.raw.ctx"
F1_ctx="mccortexF1/k$k/graphs/F1.clean.ctx"


ls mccortexF1/k$k/graphs/*.ctx | parallel -j  12 "mccortex31 vcfcov -m 16G -r $ref $bubble_vcf {} 1>{}.cov.vcf 2>{}.cov.vcf.log"

column10s=""
coveragelist=""

for file in $parent1_ctx $parent2_ctx $F1_ctx
do 
  echo "$file"
  column10s+="$file.cov.vcf.c10 "
  coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}')
  coveragelist+="$coverage "
done

for file in $(ls mccortexF1/k$k/graphs/*.ctx | grep -v $parent1_ctx | grep -v $parent2_ctx | grep -v $F1_ctx)
do 
  echo "$file"
  column10s+="$file.cov.vcf.c10 "
  coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}')
  coveragelist+="$coverage "
done

coveragelist=$(echo "$coveragelist" | tr ' ' ',' | sed -e "s/,$//")
echo "coveragelist: $coveragelist"
echo "column10s: $column10s"

ls mccortexF1/k$k/graphs/*.cov.vcf | parallel -j 54 "grep -v '^##' <{} | cut -f 10 >{}.c10"
grep "^##" $F1_ctx.cov.vcf | grep -v "mean_read_length" >$pop_cov_vcf
cat mccortexF1/k$k/graphs/*.cov.vcf | grep "^##" | grep "mean_read_length" >>$pop_cov_vcf

grep -v "^##" $F1_ctx.cov.vcf | cut -f 1-9 >$F1_ctx.cov.vcf.c1_9
paste $F1_ctx.cov.vcf.c1_9 $column10s >>$pop_cov_vcf
mccortex31 vcfgeno -C $coveragelist -P 2 $pop_cov_vcf > $pop_geno_vcf


