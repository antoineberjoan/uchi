# Publier dans uchi

Date : 2026-11-07 · Statut : acceptée
Décidé par : Antoine

## Contexte

Le dépôt `antoineberjoan/uchi` est public. Antoine autorise d’y remplacer Scratch par Graker Local sans changer la visibilité.

## Décision

Supprimer la branche de sauvegarde Scratch, publier l’import, vérifier la construction macOS, puis intégrer sur `main`. L’historique Git n’est pas réécrit.

## Options

| Option | Effet |
| --- | --- |
| Nouveau dépôt privé | Refusé par l’intégration ou non demandé |
| Remplacement dans uchi | Retenu |

## Conséquences

L’arbre courant ne porte plus Scratch ; la traçabilité Git reste. Complète la décision d’import.

## Trace

- Étape de revue par fusion sur `main` : détaillée dans [Documentation/Decisions/2026-11-07-publication.md](../../Documentation/Decisions/2026-11-07-publication.md).
- Branche de sauvegarde : `backup/scratch-before-graker-2026-11-07`.
