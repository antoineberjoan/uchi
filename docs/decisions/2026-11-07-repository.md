# Réutiliser le dépôt uchi — 7 novembre 2026

## Demande

Antoine demande de récupérer un dépôt existant, d'en supprimer le projet actuel
et d'y intégrer Graker Local. Il désigne `https://github.com/antoineberjoan/uchi`.
Cette demande remplace la tentative de création de `antoineberjoan/graker-local`,
refusée par les droits de l'intégration GitHub.

## Décision

Conserver le dépôt et son nom GitHub. Remplacer les fichiers de Scratch
(Tauri/React/Rust) par les sources Swift de Graker Local. Le nom de produit
Graker Local, son identifiant d'application et ses contrats ne changent pas.

La branche `backup/scratch-before-graker-2026-11-07` sauvegarde l'ancien état
`9126a5adf78abbabd111302ca0b659ca9278d43a` sur GitHub. L'import vit sur
`feat/graker-local`. Son ascendance réunit l'historique de Scratch et les cinq
commits du projet local, jusqu'à `a34a075a757c83e66ecb7e543e86ef9eee80f16a`.
Les fichiers du nouvel arbre remplacent l'ancien projet ; aucun force-push,
suppression de dépôt ou effacement de son historique n'est nécessaire.

## Pourquoi

L'utilisateur fournit un dépôt accessible alors que l'intégration ne peut pas
en créer un. Garder les deux historiques rend le remplacement contrôlable et
réversible. Une PR permet à une autre session de relire l'import complet et de
lancer la vérification macOS sans dépendre du chat d'origine.

## Contrôles

Les tokens, les frontières et les tests du noyau se vérifient localement.
La compilation de l'application et les essais d'accessibilité, de raccourcis,
de remplacement et d'affichage natif demandent toujours macOS. Le dépôt fourni
est un fork public ; le choix de visibilité doit précéder la publication des
nouveaux fichiers. Aucun changement de visibilité n'est implicite.
