# Plateformes Apple partagées

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (macOS et iPhone, couches Sophos)

## Contexte

Graker Local visait macOS seul. Antoine demande macOS et iPhone avec SwiftUI, en appliquant Sophos (couches, jetons DTCG, socle version 2).

## Décision

Partager `GrakerCore`, `GrakerDesign`, `GrakerUI` et `GrakerPlatform` entre les cibles. `GrakerMac` garde AppKit (panneau, Accessibilité, raccourcis Carbon). `GrakerIOS` livre l’éditeur intégré sans capture de sélection système. Les jetons vivent dans `Resources/Brand/tokens.json` ; les sorties Swift sont fabriquées par `jetons.mjs`. La CI macOS hébergée sur le dépôt public `uchi` reste : écart au filet Sophos, assumé ici.

## Options

| Option | Résultat |
| --- | --- |
| macOS seul | Rejeté : pas d’iPhone |
| Deux apps SwiftUI + noyau commun | Retenu |
| UIKit-only sur iOS | Rejeté au profit de SwiftUI |

## Conséquences

Le remplacement de sélection hors application reste macOS. iOS utilise collage, saisie et copie. `Tokens.swift` dans `GrakerDesign` assure la transition depuis l’ancien pont CSS.

## Trace

- Fichiers : `Package.swift`, modules `GrakerMac` / `GrakerIOS`.
- Décision liée : [marque et jetons](2026-11-13-marque-jetons.md).
