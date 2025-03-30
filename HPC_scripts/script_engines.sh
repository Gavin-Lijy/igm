#!/bin/bash
#$ -M bonimba@g.ucla.edu
#$ -m ea
#$ -N ipycluster
#$ -l h_data=2G
#$ -l h_rt=200:59:59
#$ -l highp
#$ -cwd
#$ -o out_engines
#$ -e err_engines
#$ -V
#$ -pe dc* 100 


export PATH="/home/jl9324/miniforge3/envs/igm/bin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/home/jl9324/.vscode-server/cli/servers/Stable-384ff7382de624fb94dbaf6da11977bba1ecd427/server/bin/remote-cli:/home/jl9324/miniforge3/condabin:/home/jl9324/.local/bin:/home/jl9324/bin:/opt/software/spack/bin:/opt/slurm/22.05.8/bin:/opt/slurm/22.05.8/sbin:/usr/share/lmod/lmod/libexec:/usr/bin:/bin:/usr/local/sbin:/usr/sbin"
ulimit -s 8192

cd 

# let the scheduler setup finish
sleep 10
MONITOR=
if [[ ! -z "" ]]; then
    mpirun --n 100 monitor_process --wtype W ipengine
else
    mpirun --n 100 ipengine
fi

