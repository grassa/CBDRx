./vcf2binary.pl <lbimpute/POP.geno.lbimp.vcf | cut -f 6- | tr '\t' ' ' | grep -v n | sort | uniq -c | sort -k1,1nr >patterncounts

./vcf2binary.pl <lbimpute/POP.geno.lbimp.vcf | cut -f 6- | tr '\t' ' ' | sort | uniq -c | sort -k1,1nr >patterncounts2

