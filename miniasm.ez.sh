#!/bin/bash
#cat \
#rawdata/*.fastq \
#>miniasm/cbdrx_all_nanopore.fastq
#
#minimap2 -x ava-ont -I 60G -t 54 miniasm/cbdrx_all_nanopore.fastq miniasm/cbdrx_all_nanopore.fastq 2>miniasm/cbdrx_all_nanopore.paf.err | gzip -1 >miniasm/cbdrx_all_nanopore.paf.gz
#
#miniasm -R -c 2 -f miniasm/cbdrx_all_nanopore.fastq miniasm/cbdrx_all_nanopore.paf.gz 1>miniasm/cbdrx_all_nanopore.gfa 2>miniasm/cbdrx_all_nanopore.gfa.err
miniasm -R -c 2 -s 1000 -f miniasm/cbdrx_all_nanopore.fastq miniasm/cbdrx_all_nanopore.paf.gz 1>miniasm/cbdrx_all_nanopore.Rc2s1000.gfa 2>miniasm/cbdrx_all_nanopore.Rc2s1000.gfa.err

minimap2 -t 48 miniasm/cbdrx_all_nanopore.Rc2s1000.fa miniasm/cbdrx_pass_nanopore.fastq | racon -t 48 miniasm/cbdrx_pass_nanopore.fastq - miniasm/cbdrx_all_nanopore.Rc2s1000.fa miniasm/cbdrx_all_nanopore.Rc2s1000.racon.1.fa ; minimap2 -t 48 miniasm/cbdrx_all_nanopore.Rc2s1000.racon.1.fa miniasm/cbdrx_pass_nanopore.fastq | racon -t 48 miniasm/cbdrx_pass_nanopore.fastq - miniasm/cbdrx_all_nanopore.Rc2s1000.racon.1.fa miniasm/cbdrx_all_nanopore.Rc2s1000.racon.2.fa ; minimap2 -t 48 miniasm/cbdrx_all_nanopore.Rc2s1000.racon.2.fa miniasm/cbdrx_pass_nanopore.fastq | racon -t 48 miniasm/cbdrx_pass_nanopore.fastq - miniasm/cbdrx_all_nanopore.Rc2s1000.racon.2.fa miniasm/cbdrx_all_nanopore.Rc2s1000.racon.3.fa ;

#cat \
#rawdata/*pass.fastq \
#>miniasm/cbdrx_pass_nanopore.fastq
#
#minimap2 -x ava-ont -I 60G -t 54 miniasm/cbdrx_pass_nanopore.fastq miniasm/cbdrx_pass_nanopore.fastq 2>miniasm/cbdrx_pass_nanopore.paf.err | gzip -1 >miniasm/cbdrx_pass_nanopore.paf.gz
#
#miniasm -R -f miniasm/cbdrx_pass_nanopore.fastq miniasm/cbdrx_pass_nanopore.paf.gz 1>miniasm/cbdrx_pass_nanopore.gfa 2>miniasm/cbdrx_pass_nanopore.gfa.err
#cat miniasm/cbdrx_pass_nanopore.gfa | awk '/^S/{print ">"$2"\n"$3}' > miniasm/cbdrx_pass_nanopore.fa



#Usage: minimap2 [options] <target.fa>|<target.idx> [query.fa] [...]
#Options:
#  Indexing:
#    -H           use homopolymer-compressed k-mer
#    -k INT       k-mer size (no larger than 28) [15]
#    -w INT       minizer window size [10]
#    -I NUM       split index for every ~NUM input bases [4G]
#    -d FILE      dump index to FILE []
#  Mapping:
#    -f FLOAT     filter out top FLOAT fraction of repetitive minimizers [0.0002]
#    -g INT       stop chain enlongation if there are no minimizers in INT-bp [5000]
#    -r INT       bandwidth used in chaining and DP-based alignment [500]
#    -n INT       minimal number of minimizers on a chain [3]
#    -m INT       minimal chaining score (matching bases minus log gap penalty) [40]
#    -X           skip self and dual mappings (for the all-vs-all mode)
#    -p FLOAT     min secondary-to-primary score ratio [0.8]
#    -N INT       retain at most INT secondary alignments [5]
#    -G NUM       max intron length (only effective following -x splice) [200k]
#  Alignment:
#    -A INT       matching score [2]
#    -B INT       mismatch penalty [4]
#    -O INT[,INT] gap open penalty [4,24]
#    -E INT[,INT] gap extension penalty; a k-long gap costs min{O1+k*E1,O2+k*E2} [2,1]
#    -z INT       Z-drop score [400]
#    -s INT       minimal peak DP alignment score [80]
#    -u CHAR      how to find GT-AG. f:transcript strand, b:both strands, n:don't match GT-AG [n]
#  Input/Output:
#    -a           output in the SAM format (PAF by default)
#    -Q           don't output base quality in SAM
#    -R STR       SAM read group line in a format like '@RG\tID:foo\tSM:bar' []
#    -c           output CIGAR in PAF
#    -S           output the cs tag in PAF (cs encodes both query and ref sequences)
#    -t INT       number of threads [3]
#    -K NUM       minibatch size for mapping [200M]
#    --version    show version number
#  Preset:
#    -x STR       preset (recommended to be applied before other options) []
#                 map10k/map-pb: -Hk19 (PacBio/ONT vs reference mapping)
#                 map-ont: -k15 (slightly more sensitive than 'map10k' for ONT vs reference)
#                 asm5: -k19 -w19 -A1 -B19 -O39,81 -E3,1 -s200 -z200 (asm to ref mapping; break at 5% div.)
#                 asm10: -k19 -w19 -A1 -B9 -O16,41 -E2,1 -s200 -z200 (asm to ref mapping; break at 10% div.)
#                 ava-pb: -Hk19 -w5 -Xp0 -m100 -g10000 -K500m --max-chain-skip 25 (PacBio read overlap)
#                 ava-ont: -k15 -w5 -Xp0 -m100 -g10000 -K500m --max-chain-skip 25 (ONT read overlap)
#                 splice: long-read spliced alignment (see minimap2.1 for details)
#                 sr: short single-end reads without splicing (see minimap2.1 for details)
#
#See `man ./minimap2.1' for detailed description of command-line options.
