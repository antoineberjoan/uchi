# Fondation

Ce document dit ce qu'est le projet, pour une personne qui ne l'a jamais vu.

## Nom

**Graker Local** : application personnelle inspirée de Graker, intégrée dans le dépôt GitHub `antoineberjoan/uchi`.

## Raison d'être

Corriger, reformuler et traduire un texte depuis l'application où l'on écrit, avec ses clés API et sans service intermédiaire. Avant : copier-coller vers un outil web. Après : panneau ou éditeur dédié, explication des changements, copie ou remplacement (macOS).

## Pour qui

Pour Antoine, usage personnel sur Mac et iPhone. Pas pour une redistribution ni un support multi-utilisateurs.

## Périmètre

Dedans : noyau pur de requêtes et révisions, interface SwiftUI commune, coquilles macOS (sélection, raccourcis, panneau) et iOS (éditeur intégré + **clavier** pour agir dans d’autres apps). Dehors : capture système de sélection sur iOS, modèles hors ligne, serveur relais.

## Principes

Une source de jetons (`Resources/Brand/tokens.json`). Noyau pur sans réseau. Erreur visible, jamais de repli silencieux. Clés dans le trousseau. Dix résultats en mémoire. Méthodes Sophos activées dans `AGENTS.md`.

## Marque

Discret, gris chaud, accent bleu unique. Icônes `Design/icon-*.svg`, palette nommée `Design/graker-couleurs.json`, rôles d’interface via `Resources/Brand/tokens.json` → `Sources/GrakerDesign/`. Décision : `docs/decisions/2026-11-13-marque-jetons.md`. Texte d'interface en français (`expliquer`).

## Voix

- **Montré** : oui, dépôt public `uchi` ; usage personnel.
- **Signature** : Graker Local
- **Publics** : l'utilisateur qui rédige en français et corrige depuis d'autres applications.
- **Ton** : direct, calme, erreurs explicites en français simple.
- **Mots** : correction, reformulation, traduction, fournisseur, affinage ; pas de jargon marketing.
- **Jamais** : promesse de fidélité parfaite à Graker public ; pas de clé partagée ni de secours simulé.
