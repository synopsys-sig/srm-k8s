# Make MinIO Available with your SRM Hostname

You can proxy MinIO by using the same hostname for both SRM and MinIO.

The following example uses hostname `srm.local` to make the `minio` K8s service available at http://srm.local/upload/. Note the use of the `use-regex` and `rewrite-target` annotations to drop "/upload/" when routing a request to the MinIO service.

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 500m
    nginx.ingress.kubernetes.io/rewrite-target: /$1
    nginx.ingress.kubernetes.io/use-regex: "true"
  name: minio
  namespace: srm
spec:
  ingressClassName: nginx
  rules:
  - host: srm.local
    http:
      paths:
      - backend:
          service:
            name: minio
            port:
              number: 9000
        path: /upload/(.*)
        pathType: ImplementationSpecific
```