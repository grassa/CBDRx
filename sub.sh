#!/bin/bash
endr=$1
#seqtk sample -s 1111 tadpole/raw.1.fastq 0.3 >tadpole/sub.1.fastq
#seqtk sample -s 1111 tadpole/raw.2.fastq 0.3 >tadpole/sub.2.fastq

seqtk sample -s 1112 "tadpole/sub.$endr.fastq" 328000000 \
| paste - - - - \
| cut -d \: -f 4- \
| awk -v R="$endr" '{print "@SEQTX:000:SUBSAMPLE:"$1" "R":N:0\n"$3"\n"$4"\n"$5}' \
| gzip \
>"tadpole/F1.$endr.fastq.gz"


