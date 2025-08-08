# Etapa 1: Builder
FROM gcc:14 as builder

# Instala dependências necessárias
RUN apt-get update && \
    apt-get install -y curl zip unzip tar git libssl-dev build-essential pkg-config

# Instala CMake 3.31.2 manualmente
WORKDIR /tmp
RUN curl -LO https://github.com/Kitware/CMake/releases/download/v3.31.2/cmake-3.31.2-linux-x86_64.sh && \
    chmod +x cmake-3.31.2-linux-x86_64.sh && \
    ./cmake-3.31.2-linux-x86_64.sh --skip-license --prefix=/usr/local

# Instala o vcpkg
WORKDIR /
RUN git clone https://github.com/microsoft/vcpkg.git && \
    ./vcpkg/bootstrap-vcpkg.sh

# Define variáveis de ambiente
ENV VCPKG_ROOT=/vcpkg
ENV CMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake

# Cria diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências via vcpkg
RUN ./vcpkg/vcpkg install crow nlohmann-json

# Compila o projeto
RUN cmake -Bbuild -S. -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE && \
    cmake --build build

# Etapa 2: Runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/build/aqui_tem_sabor /app/
COPY config/settings.json /app/config/settings.json

EXPOSE 18080

CMD ["./aqui_tem_sabor"]
