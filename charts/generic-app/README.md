# generic-app

Chart Helm générique pour déployer des applications simples : 1..N Deployments, Services, IngressRoutes Traefik, PVC, ConfigMaps et ExternalSecrets (ESO).

## Principes

- **Maps nommées** : `deployments.<clé>`, `services.<clé>`, etc. Facile à surcharger par environnement.
- **Nom de la ressource = clé** (ex: `deployments.web` → Deployment `web`). Champ `name` optionnel pour forcer un autre nom.
- **Services → Deployments** : `services.web` cible `deployments.web` par défaut ; `deployment: autre` pour changer, ou `selector` pour un sélecteur libre.
- **Secrets ESO** : l'`ExternalSecret` `web-secrets` génère un `Secret` `web-secrets`, à référencer directement dans `envFrom` / `volumes`.
- **Exposition** : `services.<clé>.expose: lan|public` génère l'IngressRoute et le Certificate cert-manager (hostname `<clé>.<domain du profil>`). Les profils (entrypoints, domaine, issuer, middlewares) se définissent dans `global.expose.profiles`, idéalement dans un fichier de values commun à toutes les apps.
- **IngressRoutes manuelles** : `ingressRoutes` reste disponible pour les cas atypiques (multi-routes, path-based).
- **Argo CD** : sync-wave `-1` sur ConfigMaps et ExternalSecrets (désactivable via `global.argocd.syncWaves`).
- **Désactivation** : `enabled: false` sur une ressource, ou `clé: null` dans un override.
- Les blocs Kubernetes (env, probes, volumes, routes Traefik, data ESO…) sont passés tels quels : pas de sur-abstraction.

## Utilisation

```bash
helm lint . -f examples/full-example.yaml
helm template myapp . -f examples/full-example.yaml
```

Avec Argo CD, utiliser la chart comme source Helm et fournir les `values` de l'application (voir `values.yaml` pour toutes les options).

## Points d'attention

- Les noms n'étant pas préfixés par la release, deux applications déployées dans le **même namespace** avec les mêmes clés entreront en conflit.
- Les changements de contenu d'un ConfigMap déclenchent un rollout via `checksumConfigMaps`. Pour les Secrets, utiliser un outil comme Reloader (`podAnnotations`).
- `global.externalSecrets.secretStoreRef.name` doit être renseigné, sinon le rendu échoue avec un message explicite.
