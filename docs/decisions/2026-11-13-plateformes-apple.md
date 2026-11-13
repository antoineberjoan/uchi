# Plateformes Apple partagées

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (macOS et iPhone, couches Sophos)

## Contexte

imi visait macOS seul. Antoine demande macOS et iPhone avec SwiftUI, en appliquant Sophos (couches, jetons DTCG, socle version 2).

## Décision

Partager `ImiCore`, `ImiDesign`, `ImiUI` et `ImiPlatform` entre les cibles. `ImiMac` garde AppKit (panneau, Accessibilité, raccourcis Carbon). `ImiIOS` livre l’éditeur intégré sans capture de sélection système. Les jetons vivent dans `Resources/Brand/tokens.json` ; les sorties Swift sont fabriquées par `jetons.mjs`. La CI macOS hébergée sur le dépôt public `uchi` reste : écart au filet Sophos, assumé ici.

## Options

| Option | Résultat |
| --- | --- |
| macOS seul | Rejeté : pas d’iPhone |
| Deux apps SwiftUI + noyau commun | Retenu |
| UIKit-only sur iOS | Rejeté au profit de SwiftUI |

## Conséquences

Le remplacement de sélection hors application reste macOS. iOS utilise collage, saisie, copie et **clavier** (sélection prioritaire quand l’hôte coopère). `Tokens.swift` dans `ImiDesign` assure la transition depuis l’ancien pont CSS.

## Trace

- Fichiers : `Package.swift`, modules `ImiMac` / `ImiIOS`.
- Décisions liées : [marque et jetons](2026-11-13-marque-jetons.md), [clavier iOS](2026-11-13-clavier-ios.md).
