#!/bin/bash
vcffmt=$1
vcfpart=$2
base_name=$(basename $vcffmt .vcf)
vcfin="lbimpute/parts/$vcfpart.$base_name.vcf"
vcfout="lbimpute/parts/$vcfpart.$base_name.lbimp.vcf"
cat $vcffmt | grep '^#' >"$vcfin"
cat $vcffmt | grep -v '^#' | awk -v P="$vcfpart" '$1==P' >>"$vcfin"

java -jar -Xmx8g bin/LB-Impute/LB-Impute.jar -method impute -f $vcfin -readerr 0.01 -genotypeerr 0.1 -recombdist 10000000 -window 7 -offspringimpute -minfraction 0.2 -parents CD1,CF2 -o $vcfout 1>"$vcfout.o" 2>"$vcfout.e"


