#!/bin/bash
#PBS -N PORECHOP_FASTQC
#PBS -l select=1:ncpus=32:mem=40gb:scratch_local=10gb
#PBS -l walltime=2:00:00
#PBS -M n

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/brno2/home/oluksan/data/Nanopore_zcats

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

#loads the application modules
module add fastQC-0.11.5

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# copy input file
# if the copy operation fails, issue error message and exit
cp $DATADIR/porechop_output.fastq  $SCRATCHDIR || { echo >&2 "Error while copying input file(s)!"; exit 2; }

# move into scratch directory
cd $SCRATCHDIR

# if the calculation ends with an error, issue error message an exit
fastqc porechop_output.fastq -t 32 -o /storage/brno2/home/oluksan/data/results || { echo >&2 "Calculation ended up erroneously (with a code $?) !!"; exit 3; }

# move the output to user's DATADIR or exit in case of failure
#cp dna_ilumina.out $DATADIR/ || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

# clean the SCRATCH directory
clean_scratch
