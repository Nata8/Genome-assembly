#!/bin/bash
#PBS -N FLYE
#PBS -l select=1:ncpus=64:mem=400gb:scratch_local=100gb
#PBS -l walltime=60:00:00
#PBS -m n

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/brno2/home/oluksan/data/Nanopore_zcats
OUTPUT=/storage/brno2/home/oluksan/data/scripts

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

#loads the application modules
module add flye-2.9

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# copy input file
# if the copy operation fails, issue error message and exit
cp $DATADIR/porechop_output.fastq  $SCRATCHDIR || { echo >&2 "Error while copying input file(s)!"; exit 2; }
cp -r $OUTPUT/flye_out  $SCRATCHDIR 

# move into scratch directory
cd $SCRATCHDIR

# if the calculation ends with an error, issue error message an exit
flye --nano-raw porechop_output.fastq --out-dir flye_out --genome-size 1g --threads 64 --iterations 5 || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; }

# move results to DATADIR
ls -Rl $SCRATCHDIR > $OUTPUT/outfiles_flye.txt
cp -r $SCRATCHDIR/flye_out $OUTPUT

# clean the SCRATCH directory
clean_scratch
