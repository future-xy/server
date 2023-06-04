# # generate Dockerfile.compose (only run once)
# python3 compose.py \
# --backend pytorch \
# --repoagent checksum \
# --container-version 22.08 \
# --dry-run

# must provide a tag
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi
TAG=$1

set -e
# build tritonserver (core)
cd ../core/
bash build.sh
cp -u ./build/install/lib/libtritonserver.so ../server/
cd ../server/

# build pytorch_backend
cd ../pytorch_backend/
bash build.sh
cp -r -u ./build/install/backends/pytorch ../server/
cp -u ./build/Phantom-component/phantom_checkpoint/libphantom_checkpoint.so ../server/pytorch/
cd ../server/

# copy scheduling.proto
cp ~/Phantom-dev/GPU-serverless/pkg/scheduler/proto/scheduling.proto .

# /home/sl/.conda/envs/triton_dev/bin/python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. scheduling.proto
docker build -t futurexy/tritonserver-sb:$TAG -f Dockerfile.compose .
docker push futurexy/tritonserver-sb:$TAG