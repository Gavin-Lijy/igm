# This script prepares the controller/engines environment, using the MONITOR option 
# which allows to keep track of how the tasks are split among the different engines
# On the top of this, the serial IGM job will be submitted

# number of workers
NTASKS=100
# memory per worker
MEM=$2
# walltime
WTIME=$3
# conda env to use
CONDA=$4
# scheduler memory, usual a little larger than workers
SMEM=$5

let NTOT=${NTASKS}+1
if [[ -z "$2" ]]; then
    MEM=20G
fi
if [[ -z "$3" ]]; then
    WTIME=200:59:59
fi

if [[ -z "$4" ]]; then
    CONDA=py3
fi

if [[ -z "$5" ]]; then
    SMEM=25G
fi

echo "requesting ${NTASKS} processes, ${MEM} per cpu, walltime: ${WTIME}" 

CURRDIR=`pwd`

TMPFILE=`mktemp` || exit 1
# write the slurm script
cat > $TMPFILE <<- EOF
#!/bin/bash
#$ -M bonimba@g.ucla.edu
#$ -m ea
#$ -N ipycontroller
#$ -l h_data=${SMEM}
#$ -l h_rt=${WTIME}
#$ -l highp
#$ -cwd
#$ -o out_controller
#$ -e err_controller
#$ -V 

export PATH="$PATH"
ulimit -s 8192


cd $SGE_O_WORKDIR

# myip=\$(getent hosts \$(hostname) | awk '{print \$1}')
myip=\$(hostname -I | cut -d' ' -f1)
MONITOR=$(command -v monitor_process)
if [[ ! -z "$MONITOR" ]]; then
    monitor_process --wtype S ipcontroller --nodb --ip=\$myip 
else
    ipcontroller --nodb --ip=\$myip
fi
EOF

# cat $TMPFILE >> 'script1.txt'

SCHEDJOB=$(sbatch $TMPFILE | awk '{print $4}')
echo 'scheduler job submitted:' $SCHEDJOB

TMPFILE=`mktemp` || exit 1
# write the slurm script
cat > $TMPFILE <<- EOF
#!/bin/bash
#$ -M bonimba@g.ucla.edu
#$ -m ea
#$ -N ipycluster
#$ -l h_data=${MEM}
#$ -l h_rt=${WTIME}
#$ -l highp
#$ -cwd
#$ -o out_engines
#$ -e err_engines
#$ -V
#$ -pe dc* ${NTASKS} 


export PATH="$PATH"
ulimit -s 8192

cd $SGE_O_WORKDIR

# let the scheduler setup finish
sleep 10
MONITOR=$(command -v monitor_process)
if [[ ! -z "$MONITOR" ]]; then
    mpirun --n ${NTASKS} monitor_process --wtype W ipengine
else
    mpirun --map-by :OVERSUBSCRIBE --n ${NTASKS} ipengine
fi
# add --map-by :OVERSUBSCRIBE to allow more than one process per core

EOF

#cat $TMPFILE
sleep 1
cat $TMPFILE >> 'script_engines.sh'

echo "The engines will start only after the controller job $SCHEDJOB starts..."

echo "Need to manually submit $NTASKS engines on the top of the controller, by executing the script_engines.sh script"
