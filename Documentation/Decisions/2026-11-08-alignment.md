# Rapprocher le panneau de Graker — 8 novembre 2026

## Contexte

Antoine demande si l'application suit Graker pour le rendu et les fonctions.
La comparaison s'appuie sur le [journal de Graker](https://graker.fehey.com/changelog)
et sur deux captures de son site, lus le 8 novembre 2026. Antoine retient deux
recommandations : le surlignage des changements, puis le menu du fournisseur
avec un modèle par défaut à jour.

## Décision

1. **Surlignage.** En correction et en reformulation, chaque passage modifié
   apparaît sur un fond léger souligné, à sa place dans le texte. Un clic sur
   un passage affiche sous le texte une carte : l'ancien fragment barré, le
   nouveau, puis la raison. `RevisionLayout`, dans le noyau, place chaque
   remplacement ; `RevisionView` l'affiche. Les suppressions et les fragments
   introuvables restent visibles dans « Autres changements ».
2. **Menu du fournisseur.** La barre d'outils porte un menu : un fournisseur
   par ligne avec son modèle, puis « Réglages du fournisseur… ».
   `Configuration` garde un profil (adresse et modèle) par fournisseur.
3. **Modèle par défaut.** Gemini passe à `gemini-3.1-flash-lite`, version
   stable de mai 2026 selon [ai.google.dev](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite),
   et modèle montré par la capture de Graker.

## Options écartées

- Une bulle flottante ancrée sur le passage, comme Graker : SwiftUI ne donne
  pas la position d'un passage dans un `Text`. La carte s'affiche sous le texte.
- Un `NSTextView` avec un `NSPopover` : la bulle serait bien placée, mais la vue
  lirait des couleurs AppKit, ce que la vérification de fondation interdit dans
  `Presentation`.
- Une vue par mot dans une mise en page fluide : le retour à la ligne natif et
  la lecture continue du texte seraient perdus.
- Garder la liste dépliable en plus du surlignage : deux affichages pour une
  même information.
- Remettre l'adresse et le modèle par défaut à chaque changement de fournisseur :
  les réglages seraient perdus à chaque aller-retour.

## Écarts restants

Entrée qui lance le traitement et collage qui lance la requête : en attente du
choix d'Antoine, car Entrée sert aujourd'hui à aller à la ligne. Markdown complet,
panneau qui grandit, traduction des courriels HTML, fournisseurs côte à côte,
réflexion réduite pour Gemini et mises à jour automatiques : non faits.

## Limites

Le texte surligné ne se sélectionne pas : la sélection gênerait le clic sur
les passages. Le bouton Copier reste disponible.

Les profils remplacent les champs `endpoint` et `model` des préférences. Comme
pour `rephrasingKey`, des préférences anciennes ne se décodent plus : une seule
remise à zéro, visible, au premier lancement.

Non vérifié : le rendu réel sur un Mac (fond, soulignement, clic sur un passage)
et la date d'arrêt prévue de `gemini-3.1-flash-lite`.
