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
echo "Job id: ${SLURM_JOB_ID}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

export CARLA_PORT=$((65000+${SLURM_ARRAY_TASK_ID}))
export CARLA_SIF=/cluster/apps/dev/carla/carla_latest.sif

# ---

mkdir worker-${SLURM_ARRAY_TASK_ID}
cd worker-${SLURM_ARRAY_TASK_ID}

echo Starting server
singularity exec --nv \
  $CARLA_SIF \
  /home/carla/CarlaUE4.sh \
    -RenderOffScreen \
    -carla-rpc-port=$CARLA_PORT \
  &

CARLA_PID=$!

sleep 10
echo Starting client
singularity run --nv --pwd /code $CLIENT_SIF $CLIENT_COMMAND

echo Killing $CARLA_PID
kill $CARLA_PID

echo Bye
