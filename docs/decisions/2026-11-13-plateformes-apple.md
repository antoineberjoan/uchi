# Plateformes Apple partagées

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (macOS et iPhone, couches Sophos)

## Contexte

imi visait macOS seul. Antoine demande macOS et iPhone avec SwiftUI, en appliquant Sophos (couches, jetons DTCG, socle version 2).

## Décision

Partager `ImiCore`, `ImiDesign`, `ImiUI` et `ImiPlatform` entre les cibles. `ImiMac` garde AppKit (panneau, Accessibilité, raccourcis Carbon). `ImiIOS` ne garde que les réglages : le geste iPhone est le clavier ([iPhone : le clavier seul](2026-11-14-iphone-clavier.md)). Les jetons vivent dans `Resources/Brand/tokens.json` ; les sorties Swift sont fabriquées par `jetons.mjs`. La construction macOS se fait sur le Mac : la CI hébergée est retirée ([pas de CI](2026-11-14-pas-de-ci.md)).

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
