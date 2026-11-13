# Fiabilité flux, sélection et focus

Date : 2026-11-08 · Statut : acceptée
Décidé par : Antoine / implémentation fondation

## Contexte

Requêtes SSE qui échouent (lignes vides perdues), validations de blancs sur sélection paragraphe, focus perdu à la fermeture du panneau.

## Décision

Lecture octets + `LineDecoder` ; `SourceWhitespace` pour blancs ; réactivation de l’app d’origine à la fermeture ; throttle d’affichage 80 ms. Contrats fondation inchangés.

## Options

| Option | Risque |
| --- | --- |
| `URLSession.AsyncBytes.lines` | Écartée : saute lignes vides SSE |
| Demande au modèle de garder les blancs | Écartée : non fiable |

## Conséquences

Tests noyau sous Linux ; comportement fournisseur réel à valider sur Mac. Marqueur `[DONE]` requis ; erreur visible si absent chez Gemini.

## Trace

- Détail technique : [Documentation/Decisions/2026-11-08-reliability.md](../../Documentation/Decisions/2026-11-08-reliability.md).
