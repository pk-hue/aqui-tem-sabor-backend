FROM alpine:latest

RUN apk add --no-cache g++ cmake make git openssl-dev

WORKDIR /app

COPY . .

RUN cmake -Bbuild -H. && cmake --build build

EXPOSE 18080

CMD ["./build/seu-executavel"]

