{{/* Chart name */}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{/* Fullname: release-name + chart name */}}
{{- define "my-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "my-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Common labels */}}
{{- define "my-app.labels" -}}
app.kubernetes.io/name: "{{ include "my-app.name" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
{{- end -}}