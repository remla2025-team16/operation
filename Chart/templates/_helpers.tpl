{{/*
Define the chart name.
*/}}
{{- define "multi-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate a fully qualified name that includes the release name.
*/}}
{{- define "multi-service.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "multi-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}