# Fondation produit

Date : 2026-11-07 · Statut : acceptée
Décidé par : Antoine (chat initial imi)

## Contexte

Usage personnel avec clés API dans le trousseau, interface native et méthodes Sophos. Choix entre SwiftUI natif, WebView Tailwind ou web locale avec compagnon.

## Décision

Application macOS 15 en SwiftUI ; AppKit pour fenêtres, presse-papiers, activation, Accessibilité et Carbon. Jetons depuis CSS puis migration DTCG ; accent bleu pour action et focus ; rouge et vert pour les états. Noyau pur, adaptateurs réseau et système, contrats de modules listés ci-dessous. Qualité : facette min 3, fiabilité min 4, jugée sur Mac.

## Options

| Option | Conséquence |
| --- | --- |
| Interface native | Retenue : un système de vues, référence Imi |
| WebView Tailwind | Écartée : double a11y, pont inutile |
| Web seule | Écartée : pas de remplacement de sélection externe |

## Conséquences

Tokens, couches et limites (pas de code source d'un autre produit, pas de HTML mail garanti) guident toute l’implémentation. Voir aussi [Documentation/Decisions/2026-11-07-foundation.md](../../Documentation/Decisions/2026-11-07-foundation.md) pour le détail des contrats et critères.

## Trace

- Critères qualité, tableaux de contrats et limites détaillées : copie longue dans `Documentation/Decisions/2026-11-07-foundation.md`.
- Circuit de revue GitHub : à brancher plus tard selon Sophos ; rien d’inventé dans le dépôt.
