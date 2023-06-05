# python3 compose.py \
# --backend python \
# --backend pytorch \
# --backend tensorflow2 \
# --backend onnxruntime \
# --repoagent checksum \
# --container-version 22.08 \
# --dry-run

# must input tag
if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

# set tag
TAG=$1

set -e

# build core
cd ../core
bash build.sh
cd ../server

# build pytorch backend
cd ../pytorch_backend
bash build.sh
cd ../server

# copy to compose
cp -u ../core/build/install/lib/libtritonserver.so .
cp -r -u ../pytorch_backend/build/install/backends/pytorch .

# build server
docker build -t futurexy/tritonserver-baseline:$TAG -f Dockerfile.compose .
docker push futurexy/tritonserver-baseline:$TAG