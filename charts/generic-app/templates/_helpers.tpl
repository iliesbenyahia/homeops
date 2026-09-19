{{/*
Une ressource est activée sauf si enabled: false est explicitement positionné.
Usage : {{ if include "app.enabled" $obj }}
*/}}
{{- define "app.enabled" -}}
{{- if not (kindIs "invalid" .) -}}
{{- if or (not (hasKey . "enabled")) .enabled -}}true{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Nom d'une ressource : clé de la map, ou champ "name" si fourni.
Usage : include "app.name" (list $key $obj)
*/}}
{{- define "app.name" -}}
{{- $key := index . 0 -}}
{{- $obj := index . 1 | default dict -}}
{{- default $key $obj.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Labels de sélection (immuables). Usage : include "app.selectorLabels" (dict "root" $ "name" $name)
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/part-of: {{ .root.Release.Name }}
{{- end -}}

{{/*
Labels communs. Usage : include "app.labels" (dict "root" $ "name" $name "extra" $obj.labels)
*/}}
{{- define "app.labels" -}}
{{ include "app.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .root.Chart.Name .root.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- with .root.Values.global.labels }}
{{ toYaml . }}
{{- end }}
{{- with .extra }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Annotations : globales + spécifiques à la ressource (la ressource gagne) + sync-wave Argo CD optionnelle.
Usage : include "app.annotations" (dict "root" $ "extra" $obj.annotations "wave" "-1")
Ne rend rien si vide.
*/}}
{{- define "app.annotations" -}}
{{- $defaults := dict -}}
{{- if and .wave .root.Values.global.argocd.syncWaves -}}
{{- $_ := set $defaults "argocd.argoproj.io/sync-wave" (toString .wave) -}}
{{- end -}}
{{- $ann := merge (dict) (default (dict) .extra) $defaults (default (dict) .root.Values.global.annotations) -}}
{{- with $ann -}}
{{ toYaml . }}
{{- end -}}
{{- end -}}

{{/*
Image : chaîne complète ("nginx:1.27") ou dict {repository, tag, digest}.
*/}}
{{- define "app.image" -}}
{{- if kindIs "string" . -}}
{{- . -}}
{{- else -}}
{{- $repo := required "image.repository est requis" .repository -}}
{{- if .digest -}}
{{- printf "%s@%s" $repo .digest -}}
{{- else -}}
{{- printf "%s:%s" $repo (toString (required "image.tag est requis (ou utiliser image.digest)" .tag)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
