~/install/mccortex/scripts/make-pipeline.pl 19,25,31,47 mccortexF1 F1.samples >mccortexF1.mk
make -f mccortexF1.mk CTXDIR=~/install/mccortex/ MEM=200G NTHREADS=54 MIN_FRAG_LEN=100 MAX_FRAG_LEN=600 USE_LINKS=yes bubbles

