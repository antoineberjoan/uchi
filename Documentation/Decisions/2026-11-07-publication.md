# Publier Graker Local dans uchi — 7 novembre 2026

## Décision de l'utilisateur

Après l'information sur le caractère public de `antoineberjoan/uchi`, Antoine
demande de supprimer la sauvegarde de Scratch et de remplacer le contenu de
la branche principale par notre réimplémentation personnelle de Graker.
La publication dans ce dépôt public est donc autorisée ; aucune modification
de visibilité n'est demandée.

## Application

Supprimer la branche `backup/scratch-before-graker-2026-11-07`. Publier l'import
dans une PR, vérifier la construction macOS, puis intégrer le remplacement sur
`main`. Les sources, images et workflows de Scratch disparaissent de l'arbre
courant. L'historique Git n'est pas réécrit : il garde la traçabilité des deux
projets, sans maintenir une branche de sauvegarde de l'ancien produit.

Cette décision complète celle d'import : la sauvegarde préparatoire n'est plus
conservée comme branche et le choix de visibilité est désormais explicite.
