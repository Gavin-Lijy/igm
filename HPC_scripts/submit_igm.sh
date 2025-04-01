#!/bin/bash

#----------------------------------------#
#- IGM SUBMISSION SCRIPT, multi-threaded JOB
#----------------------------------------#

#!/bin/bash
#SBATCH --job-name=igm
#SBATCH --mail-user=bonimba@g.ucla.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=200G
#SBATCH --time=48:59:59
#SBATCH --partition=cpu
#SBATCH --output=out_igm
#SBATCH --error=err_igm
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

