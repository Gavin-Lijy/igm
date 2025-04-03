#!/bin/bash
#SBATCH --job-name=ipycluster
#SBATCH --mail-user=bonimba@g.ucla.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --time=48:59:59
#SBATCH --partition=cpu
#SBATCH --chdir=/home/jl9324/env/download/igm/HPC_scripts
#SBATCH --output=out_engines
#SBATCH --error=err_engines
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=100G
#SBATCH --cpus-per-task=1
#SBATCH --export=ALL

export PATH="/home/jl9324/miniforge3/envs/IGM/bin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/home/jl9324/env/download/bin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/opt/slurm/22.05.8/bin:/opt/slurm/22.05.8/sbin:/home/jl9324/bin:/home/jl9324/.local/bin:/usr/local/bin:/home/jl9324/env/download/sratoolkit.3.2.1-ubuntu64/bin:/home/jl9324/miniforge3/condabin:/opt/software/spack/bin:/usr/share/lmod/lmod/libexec:/usr/bin:/usr/local/sbin:/usr/sbin"
# ulimit -s 8192

# Let the scheduler setup finish
sleep 10
MONITOR=$(command -v monitor_process)

if [[ ! -z "$MONITOR" ]]; then
    mpirun --map-by :OVERSUBSCRIBE -n 100 monitor_process --wtype W ipengine
else
    mpirun --map-by :OVERSUBSCRIBE -n 2 ipengine
fi
