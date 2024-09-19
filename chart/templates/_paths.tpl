{{/*
Full path to the AppData directory
*/}}
{{- define "srm-web.appdata.path" -}}
/opt/codedx
{{- end -}}

{{/*
Full path to the profile directory
*/}}
{{- define "srm-web.profile.path" -}}
/home/codedx/.codedx
{{- end -}}

{{/*
Returns the admin password filename.
*/}}
{{- define "srm-web.admin.password.filename" -}}
admin-password
{{- end -}}

{{/*
Returns the admin password path.
*/}}
{{- define "srm-web.admin.password.path" -}}
{{- printf "%s/%s" (include "srm-web.profile.path" . ) (include "srm-web.admin.password.filename" .) -}}
{{- end -}}

{{/*
Returns the cacerts password path.
*/}}
{{- define "srm-web.cacerts.password.filename" -}}
cacerts-password
{{- end -}}

{{/*
Returns the cacerts password path.
*/}}
{{- define "srm-web.cacerts.password.path" -}}
{{- printf "%s/%s" (include "srm-web.profile.path" . ) (include "srm-web.cacerts.password.filename" .) -}}
{{- end -}}

{{/*
Returns the connection pool filename.
*/}}
{{- define "srm-web.connection-pool.filename" -}}
hikari.properties
{{- end -}}

{{/*
Returns the connection pool properties path.
*/}}
{{- define "srm-web.connection-pool.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.connection-pool.filename" .) -}}
{{- end -}}

{{/*
Returns the license filename.
*/}}
{{- define "srm-web.license.filename" -}}
license.lic
{{- end -}}

{{/*
Returns the license path.
*/}}
{{- define "srm-web.license.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.license.filename" .) -}}
{{- end -}}

{{/*
Returns the logback filename.
*/}}
{{- define "srm-web.logback.filename" -}}
logback.xml
{{- end -}}

{{/*
Returns the logback path.
*/}}
{{- define "srm-web.logback.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.logback.filename" .) -}}
{{- end -}}

{{/*
Returns the SAML IdP filename.
*/}}
{{- define "srm-web.saml-idp.filename" -}}
saml-idp.xml
{{- end -}}

{{/*
Returns the SAML IdP path.
*/}}
{{- define "srm-web.saml-idp.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.saml-idp.filename" .) -}}
{{- end -}}

{{/*
Returns the main properties filename.
*/}}
{{- define "srm-web.main.props.filename" -}}
codedx.props
{{- end -}}

{{/*
Returns the main properties path.
*/}}
{{- define "srm-web.main.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.main.props.filename" .) -}}
{{- end -}}

{{/*
Returns the database properties filename.
*/}}
{{- define "srm-web.database.props.filename" -}}
db.props
{{- end -}}

{{/*
Returns the database properties path.
*/}}
{{- define "srm-web.database.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.database.props.filename" .) -}}
{{- end -}}

{{/*
Returns the ML properties filename.
*/}}
{{- define "srm-web.ml.props.filename" -}}
ml.props
{{- end -}}

{{/*
Returns the ML properties path.
*/}}
{{- define "srm-web.ml.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.ml.props.filename" .) -}}
{{- end -}}

{{/*
Returns the SAML properties filename.
*/}}
{{- define "srm-web.saml.props.filename" -}}
saml.props
{{- end -}}

{{/*
Returns the SAML properties path.
*/}}
{{- define "srm-web.saml.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.saml.props.filename" .) -}}
{{- end -}}

{{/*
Returns the SAML keystore properties filename.
*/}}
{{- define "srm-web.saml-keystore.props.filename" -}}
saml-keystore.props
{{- end -}}

{{/*
Returns the SAML keystore properties path.
*/}}
{{- define "srm-web.saml-keystore.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.saml-keystore.props.filename" .) -}}
{{- end -}}

{{/*
Returns the TO key properties filename.
*/}}
{{- define "srm-web.to-key.props.filename" -}}
to-key.props
{{- end -}}

{{/*
Returns the TO key properties path.
*/}}
{{- define "srm-web.to-key.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.to-key.props.filename" .) -}}
{{- end -}}

{{/*
Returns the TO properties filename.
*/}}
{{- define "srm-web.to.props.filename" -}}
to.props
{{- end -}}

{{/*
Returns the TO properties path.
*/}}
{{- define "srm-web.to.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.to.props.filename" .) -}}
{{- end -}}

{{/*
Returns the Scan Farm properties filename.
*/}}
{{- define "srm-web.sf.props.filename" -}}
sf.props
{{- end -}}

{{/*
Returns the Scan Farm properties path.
*/}}
{{- define "srm-web.sf.props.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.sf.props.filename" .) -}}
{{- end -}}

{{/*
Returns the optional database public key filename.
*/}}
{{- define "srm-web.database.pubkey.filename" -}}
db-public-key
{{- end -}}

{{/*
Returns the optional database public key path.
*/}}
{{- define "srm-web.database.pubkey.path" -}}
{{- printf "%s/%s" (include "srm-web.appdata.path" . ) (include "srm-web.database.pubkey.filename" .) -}}
{{- end -}}
