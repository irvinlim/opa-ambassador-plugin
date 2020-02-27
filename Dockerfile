FROM golang:1.12 as build

WORKDIR /go/src/github.com/open-policy-agent/opa-istio-plugin

ADD . .
RUN go build -o /go/bin/app ./cmd/opa-istio-plugin/...

FROM gcr.io/distroless/base
COPY --from=build /go/bin/app /
ENTRYPOINT ["/app"]
