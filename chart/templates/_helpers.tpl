{{/*
Expand the name of the chart.
*/}}
{{- define "srm.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "srm.fullname" -}}
{{- $name := .Chart.Name }}
{{- if eq $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "srm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create NetworkPolicy port ranges.
*/}}
{{- define "netpolicy.ports" -}}
{{- $portData := . -}}
{{- if $portData.ports -}}
{{- if gt (len $portData.ports) 0 -}}
- ports:
{{- range $portData.ports }}
  - port: {{ . }}
    protocol: {{ $portData.protocol }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}