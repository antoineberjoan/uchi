# Guide de reprise

Archive de sources, reprise hors chat et contrôles attendus avant une revue indépendante.

## Contenu de l'archive

Le zip de sources contient le Swift, les tests, les règles et les décisions. Il ne contient ni transcription de chat, ni `.app` compilée, ni clé API.

## Export

Depuis un dépôt sans changement non enregistré :

```sh
python3 Scripts/export-project.py
```

`dist/imi-sources.zip` inclut `history.bundle` et `EXPORT.txt` (commit et branche exportés).

## Restauration pour revue

```sh
git clone --branch main /chemin/vers/imi-local/history.bundle imi-local-review
cd imi-local-review
git log --oneline
```

Lire `EXPORT.txt` si l'archive ne vient pas de `main`.

## Avant la revue

Lire `AGENTS.md`, le README, [fondation](fondation.md), [marque et jetons](decisions/2026-11-13-marque-jetons.md) et le [contrat réseau](../Documentation/Network.md). Sous Linux : `python3 scripts/check-foundation.py` et tests du noyau si Swift est disponible. Sur Mac : `bash Scripts/build-app.sh` et [tests manuels](../Documentation/ManualTests.md).
