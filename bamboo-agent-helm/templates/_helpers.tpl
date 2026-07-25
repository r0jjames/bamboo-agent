{{- define "bamboo-agent.name" -}}
bamboo-agent
{{- end -}}

{{- define "bamboo-agent.labels" -}}
app.kubernetes.io/name: {{ include "bamboo-agent.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
