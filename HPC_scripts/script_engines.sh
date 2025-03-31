#!/bin/bash
#$ -M bonimba@g.ucla.edu
#$ -m ea
#$ -N ipycluster
#$ -l h_data=20G
#$ -l h_rt=200:59:59
#$ -l highp
#$ -cwd
#$ -o out_engines
#$ -e err_engines
#$ -V
#$ -pe dc* 100 


export PATH="/home/jl9324/miniforge3/envs/IGM/bin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/home/jl9324/env/download/bin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/opt/slurm/22.05.8/bin:/opt/slurm/22.05.8/sbin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/home/jl9324/miniforge3/condabin:/opt/software/spack/bin:/usr/share/lmod/lmod/libexec:/usr/bin:/usr/local/sbin:/usr/sbin"
ulimit -s 8192

cd 

# let the scheduler setup finish
sleep 10
MONITOR=
if [[ ! -z "" ]]; then
    mpirun --n 100 monitor_process --wtype W ipengine
else
    mpirun --map-by :OVERSUBSCRIBE --n 100 ipengine
fi
# add --map-by :OVERSUBSCRIBE to allow more than one process per core

