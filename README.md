# opa-ambassador-plugin

This is a fork of [opa-istio-plugin](https://github.com/open-policy-agent/opa-istio-plugin), modified to support the gRPC protobuf that [Ambassador](https://www.getambassador.io/) uses.

The image is also available on Docker Hub. To use the image:

```
docker pull irvinlim/opa-ambassador-plugin
``` 

## Overview

OPA-Ambassador extends OPA with a gRPC server that implements the [Envoy External
Authorization
API](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/security/ext_authz_filter.html).
You can use this version of OPA to enforce fine-grained, context-aware access
control policies at the Istio Proxy layer without modifying your microservice.

This version of OPA specifically supports [Ambassador's Authorization](https://github.com/datawire/ambassador/blob/22c7771cabf308ef5fc0fc4c6eee788777761855/api/envoy/service/auth/v2/external_auth.proto) 
protobuf service, which is frustratingly slightly different from the one that OPA-Istio uses.  

## Integration with Ambassador

See <https://www.getambassador.io/reference/services/auth-service/>.

## Configuration

To deploy OPA-Istio include the following container in your Kubernetes Deployments:

```yaml
containers:
- image: irvinlim/opa-ambassador-plugin
  imagePullPolicy: IfNotPresent
  name: opa-istio
  volumeMounts:
  - mountPath: /config
    name: opa-istio-config
  args:
  - run
  - --server
  - --config-file=/config/config.yaml
```

The OPA-Istio configuration file should be volume mounted into the container. Add the following volume to your Kubernetes Deployments:

```yaml
volumes:
- name: opa-istio-config
  configMap:
    name: opa-istio-config
```

The OPA-Ambassador plugin supports the following configuration fields:

| Field | Required | Description |
| --- | --- | --- |
| `plugins["ambassador_ext_authz_grpc"].addr` | No | Set listening address of Envoy External Authorization gRPC server. This must match the value configured in the Envoy Filter resource. Default: `:9191`. |
| `plugins["ambassador_ext_authz_grpc"].path` | No | Specifies the hierarchical policy decision path. The policy decision can either be a `boolean` or an `object`. If boolean, `true` indicates the request should be allowed and `false` indicates the request should be denied. If the policy decision is an object, it **must** contain the `allowed` key set to either `true` or `false` to indicate if the request is allowed or not respectively. It can optionally contain a `headers` field to send custom headers to the downstream client or upstream. An optional `body` field can be included in the policy decision to send a response body data to the downstream client. Also an optional `http_status` field can be included to send a HTTP response status code to the downstream client other than `403 (Forbidden)`. Default: `ambassador/authz/allow`.|
| `plugins["ambassador_ext_authz_grpc"].dry-run` | No | Configures the Envoy External Authorization gRPC server to unconditionally return an `ext_authz.CheckResponse.Status` of `google_rpc.Status{Code: google_rpc.OK}`. Default: `false`. |
|`plugins["ambassador_ext_authz_grpc"].enable-reflection`| No | Enables gRPC server reflection on the Envoy External Authorization gRPC server. Default: `false`. |

If the configuration does not specify the `path` field, `ambassador/authz/allow` will be considered as the default policy decision path. `data.ambassador.authz.allow` will be the name of the policy decision to query in the default case.

The `dry-run` parameter is provided to enable you to test out new policies. You can set `dry-run: true` which will unconditionally allow requests. Decision logs can be monitored to see what "would" have happened. This is especially useful for initial integration of OPA or when policies undergo large refactoring.

The `enable-reflection` parameter registers the Envoy External Authorization gRPC server with reflection. After enabling server reflection, a command line tool such as [grpcurl](https://github.com/fullstorydev/grpcurl) can be used to invoke RPC methods on the gRPC server. See [gRPC Server Reflection Usage](#grpc-server-reflection-usage) section for more details.

An example of a rule that returns an object that not only indicates if a request is allowed or not but also provides optional response headers, body and HTTP status that can be sent to the downstream client or upstream can be seen below in the [Example Policy with Object Response](#example-policy-with-object-response) section.

## Dependencies

Dependencies are managed with [Modules](https://github.com/golang/go/wiki/Modules).
If you need to add or update dependencies, modify the `go.mod` file or
use `go get`. More information is available [here](https://github.com/golang/go/wiki/Modules#how-to-upgrade-and-downgrade-dependencies). Finally commit all changes to the repository.

---

For more information, see the original [opa-istio-plugin README](https://github.com/open-policy-agent/opa-istio-plugin/blob/master/README.md).
