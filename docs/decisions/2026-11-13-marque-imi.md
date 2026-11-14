# Marque imi

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (marque imi, panneau minimal)

## Contexte

Le panneau visé est minimal : épingle, titre, élargir, modes en icônes, bouton d’action. La marque du dépôt devient **imi** (« le sens »), surligneur `#FFD43B` sur encre `#121A2E`.

## Décision

Poser les fichiers dans `Design/imi/`. Pointer `projet.yml` vers les marques claire et sombre. Aligner les primitives `ink` et `paper` sur encre, nuit, blanc et brume. L’accent d’interface est le surligneur `#FFD43B` (`mark.100`), y compris les boutons. Le seuil de contraste de l’accent et du focus est abaissé à 1:1 pour garder cette teinte. Le texte posé sur le bouton reste l’encre. Le panneau Mac reprend l’épingle à gauche, le titre imi, les modes en icônes. Les réglages Général montrent scène, langues et état d’accessibilité. Les modules Swift portent le préfixe `Imi` (cible de compilation), le nom affiché est imi.

## Options

| Option | Effet |
| --- | --- |
| Bouton exactement `#FFD43B` | Refusé par le contraste Sophos sur fond clair |
| Renommer tous les modules | Fait le 14 novembre 2026 : préfixe Imi |
| Copier les liens About d'un autre produit | Refusé : ce n’est pas la même application |

## Conséquences

Le rendu n’est pas une copie pixel d'un autre panneau. L’épingle, la barre courte et les réglages en cartes s’en rapprochent. Logo et textes utilisateur disent imi.

## Trace

- Assets : `Design/imi/`.
- Interface : `Sources/ImiUI/EditorView.swift`, `SettingsView.swift`.
