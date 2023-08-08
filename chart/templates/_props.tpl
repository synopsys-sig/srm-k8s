{{/*
Returns the system properties that include the main and database properties files.
*/}}
{{- define "srm-web.database.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-database=%s" (include "srm-web.database.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the ML properties file.
*/}}
{{- define "srm-web.ml.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-ml=%s" (include "srm-web.ml.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the SAML properties file.
*/}}
{{- define "srm-web.saml.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-saml=%s" (include "srm-web.saml.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the SAML keystore properties file.
*/}}
{{- define "srm-web.saml-keystore.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-saml-keystore=%s" (include "srm-web.saml-keystore.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the TO key properties file.
*/}}
{{- define "srm-web.to-key.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-to-key=%s" (include "srm-web.to-key.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the TO properties file.
*/}}
{{- define "srm-web.to.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-to=%s" (include "srm-web.to.props.path" .) -}}
{{- end -}}

{{/*
Returns the system property that includes the SF properties file.
*/}}
{{- define "srm-web.sf.props.system-property" -}}
{{- printf "-Dcodedx.additional-props-sf=%s" (include "srm-web.sf.props.path" .) -}}
{{- end -}}

{{/*
Returns all system properties followed by all extra props files.
*/}}
{{- define "srm-web.props.system-properties" -}}
{{- printf "%s " (include "srm-web.database.props.system-property" .) -}}
{{- printf "%s " (include "srm-web.ml.props.system-property" .) -}}
{{- if .Values.web.authentication.saml.enabled -}}
{{- printf "%s " (include "srm-web.saml.props.system-property" .) -}}
{{- printf "%s " (include "srm-web.saml-keystore.props.system-property" .) -}}
{{- end -}}
{{- if .Values.features.to -}}
{{- printf "%s " (include "srm-web.to-key.props.system-property" .) -}}
{{- printf "%s " (include "srm-web.to.props.system-property" .) -}}
{{- end -}}
{{- if .Values.features.scanfarm -}}
{{- printf "%s " (include "srm-web.sf.props.system-property" .) -}}
{{- end -}}
{{- range .Values.web.props.extra -}}
{{- printf "-Dcodedx.additional-props-%s=\"%s/%s\" " .key (include "srm-web.appdata.path" .) .key -}}
{{- end -}}
{{- end -}}
