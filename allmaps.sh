#!/bin/bash
lg=$1
export PYTHONPATH=~/install:$PYTHONPATH

rm -rf $lg

mkdir $lg

cat rp4contigs.bed | grep "^$lg""_" >$lg/rp4contigs.bed

cat cs_rp4.contigs.fasta | fasta1line | paste - - | grep "^>$lg""_" | awk '{print $1"\n"$2}' >$lg/cs_rp4.contigs.fasta

cp weights.txt $lg/weights.txt

cd $lg/

python -m jcvi.assembly.allmaps path --cpus=14 rp4contigs.bed cs_rp4.contigs.fasta 1>$lg.allmaps.o 2>$lg.allmaps.e
python -m jcvi.assembly.allmaps estimategaps --links=2 --maxsize=500000 --verbose rp4contigs.bed 2>$lg.allmaps.estimategaps.e
mv rp4contigs.estimategaps.agp rp4contigs.chr.agp
python -m jcvi.assembly.allmaps build rp4contigs.bed cs_rp4.contigs.fasta

cd ..

