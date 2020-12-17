cat red/in/scaffolds_FINAL.racon11.pilon.fa | ./fasta_gaps_to_bed.pl | awk '{print $0"\t"gap}' >chimera/scaffolds_FINAL.racon11.pilon.gaps.bed
cat red/out/scaffolds_FINAL.racon11.pilon.rpt | sed -e "s/^>//" | tr ':' '\t' | tr '-' '\t' | awk '{print $0"\trepeat"}' >chimera/scaffolds_FINAL.racon11.pilon.rpt.bed
cat <( cat chimera/scaffolds_FINAL.racon11.pilon.gaps.bed | awk '{print $0"\tlowdepth"}' ) <( cat chimera/scaffolds_FINAL.racon11.pilon.rpt.bed ) | sort -k1,1 -k2,2 | awk '{print $1"\t"$2"\t"$3"\t"$4}' >chimera/scaffolds_FINAL.racon11.pilon.gaps_rpt.bed
bedtools intersect -a chimera/scaffolds_FINAL.racon11.pilon.rpt.bed -b chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed.breaks -wao | awk '$9 != 0' | grep break >chimera/rpts_in_breaks
bedtools intersect -a chimera/scaffolds_FINAL.racon11.pilon.gaps.bed -b chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed.breaks -wao | awk '$9 != 0' | grep break >chimera/gaps_in_breaks
while read line; do grep "$line" chimera/gaps_in_breaks | sort -k8,8nr | head -n 1 ; done<chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed.breaks >chimera/gaps_in_breaks_longest
while read line; do grep "$line" chimera/rpts_in_breaks | sort -k8,8nr | head -n 1 ; done<chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed.breaks >chimera/rpts_in_breaks_longest
cat <(cut -f 4-6 chimera/gaps_in_breaks_longest ) <(cut -f 5-7 chimera/rpts_in_breaks_longest) | sort | uniq -c | awk '$1==1 {print $2"\t"$3"\t"$4}' >chimera/rpts_in_breaks_no_gaps.list
while read line; do grep "$line" chimera/rpts_in_breaks_longest ; done<chimera/rpts_in_breaks_no_gaps.list >chimera/rpts_in_breaks_no_gaps

cat chimera/gaps_in_breaks_longest chimera/rpts_in_breaks_no_gaps | cut -f 1-3 | sort -k1,1 -k2,2n >chimera/break_scaffolds_here

cat red/in/scaffolds_FINAL.racon11.pilon.fa | fasta1line | paste - - | awk '{print $1"\t1\t"length($2)}' | sed -e "s/^>//" >chimera/scaffold_lengths.bed
cat chimera/break_scaffolds_here | cut -f 1 | sort | uniq >chimera/break_scaffolds_here.list

while read line; do grep "$line" chimera/scaffold_lengths.bed >>chimera/break_scaffolds_lengths.bed; done<chimera/break_scaffolds_here.list

bedtools subtract -a chimera/break_scaffolds_lengths.bed -b chimera/break_scaffolds_here >chimera/retain_scaffold_parts.bed
cat <(cat chimera/break_scaffolds_here.list | sort | uniq ) <(cut -f 1 chimera/scaffold_lengths.bed | sort | uniq ) | sort | uniq -c | awk '$1==1{print $2}' >chimera/nobreak_scaffolds.list
while read line; do grep "$line" chimera/scaffold_lengths.bed; done<chimera/nobreak_scaffolds.list >>chimera/retain_scaffold_parts.bed

bedtools getfasta -fi red/in/scaffolds_FINAL.racon11.pilon.fa -bed chimera/retain_scaffold_parts.bed -fo chimera/scaffolds_FINAL.racon11.pilon.breakchimera.fa

grep "^>" chimera/scaffolds_FINAL.racon11.pilon.breakchimera.fa | sed -e "s/^>//" >chimera/scaffolds_FINAL.racon11.pilon.breakchimera.headers

while read line; do scf=$(echo $line | tr ':' '\t' | tr '-' '\t' | awk '{print $1}'); start=$(echo $line | tr ':' '\t' | tr '-' '\t' | awk '{print $2}'); end=$(echo $line | tr ':' '\t' | tr '-' '\t' | awk '{print $3}'); cat chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed | awk -v C="$scf" -v S="$start" -v E="$end" -v H="$line" '$1==C && $2>=S && $3<=E {print H"\t"$2+1-S"\t"$3+1-S"\t"$4"\t"$5"\t"$6"\t"$7}'; done<chimera/scaffolds_FINAL.racon11.pilon.breakchimera.headers >chimera/scaffolds_FINAL.racon11.pilon.breakchimera.gmap.bed

cat <(cat ref/scaffolds_FINAL.racon11.pilon.breakchimera.fa.fai | cut -f 1 ) <(cat gmap/all_scaffold_chimera_slayed_placements.bed | cut -f 1 | sort | uniq ) | sort | uniq -c | awk '$1==1 {print $2}' | tr '_' '\t' | awk '$5 != 1 {print $1"_"$2"_"$3"_"$4"\t"$5"\t"$6}' >chimera/missing_but_should_have_gmap

bedtools intersect -a chimera/missing_but_should_have_gmap -b chimera/k31.POP.TO.scaffolds_FINAL.racon11.pilon.geno.lbi_in.lbimp.vcf.patterns.gmap.bed -wao | awk '{print $1"_"$2"_"$3"\t1\t"$3-$2"\t"$7"\t"$8"\t"$9"\t"$10}' >chimera/missing_but_should_have_gmap.gmap.bed

cat chimera/missing_but_should_have_gmap.gmap.bed >>gmap/all_scaffold_chimera_slayed_placements.bed

