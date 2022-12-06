#! /usr/bin/bash
#SBATCH --job-name="CarlaSim"
#SBATCH --partition=GPUQ
#SBATCH --account=share-ie-idi
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --array=0-0
#SBATCH --gres=gpu:1

# Brukes m. forsiktighet:
##SBATCH --exclusive

cd ${SLURM_SUBMIT_DIR}
echo "Jobbnummer: ${SLURM_JOB_ID}"
echo "Task-id innad i array: ${SLURM_ARRAY_TASK_ID}"

mkdir worker-${SLURM_ARRAY_TASK_ID}
cd worker-${SLURM_ARRAY_TASK_ID}

export CARLA_PORT=65005

echo Starting server
singularity exec --nv \
  /cluster/apps/dev/carla/carla_latest.sif \
  /home/carla/CarlaUE4.sh \
    -RenderOffScreen \
    -carla-rpc-port=$CARLA_PORT \
  &

CARLA_PID=$!

sleep 10
echo Starting client
singularity run --nv --pwd /code ../carlo.sif python -m src.scripts.idun "$(pwd)"

echo Killing $CARLA_PID
kill $CARLA_PID

echo Bye
