#!/bin/bash
#SBATCH -N 8
#SBATCH -n 256
#SBATCH -t 0:30:00
#DW jobdw type=scratch access_mode=striped capacity=400GiB

###
###  Before launching, ensure that $SCRATCH/1stripe has a stripe width of 1 and
###  $SCRATCH/4stripe has a stripe width of 4.
###

NPROCS=256
FILE_SIZE=13958643712 # 13.0 GiB

export DARSHAN_DISABLE=1

IOR_OPTS=( "-o $DW_JOB_STRIPED/testFile -F"
           "-o $SCRATCH/1stripe/testFile -F"
           "-o $SCRATCH/4stripe/testFile" )

for options in "${IOR_OPTS[@]}"; do
    BLKSIZE=8388608
    if [[ "$options" == *$DW_JOB_STRIPED* ]]; then
        fs_tag="dw"
    else
        fs_tag="lustre"
    fi

    if [[ "$options" == *-F* ]]; then
        fpp_tag="fpp"
    else
        fpp_tag="ssf"
    fi
    while [ $BLKSIZE -ge 8192 ]; do
        SEGCT=$((FILE_SIZE / NPROCS / BLKSIZE))
        set -x
        srun -N 8 -n $NPROCS \
            ~/bin/ior \
            -t $BLKSIZE \
            -b $BLKSIZE \
            -s $SEGCT \
            -e \
            -w \
            $options \
            -O "memoryPerNode=90%,repetitions=3" \
            2>&1 | tee "$SLURM_SUBMIT_DIR/out.${fs_tag}-${fpp_tag}.${BLKSIZE}"
        set +x
        BLKSIZE=$((BLKSIZE / 2))
    done
done
