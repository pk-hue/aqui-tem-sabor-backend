FROM debian:bullseye

# Instale o GCC, Crow, nlohmann, etc
RUN apt-get update && \
    apt-get install -y g++ cmake git libssl-dev

# Copie seu código para a imagem
WORKDIR /app
COPY . .

# Compile seu projeto
RUN g++ -std=c++17 -O2 main.cpp -o aqui_tem_sabor

# Exponha a porta
EXPOSE 8080

# Rode o binário
CMD ["./aqui_tem_sabor"]