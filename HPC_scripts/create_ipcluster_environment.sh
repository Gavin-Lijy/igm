#!/bin/bash

# Number of workers
NTASKS=100
# Memory per worker
MEM_PER_TASK=2G
# Compute total memory
TOTAL_MEM=$((NTASKS * ${MEM_PER_TASK%G}))G
# Walltime
WTIME=48:59:59
# Conda environment (optional)
CONDA_ENV=py3
# Scheduler memory (larger than worker memory)
SCHEDULER_MEM=10G

echo "Requesting ${NTASKS} tasks, ${MEM_PER_TASK} per task, total memory: ${TOTAL_MEM}, walltime: ${WTIME}"

CURRDIR=$(pwd)
TMPFILE=$(mktemp) || exit 1

# -------------------
# SLURM Script for CONTROLLER
# -------------------
cat > $TMPFILE <<- EOF
#!/bin/bash
#SBATCH --job-name=ipycontroller
#SBATCH --mail-user=bonimba@g.ucla.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=${SCHEDULER_MEM}
#SBATCH --time=${WTIME}
#SBATCH --partition=cpu
#SBATCH --chdir=${CURRDIR}
#SBATCH --output=out_controller
#SBATCH --error=err_controller
#SBATCH --export=ALL

export PATH="$PATH"
ulimit -s 8192

echo "Starting IPython Controller..."
# myip=\$(getent hosts \$(hostname) | awk '{print \$1}')
# myip=\$(hostname -I | cut -d' ' -f1)
myip=0.0.0.0
MONITOR=\$(command -v monitor_process)

if [[ ! -z "\$MONITOR" ]]; then
    monitor_process --wtype S ipcontroller --nodb --ip=\$myip
else
    ipcontroller --nodb --ip=\$myip
fi
EOF


# Submit controller job
cat $TMPFILE >> 'script1.txt'
SCHEDJOB=$(sbatch $TMPFILE | awk '{print $4}')
echo "Scheduler job submitted: $SCHEDJOB"

# -------------------
# SLURM Script for ENGINES
# -------------------
TMPFILE=$(mktemp) || exit 1
cat > $TMPFILE <<- EOF
#!/bin/bash
#SBATCH --job-name=ipycluster
#SBATCH --mail-user=bonimba@g.ucla.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --mem=${TOTAL_MEM}      # Total memory = NTASKS * MEM_PER_TASK
#SBATCH --time=${WTIME}
#SBATCH --partition=cpu
#SBATCH --chdir=${CURRDIR}
#SBATCH --output=out_engines
#SBATCH --error=err_engines
#SBATCH --ntasks=${NTASKS}
#SBATCH --cpus-per-task=2
#SBATCH --export=ALL

export PATH="$PATH"
# ulimit -s 8192

# Let the scheduler setup finish
sleep 10
MONITOR=\$(command -v monitor_process)

if [[ ! -z "\$MONITOR" ]]; then
    mpirun --map-by :OVERSUBSCRIBE -n ${NTASKS} monitor_process --wtype W ipengine
else
    mpirun --map-by :OVERSUBSCRIBE -n ${NTASKS} ipengine
fi
EOF


#cat $TMPFILE
sleep 1
cat $TMPFILE >> 'script_engines.sh'

echo "The engines will start only after the controller job $SCHEDJOB starts..."

echo "Need to manually submit $NTASKS engines on the top of the controller, by executing the script_engines.sh script"