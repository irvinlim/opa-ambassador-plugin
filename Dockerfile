FROM golang:1.12 as build

WORKDIR /go/src/github.com/irvinlim/opa-ambassador-plugin

ADD . .
RUN go build -o /go/bin/app ./cmd/opa-ambassador-plugin/...

FROM gcr.io/distroless/base
COPY --from=build /go/bin/app /
ENTRYPOINT ["/app"]
