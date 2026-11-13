# Marque et jetons

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (validation de la proposition visuelle), avec l’agent cloud

## Contexte

L’alignement Sophos exige une marque documentée, des jetons DTCG et une fiche `projet.yml` sans clés hors schéma. La marque Graker devait reprendre le minimalisme d’un autre projet (double cercle) sans importer ses assets ni sa palette citron.

## Décision

Valider la marque Graker : double cercle, gris chaud, bleu d’accent. Icônes `Design/icon-*.svg`, mots-symboles `Design/graker-wordmark-*.svg`, palette nommée `Design/graker-couleurs.{json,css}`. Rapprocher `Resources/Brand/tokens.json` : primitives `ink`/`paper` chaudes, échelle `blue` marque, rôles `color.accent` et `color.accent-text` sur le bleu. `projet.yml` ne garde que les clés `marque` prévues par Sophos.

## Options

| Option | Ce qu’elle donne | Ce qu’elle coûte |
| --- | --- | --- |
| Accent monochrome (patron) | Alignement strict Sophos | Contredit la fondation produit (accent bleu) |
| Palette Pithos dans le dépôt | Copier-coller rapide | Confusion de marque, citron hors identité Graker |
| Marque validée + jetons bleus (retenu) | Cohérence logo et interface | Écart patron documenté ; `info` reste sur une nuance bleue distincte |

## Conséquences

Les sorties `jetons.mjs` régénèrent `Design/tokens.css` et `Sources/GrakerDesign/`. `text-muted` en contraste élevé utilise `ink.650`. Les dimensions panneau restent dans `Tokens.swift` jusqu’à migration. Captures `marque.capture-*` : optionnelles plus tard.

## Trace

- Fichiers : `Design/`, `Resources/Brand/tokens.json`, `docs/fondation.md`.
- Validation visuelle : conversation agent du 13 novembre 2026.
