#! /usr/bin/bash
#SBATCH --job-name="CarlaSim"
#SBATCH --partition=GPUQ
#SBATCH --account=share-ie-idi
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=1
#SBATCH --array=0-9
#SBATCH --gres=gpu:1

cd ${SLURM_SUBMIT_DIR}
echo "Job id: ${SLURM_JOB_ID}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

export CARLA_PORT=$((65000+${SLURM_ARRAY_TASK_ID}))

mkdir worker-${SLURM_ARRAY_TASK_ID}
cd worker-${SLURM_ARRAY_TASK_ID}

echo Starting server
singularity exec --nv \
  carla.sif \
  /home/carla/CarlaUE4.sh \
    -RenderOffScreen \
    -carla-rpc-port=$CARLA_PORT \
  &

CARLA_PID=$!
sleep 10

echo Starting client
singularity exec --pwd /code \
  carlo.sif \
  python -m src.scripts.idun $PWD/output

echo Killing $CARLA_PID
kill $CARLA_PID

echo Bye
