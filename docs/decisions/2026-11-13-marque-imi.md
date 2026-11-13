# Marque imi

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (marque imi, panneau proche de Graker)

## Contexte

Le panneau public de Graker est minimal : épingle, titre, élargir, modes en icônes, bouton d’action. La marque du dépôt devient **imi** (« le sens »), surligneur `#FFD43B` sur encre `#121A2E`.

## Décision

Poser les fichiers dans `Design/imi/`. Pointer `projet.yml` vers les marques claire et sombre. Aligner les primitives `ink` et `paper` sur encre, nuit, blanc et brume. L’accent d’interface est `mark.450` (lisibilité 3:1) ; le jaune du logo reste `#FFD43B`. Le panneau Mac reprend l’épingle à gauche, le titre imi, les modes en icônes. Les réglages Général montrent scène, langues et état d’accessibilité. Les modules Swift gardent le préfixe `Graker` (cible de compilation), le nom affiché est imi.

## Options

| Option | Effet |
| --- | --- |
| Bouton exactement `#FFD43B` | Refusé par le contraste Sophos sur fond clair |
| Renommer tous les modules | Reporté : trop large pour ce lot |
| Copier les liens About de Graker | Refusé : ce n’est pas la même application |

## Conséquences

Le rendu n’est pas une copie pixel de Graker. L’épingle, la barre courte et les réglages en cartes s’en rapprochent. Logo et textes utilisateur disent imi.

## Trace

- Assets : `Design/imi/`.
- Interface : `Sources/GrakerUI/EditorView.swift`, `SettingsView.swift`.
