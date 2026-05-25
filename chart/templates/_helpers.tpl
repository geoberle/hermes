{{- define "hermes.labels" -}}
app.kubernetes.io/name: hermes-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "hermes.selectorLabels" -}}
app.kubernetes.io/name: hermes-agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
