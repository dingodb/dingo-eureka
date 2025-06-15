# Use Docker Image

We provide docker images of different operating systems to support compilation and development.including

- rocky8.9
- rocky9.3
- ubuntu22.04
- ubuntu24.04
- manylinux_2_34

## Build dingo-base image

To build the `dingo-base` image for different operating systems, use the following commands. This `dingo-base` image will serve as the foundation for building the `dingo-eureka` image.

``````
cd dingofs 

docker build docker/base/rocky8/  -t dingodatabase/dingo-base:rocky8

docker build docker/base/rocky9/ -t dingodatabase/dingo-base:rocky9

docker build docker/base/ubuntu22/  -t dingodatabase/dingo-base:ubuntu2204

docker build docker/base/ubuntu24/  -t dingodatabase/dingo-base:ubuntu2404

docker build docker/base/manylinux/ -t dingodatabase/dingo-base:manylinux_2_34

``````

## Build dingo-eureka docker image

To build the `dingo-eureka` image for different operating systems, use the following commands. The `dingo-eureka` image is based on the `dingo-base` image and can be further used to create the `dingofs`, `dingo-store`, and `dingo-sdk` images.

### Build for DingoFS
``````
cd dingofs 

docker build -f docker/eureka/rocky8/Dockerfile-fs -t dingodatabase/dingo-eureka:rocky8-fs .

docker build -f docker/eureka/rocky9/Dockerfile-fs -t dingodatabase/dingo-eureka:rocky9-fs .

docker build -f docker/eureka/ubuntu22/Dockerfile-fs -t dingodatabase/dingo-eureka:ubuntu2204-fs .

docker build -f docker/eureka/ubuntu24/Dockerfile-fs -t dingodatabase/dingo-eureka:ubuntu2404-fs .

``````

### Build For Dingo-Store
``````
cd dingofs 

docker build -f docker/eureka/rocky8/Dockerfile-store -t dingodatabase/dingo-eureka:rocky8-store .

docker build -f docker/eureka/rocky9/Dockerfile-store -t dingodatabase/dingo-eureka:rocky9-store .

docker build -f docker/eureka/ubuntu22/Dockerfile-store -t dingodatabase/dingo-eureka:ubuntu2204-store .

docker build -f docker/eureka/ubuntu24/Dockerfile-store -t dingodatabase/dingo-eureka:ubuntu2404-store .

``````
### Build For Dingo-Sdk
``````
cd dingofs 

docker build -f docker/eureka/manylinux/Dockerfile -t dingodatabase/dingo-eureka:manylinux_2_34 .
``````
