# Etapa 1: Builder
FROM gcc:14 as builder

# Instala dependências necessárias para compilar e rodar o vcpkg
RUN apt-get update && \
    apt-get install -y cmake git libssl-dev curl zip unzip tar

# Instala o vcpkg
RUN git clone https://github.com/microsoft/vcpkg.git && \
    ./vcpkg/bootstrap-vcpkg.sh

# Define variáveis de ambiente para o vcpkg
ENV VCPKG_ROOT=/vcpkg
ENV CMAKE_TOOLCHAIN_FILE=/vcpkg/scripts/buildsystems/vcpkg.cmake

# Instala as libs necessárias com o vcpkg
RUN ./vcpkg/vcpkg install crow nlohmann-json

# Cria diretório de trabalho
WORKDIR /app

# Copia todos os arquivos do projeto
COPY . .

# Compila o projeto com o cmake usando o vcpkg
RUN cmake -Bbuild -S. -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE && \
    cmake --build build

# Etapa 2: Runtime
FROM debian:bookworm-slim

# Instala dependências em tempo de execução
RUN apt-get update && apt-get install -y libssl3 && rm -rf /var/lib/apt/lists/*

# Cria diretório onde o executável vai rodar
WORKDIR /app

# Copia o binário já compilado
COPY --from=builder /app/build/aqui_tem_sabor /app/

# Copia o JSON de configuração
COPY config/settings.json /app/config/settings.json

# Expõe a porta usada pelo app (ajuste se for diferente)
EXPOSE 18080

# Comando de inicialização
CMD ["./aqui_tem_sabor"]
