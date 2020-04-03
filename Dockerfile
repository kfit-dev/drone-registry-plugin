FROM alpine:3 as alpine
RUN apk add -U --no-cache ca-certificates

FROM golang as golang

WORKDIR /src

ENV GOPATH ""
ENV CGO_ENABLED 0

ADD go.mod .
ADD go.sum .
RUN go mod download
ADD . .
RUN go build -o drone-registry-plugin

FROM scratch

EXPOSE 3000

ENV DRONE_DEBUG=false
ENV DRONE_ADDRESS=:3000
ENV GODEBUG netdns=go

COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=golang /src/drone-registry-plugin /bin/

ENTRYPOINT ["/bin/drone-registry-plugin"]