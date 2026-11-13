# Mode reformulation

Date : 2026-11-08 · Statut : acceptée
Décidé par : Antoine

## Contexte

Besoin de reformuler l’anglais avec explications selon le skill `expliquer`. Graker public ne propose que correction et traduction.

## Décision

Troisième mode Reformuler (⇧⌘R) ; consignes `expliquer` dans `RequestFactory` ; format JSON de révision partagé avec la correction.

## Options

| Option | Risque |
| --- | --- |
| Tout faire via affinage | Écartée : étape répétée |
| Correction plus poussée | Écartée : mélange les modes |

## Conséquences

Raccourci global en conflit possible avec d’autres apps (configurable). Champ `rephrasingKey` pour migration préférences.

## Trace

- Suite : [Documentation/Decisions/2026-11-08-rephrasing.md](../../Documentation/Decisions/2026-11-08-rephrasing.md).
