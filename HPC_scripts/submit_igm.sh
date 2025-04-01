#!/bin/bash

#----------------------------------------#
#- IGM SUBMISSION SCRIPT, multi-threaded JOB
#----------------------------------------#

#!/bin/bash
#SBATCH --job-name=ipycluster
#SBATCH --mail-user=bonimba@g.ucla.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=200G
#SBATCH --time=48:59:59
#SBATCH --partition=cpu
#SBATCH --chdir=$PWD
#SBATCH --output=out_engines
#SBATCH --error=err_engines
#SBATCH --ntasks=100
#SBATCH --cpus-per-task=1  # One CPU per MPI task
#SBATCH --export=ALL

export PATH="$PATH"
ulimit -s 8192

# -----------------------
# print JOB ID, can be useful for keeping track of status
echo $JOB_ID

# print PATH pointing to directory the job is run from
echo $SGE_O_WORKDIR


# shared memory parallelization: same node, more cores, export number of threads
export OMP_NUM_THREADS=2
echo "submitting IGM optimization..."

# execute job
igm-run igm_config.json >> igm_output.txt

