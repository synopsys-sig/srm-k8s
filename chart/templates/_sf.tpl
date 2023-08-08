{{- define "srm-sf.scanSvcName" -}}
{{- printf "%s-cnc-scan-service" .Release.Name }}
{{- end }}

{{- define "srm-sf.storageSvcName" -}}
{{- printf "%s-cnc-storage-service" .Release.Name }}
{{- end -}}

{{- define "srm-sf.cacheSvcName" -}}
{{- printf "%s-cnc-cache-service" .Release.Name }}
{{- end -}}

{{- define "srm-sf.scanSvcUrl" -}}
{{- printf "http://%s:9998" (include "srm-sf.scanSvcName" .) }}
{{- end }}

{{- define "srm-sf.storageSvcUrl" -}}
{{- printf "http://%s:9998" (include "srm-sf.storageSvcName" .) }}
{{- end -}}

{{- define "srm-sf.svc-job" -}}
{{- printf "%s-internal-svc-job" ((include "srm.fullname" .) | trunc 45 | trimSuffix "-") }}
{{- end -}}

{{- define "srm-sf.svc-job-labels" -}}
helm.sh/chart: {{ include "srm.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ include "srm-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: configuration
{{- end }}