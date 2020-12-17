#!/bin/bash 

bin/bbmap/bbmerge-auto.sh \
in1=tadpole/F1.EC.paired.A.fastq \
in2=tadpole/F1.EC.paired.B.fastq \
out=tadpole/tadpole.M.fastq.gz \
outu1=tadpole/tadpole.1.fastq.gz \
outu2=tadpole/tadpole.2.fastq.gz \
usejni=t adapter=default rem k=50 extend2=50 ecct prefilter=20 verystrict=t \
1>merge.o 2>merge.e


