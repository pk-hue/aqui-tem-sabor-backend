# Etapa de build
FROM gcc:13 AS builder

WORKDIR /app

# Instala dependências
RUN apt-get update && apt-get install -y git cmake ninja-build zip unzip curl

# Instala o vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git
RUN ./vcpkg/bootstrap-vcpkg.sh

# Copia o projeto
COPY . .

# Instala as libs
RUN ./vcpkg/vcpkg install crow nlohmann-json

# Compila o projeto
RUN cmake -Bbuild -S. -DCMAKE_TOOLCHAIN_FILE=/app/vcpkg/scripts/buildsystems/vcpkg.cmake -DCMAKE_BUILD_TYPE=Release \
 && cmake --build build --config Release

# Etapa final (imagem enxuta com só o executável e settings.json)
FROM debian:bullseye-slim

WORKDIR /app

# Instala dependências mínimas para rodar o binário
RUN apt-get update && apt-get install -y libstdc++6 ca-certificates && apt-get clean

# Copia binário compilado
COPY --from=builder /app/build/aqui_tem_sabor ./aqui_tem_sabor

# Copia config
COPY config ./config

# Expõe porta (se necessário)
EXPOSE 18080

# Comando de execução
CMD ["./aqui_tem_sabor"]
