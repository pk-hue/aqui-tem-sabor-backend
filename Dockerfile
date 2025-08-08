FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    g++ \
    cmake \
    make \
    libboost-all-dev \
    git \
    curl \
    libssl-dev \
    ca-certificates

WORKDIR /app

COPY . .

RUN cmake . && make

CMD ["./aqui-tem-sabor"]
