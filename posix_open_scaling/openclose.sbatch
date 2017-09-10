#!/bin/bash
#SBATCH -N 512
#SBATCH -t 0:15:00

ior_bin="$HOME/bin/ior"

for nodes in 32 64 96 128 160 192 224 256 288 320 352 384 416 448 480 512
do
    fmt_nodes=$(printf "%04d" $nodes)
    for ppn in 64
    do
        fmt_ppn=$(printf "%02d" $ppn)
        srun -N $nodes -n $((nodes*ppn)) ${ior_bin} \
            -H \
            -k \
            -r \
            -o $SCRATCH/tmp.bin \
            -f $SLURM_SUBMIT_DIR/openclose.ior > ior-r.${fmt_nodes}x${fmt_ppn}.out
    done
done
