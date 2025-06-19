# ----- STAGE 1: Build -----
FROM golang:1.20-alpine AS builder

# Cài git và các công cụ cần thiết
RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o main .

# ----- STAGE 2: Runtime -----
FROM alpine:latest

WORKDIR /root/

# Copy file thực thi từ builder
COPY --from=builder /app/main .

EXPOSE 3000

CMD ["./main"]
