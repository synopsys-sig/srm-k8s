{{- define "srm.sizing.reference" -}}
{{-     if (eq nil .Values.sizing.reference) -}}
{{-         $ref := dict -}}
{{-         $size := .Values.sizing.size -}}
{{-         if (eq $size "Small") -}}
{{-             $ref = dict 
                    "webCPU" "4000m"
                    "webMemory" "16384Mi"
                    "webStorage" "64Gi"
                    "webConcurrentAnalyses" "8"
                    "webConnectionPoolSize" "12"
                    "webJobLimitCPU" "4000"
                    "webJobLimitMemory" "4000"
                    "webJobLimitDB" "4000"
                    "webJobLimitDisk" "4000"
                    "toolServiceCPU" "1000m"
                    "toolServiceMemory" "1024Mi"
                    "toolServiceReplicas" "1"
-}}
{{-         else if (eq $size "Medium") -}}
{{-             $ref = dict 
                    "webCPU" "8000m"
                    "webMemory" "32768Mi"
                    "webStorage" "128Gi"
                    "webConcurrentAnalyses" "16"
                    "webConnectionPoolSize" "24"
                    "webJobLimitCPU" "8000"
                    "webJobLimitMemory" "8000"
                    "webJobLimitDB" "8000"
                    "webJobLimitDisk" "8000"
                    "toolServiceCPU" "2000m"
                    "toolServiceMemory" "2048Mi"
                    "toolServiceReplicas" "2"
-}}
{{-         else if (eq $size "Large") -}}
{{-             $ref = dict 
                    "webCPU" "16000m"
                    "webMemory" "65536Mi"
                    "webStorage" "256Gi"
                    "webConcurrentAnalyses" "32"
                    "webConnectionPoolSize" "48"
                    "webJobLimitCPU" "16000"
                    "webJobLimitMemory" "16000"
                    "webJobLimitDB" "16000"
                    "webJobLimitDisk" "16000"
                    "toolServiceCPU" "2000m"
                    "toolServiceMemory" "2048Mi"
                    "toolServiceReplicas" "3"
-}}
{{-         else if (eq $size "ExtraLarge") -}}
{{-             $ref = dict 
                    "webCPU" "32000m"
                    "webMemory" "131072Mi"
                    "webStorage" "512Gi"
                    "webConcurrentAnalyses" "64"
                    "webConnectionPoolSize" "96"
                    "webJobLimitCPU" "32000"
                    "webJobLimitMemory" "32000"
                    "webJobLimitDB" "32000"
                    "webJobLimitDisk" "32000"
                    "toolServiceCPU" "2000m"
                    "toolServiceMemory" "2048Mi"
                    "toolServiceReplicas" "4"
-}}
{{-         else -}}
{{-             $ref = dict 
                    "webCPU" .Values.web.resources.limits.cpu 
                    "webMemory" .Values.web.resources.limits.memory
                    "webStorage" .Values.web.persistence.size
                    "webConcurrentAnalyses" .Values.web.props.limits.analysis.concurrent
                    "webConnectionPoolSize" .Values.web.props.limits.database.poolSize
                    "webJobLimitCPU" .Values.web.props.limits.jobs.cpu
                    "webJobLimitMemory" .Values.web.props.limits.jobs.memory
                    "webJobLimitDB" .Values.web.props.limits.jobs.database
                    "webJobLimitDisk" .Values.web.props.limits.jobs.disk
                    "toolServiceCPU" .Values.to.resources.limits.cpu
                    "toolServiceMemory" .Values.to.resources.limits.memory
                    "toolServiceReplicas" .Values.to.service.numReplicas
-}}
{{-         end -}}
{{-         $unusedAlways := set .Values.sizing "reference" $ref -}}
{{-     end -}}
{{- end -}}

{{- define "srm.sizing.webCPU" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webCPU -}}
{{- end -}}

{{- define "srm.sizing.webMemory" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webMemory -}}
{{- end -}}

{{- define "srm.sizing.webStorage" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webStorage -}}
{{- end -}}

{{- define "srm.sizing.webConcurrentAnalyses" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webConcurrentAnalyses -}}
{{- end -}}

{{- define "srm.sizing.webConnectionPoolSize" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webConnectionPoolSize -}}
{{- end -}}

{{- define "srm.sizing.webJobLimitCPU" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webJobLimitCPU -}}
{{- end -}}

{{- define "srm.sizing.webJobLimitMemory" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webJobLimitMemory -}}
{{- end -}}

{{- define "srm.sizing.webJobLimitDB" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webJobLimitDB -}}
{{- end -}}

{{- define "srm.sizing.webJobLimitDisk" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.webJobLimitDisk -}}
{{- end -}}

{{- define "srm.sizing.toolServiceCPU" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.toolServiceCPU -}}
{{- end -}}

{{- define "srm.sizing.toolServiceMemory" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.toolServiceMemory -}}
{{- end -}}

{{- define "srm.sizing.toolServiceReplicas" -}}
{{- include "srm.sizing.reference" . -}}
{{- .Values.sizing.reference.toolServiceReplicas -}}
{{- end -}}