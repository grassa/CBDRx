#!/bin/bash
ref=$1
k=31
base_dir="mccortexF1"
ref_base_name=$(basename $ref .fa)
ref_base_name=$(basename $ref_base_name .fasta)
bubble_vcf="$base_dir/vcfs/k$k.joint.bub.gz.TO.$ref_base_name.norm.vcf"
pop_cov_vcf="$base_dir/vcfs/k$k.PARENTS.TO.$ref_base_name.cov.vcf"
pop_geno_vcf="$base_dir/vcfs/k$k.PARENTS.TO.$ref_base_name.geno.vcf"

parent1_ctx="mccortexF1/k$k/graphs/CD1.raw.ctx"
parent2_ctx="mccortexF1/k$k/graphs/CF2.raw.ctx"


echo "$parent1_ctx $parent2_ctx" | tr ' ' '\n' | parallel -j 2 "mccortex31 vcfcov -m 16G -r $ref $bubble_vcf {} 1>{}.cov.vcf 2>{}.cov.vcf.log"

column10s=""
coveragelist=""

for file in $parent1_ctx $parent2_ctx
do 
  echo "$file"
  column10s+="$file.cov.vcf.c10 "
  coverage=$(cat "$file.view" | grep "kmer coverage" | awk '{ printf("%.0f\n", $3)}')
  coveragelist+="$coverage "
done


coveragelist=$(echo "$coveragelist" | tr ' ' ',' | sed -e "s/,$//")
echo "coveragelist: $coveragelist"
echo "column10s: $column10s"

cat mccortexF1/k31/graphs/CF2.raw.ctx.cov.vcf | grep -v '^##' | cut -f 10 >mccortexF1/k31/graphs/CF2.raw.ctx.cov.vcf.c10
cat mccortexF1/k31/graphs/CD1.raw.ctx.cov.vcf | grep -v '^##' | cut -f 10 >mccortexF1/k31/graphs/CD1.raw.ctx.cov.vcf.c10
grep "^##" $parent1_ctx_cov_vcf | grep -v "mean_read_length" >$pop_cov_vcf
cat $parent1_ctx_cov_vcf $parent2_ctx_cov_vcf | grep "^##" | grep "mean_read_length" >>$pop_cov_vcf

grep -v "^##" $parent1_ctx_cov_vcf | cut -f 1-9 >$parent1_ctx_cov_vcf.c1_9
paste mccortexF1/k31/graphs/CD1.raw.ctx.cov.vcf.c1_9 mccortexF1/k31/graphs/CD1.raw.ctx.cov.vcf.c10 mccortexF1/k31/graphs/CF2.raw.ctx.cov.vcf.c10 >>mccortexF1/vcfs/k31.PARENTS.TO.cs10.cov.vcf
mccortex31 vcfgeno -C $coveragelist -P 2 $pop_cov_vcf > $pop_geno_vcf


