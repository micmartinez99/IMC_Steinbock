#!/bin/bash
#SBATCH --job-name=imc_pipeline
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 6
#SBATCH --mem=80G
#SBATCH --partition=general
#SBATCH --qos=general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=micmartinez@uchc.edu
#SBATCH --output imc_pipeline-%j.out
#SBATCH --error imc_pipeline-%j.err

#Load singularity 
module load singularity

# Set path to steinbock image
STEINBOCK_IMAGE="/home/FCAM/mmartinez/steinbock_0.16.1.sif"

#Move to data folder
DATADIR="/home/FCAM/mmartinez/imc_pipelineTest/data"
cd ${DATADIR}


# Preprocessing
singularity exec ${STEINBOCK_IMAGE} steinbock preprocess imc images --hpf 50

# Segmentation
singularity exec ${STEINBOCK_IMAGE} steinbock segment deepcell --app mesmer --minmax --preprocess preprocessing.yml

# Pixel intensity measurment
singularity exec ${STEINBOCK_IMAGE} steinbock measure intensities

# Get region properties
singularity exec ${STEINBOCK_IMAGE} steinbock measure regionprops

# Construct spatial grapsh
singularity exec ${STEINBOCK_IMAGE} steinbock measure neighbors --type expansion --dmax 4

# Data export
singularity exec ${STEINBOCK_IMAGE} steinbock export csv intensities regionprops -o cells.csv
singularity exec ${STEINBOCK_IMAGE} steinbock export graphs --format graphml --data intensities --data regionprops



