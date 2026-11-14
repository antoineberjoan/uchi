# Test sur un Mac

Ce parcours prend environ 10 minutes. Il vérifie ce que les tests automatiques
ne voient pas : un vrai fournisseur, l'écran, le clavier et les autres apps.
Pour chaque étape, note ce que tu vois. Si le résultat diffère, copie l'erreur
affichée dans le panneau.

## Avant de commencer

1. Sur un Mac, depuis le dépôt, lance `bash Scripts/build-app.sh`, puis ouvre `dist/imi.app`.
2. Ouvre « imi » avec un clic droit, puis **Ouvrir**. macOS peut
   demander une confirmation : l'app est signée en local, pas par Apple.
3. Prépare une clé API Google Gemini. Ne l'écris jamais dans un chat.

## Parcours

| # | Action | Résultat attendu |
|---|---|---|
| 1 | Ouvre **Réglages → Fournisseur IA**. Colle ta clé. Clique **Valider et enregistrer**. | Message « Connexion validée ». Un échec montre une erreur en français. |
| 2 | Ouvre le panneau depuis la barre des menus. Écris `You not the last one.` puis presse **Retour**. | Le résultat apparaît par morceaux. « You are not » est surligné. |
| 3 | Clique sur le passage surligné. | Une carte montre l'ancien texte barré, le nouveau, puis la raison en phrases courtes. |
| 4 | Presse **⇧Retour** dans la saisie. | Une nouvelle ligne s'ajoute. Rien ne se lance. |
| 5 | Efface la saisie. Tape quelques mots à la main. | Rien ne se lance pendant que tu tapes. |
| 6 | Copie une phrase ailleurs, puis colle-la dans la saisie. | La correction se lance toute seule. |
| 7 | Passe sur **Reformuler** et presse **Retour** sur une phrase maladroite en anglais. | Un texte plus clair, avec au plus 8 changements expliqués. |
| 8 | Écris une instruction dans le champ du bas, par exemple « plus court ». | Le résultat est ajusté. |
| 9 | Passe sur **Traduire** et traduis une phrase. | La traduction arrive par morceaux. |
| 10 | Ouvre le menu du fournisseur dans la barre d'outils. | Chaque fournisseur montre son modèle. Le changement s'applique tout de suite. |

## Dans une autre app

| # | Action | Résultat attendu |
|---|---|---|
| 11 | Dans TextEdit, écris une phrase fautive puis triple-clique pour la sélectionner. Presse **⇧⌘G**. | macOS demande l'autorisation Accessibilité la première fois. Ensuite le panneau s'ouvre sous la sélection. |
| 12 | Clique **Remplacer**. | La phrase est remplacée dans TextEdit. Le retour à la ligne final est conservé. |
| 13 | Refais l'étape 11, puis change la sélection dans TextEdit avant de cliquer **Remplacer**. | Une erreur explique que la sélection a changé. **Copier** reste disponible. |
| 14 | Ferme le panneau avec **Échap**, puis tape du texte. | Le texte arrive dans TextEdit, sans cliquer dedans. |
| 15 | Refais l'étape 11 dans Safari ou Chrome, sur une zone de texte. | Le panneau s'ouvre et le remplacement fonctionne. Un échec doit afficher un message clair. |

## Les cas d'échec

| # | Action | Résultat attendu |
|---|---|---|
| 16 | Coupe le Wi-Fi, puis lance une correction. | Une erreur de connexion en français. Ta saisie reste intacte. |
| 17 | Lance une correction, puis clique **Annuler**. | « Requête annulée. Votre texte est conservé. » |
| 18 | Retire l'autorisation Accessibilité dans Réglages Système, puis presse **⇧⌘G**. | Une erreur propose d'autoriser l'accès. |

## Ce que l'on cherche en priorité

- Étape 2 : le flux de Gemini se termine-t-il bien ? Le code attend la ligne
  `data: [DONE]`. Si l'erreur « La connexion s'est arrêtée avant la fin »
  apparaît, Gemini ne l'envoie pas.
- Étapes 4 et 6 : ⇧Retour ajoute-t-il un simple retour à la ligne ? Un collage
  est-il bien reconnu, et la saisie normale reste-t-elle silencieuse ?
- Étape 14 : le clavier revient-il dans l'app d'origine ?
- Étape 12 : le remplacement garde-t-il le paragraphe suivant à sa place ?
