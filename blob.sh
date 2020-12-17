#!/bin/bash
#cat cbdrx.pilon.0.fa | parallel -j 54 --block 100k --recstart '>' --pipe blastn -evalue '1e-5' -outfmt '"6 qseqid staxids bitscore"' -db /opt/db/ncbi_nt/nt -query - >cbdrx.pilon.0.TO.nt.blobb6
#~/install/blobtools/blobtools map2cov -i cbdrx.pilon.0.fa -b MJ-350.bam -o MJ-350.cov
#~/install/blobtools/blobtools create -i cbdrx.pilon.0.fa -c MJ-350.cov.MJ-350.bam.cov -t cbdrx.pilon.0.TO.nt.blobb6 -o cbdrx.blob

~/install/blobtools/blobtools blobplot  -i cbdrx.blob.blobDB.json -m -o cbdrx.blobplot
~/install/blobtools/blobtools view -i cbdrx.blob.blobDB.json
cat cbdrx.blob.blobDB.table.txt | awk '$5>2 && $6=="Streptophyta" {print $1}'  >pass_blob.list
grepFasta pass_blob.list <cbdrx.pilon.0.fa | sed -e "s/Consensus_Consensus_Consensus_//" >cbdrx.pilon.pass_blob.fa

