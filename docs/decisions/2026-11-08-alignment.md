# Rapprocher le panneau de Graker

Date : 2026-11-08 · Statut : acceptée
Décidé par : Antoine

## Contexte

Comparer l’application au journal public de Graker (captures du 8 novembre 2026). Priorités : surlignage des changements, menu fournisseur, modèle Gemini à jour, comportement clavier comme Graker.

## Décision

Surlignage cliquable avec carte sous le texte ; menu fournisseur dans la barre d’outils ; défaut Gemini `gemini-3.1-flash-lite` ; Retour lance le traitement, collage lance aussi. `RevisionLayout` / `RevisionView` et profils `Configuration` portent ces choix.

## Options

| Option | Risque |
| --- | --- |
| Bulle flottante sur le passage | Écartée : pas de position Text SwiftUI |
| NSTextView + NSPopover | Écartée : couleurs AppKit hors jetons |
| Liste dépliable + surlignage | Écartée : doublon |

## Conséquences

Écarts restants documentés : Markdown complet, panneau extensible, HTML mail, etc. Profils remplacent endpoint/model ; migration préférences visible. Détail dans [Documentation/Decisions/2026-11-08-alignment.md](../../Documentation/Decisions/2026-11-08-alignment.md).

## Trace

- Journal Graker : https://graker.fehey.com/changelog
- Limites non vérifiées sur Mac (soulignement, ⇧Retour, date modèle Gemini).
