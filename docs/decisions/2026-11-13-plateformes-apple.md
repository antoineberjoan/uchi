# Plateformes Apple partagées — 13 novembre 2026

## Contexte

Graker Local visait macOS seul. Antoine demande macOS et iPhone avec SwiftUI, en appliquant Sophos (couches, jetons DTCG, socle version 2).

## Décision

Partager `GrakerCore`, `GrakerDesign`, `GrakerUI` et `GrakerPlatform` entre les cibles. `GrakerMac` garde AppKit (panneau, Accessibilité, raccourcis Carbon). `GrakerIOS` livre l’éditeur intégré sans capture de sélection système. Les jetons vivent dans `Resources/Brand/tokens.json` ; les sorties Swift sont fabriquées par `jetons.mjs`. La CI macOS hébergée sur le dépôt public `uchi` reste : écart au filet Sophos, documenté ici.

## Options

Une seule cible macOS : rejetée. Deux apps SwiftUI avec noyau commun : retenue. UIKit-only : rejetée au profit de SwiftUI.

## Conséquences

Le remplacement de sélection hors application reste macOS. iOS utilise collage, saisie et copie. `Tokens.swift` dans `GrakerDesign` assure la transition depuis l’ancien fichier généré CSS.
