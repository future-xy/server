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
cd ../server/

# copy scheduling.proto
cp ~/Phantom-dev/GPU-serverless/pkg/scheduler/proto/scheduling.proto .

# copy libs
mkdir -p lib
cp $HOME/.conda/envs/torch_dev/lib/libmkl_intel_lp64.so.1 ./lib/
cp $HOME/.conda/envs/torch_dev/lib/libmkl_gnu_thread.so.1 ./lib/
cp $HOME/.conda/envs/torch_dev/lib/libmkl_core.so.1 ./lib/
cp /usr/lib/x86_64-linux-gnu/openmpi/lib/libmpi_cxx.so.40.20.1 ./lib/
cp /lib/x86_64-linux-gnu/libmpi_cxx.so.40 ./lib/
cp -r /usr/local/cuda/extras/CUPTI/lib64 ./lib/

# /home/sl/.conda/envs/triton_dev/bin/python -m grpc_tools.protoc -I. --python_out=. --grpc_python_out=. scheduling.proto
docker build -t futurexy/tritonserver-sb:$TAG -f Dockerfile.compose .
docker push futurexy/tritonserver-sb:$TAG