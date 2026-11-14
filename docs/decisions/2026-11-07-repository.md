# Réutiliser le dépôt uchi

Date : 2026-11-07 · Statut : acceptée
Décidé par : Antoine

## Contexte

Antoine désigne `antoineberjoan/uchi` pour héberger imi à la place de Scratch, faute de pouvoir créer un dépôt dédié via l’intégration.

## Décision

Conserver le dépôt GitHub et le nom de produit imi. Remplacer l’arbre Tauri/React par les sources Swift. Conserver une branche de sauvegarde et une branche d’import jusqu’à fusion contrôlée.

## Options

| Option | Effet |
| --- | --- |
| Dépôt `imi-local` neuf | Indisponible |
| Fork / remplacement dans uchi | Retenu |

## Conséquences

Deux historiques restent lisibles dans Git. Les contrôles noyau tournent sous Linux ; macOS reste requis pour AppKit et essais manuels.

## Trace

- Sauvegarde Scratch, identifiant `9126a5adf78abbabd111302ca0b659ca9278d43a` ; import du 7 novembre 2026 ; cinq commits locaux jusqu’à `a34a075a757c83e66ecb7e543e86ef9eee80f16a`.
- Détail : [Documentation/Decisions/2026-11-07-repository.md](../../Documentation/Decisions/2026-11-07-repository.md).
