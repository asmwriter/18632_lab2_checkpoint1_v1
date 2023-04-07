#!/bin/csh -f

cd /afs/ece.cmu.edu/usr/araghave/18632/18632_lab2_checkpoint1_v1/aes_128_lab2_v2

#This ENV is used to avoid overriding current script in next vcselab run 
setenv SNPS_VCSELAB_SCRIPT_NO_OVERRIDE  1

/afs/ece/support/synopsys/synopsys.release/T-Foundation/vcs/T-2022.06/linux64/bin/vcselab $* \
    -o \
    simv \
    -nobanner \

cd -

