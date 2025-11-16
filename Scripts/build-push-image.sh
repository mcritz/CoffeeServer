# YOLO a latest tag built locally (for ARM and X86_64) and push to the mcritz GHCR
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/mcritz/coffee-server:latest \
  --push .
