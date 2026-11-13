# Mode Reformuler et explications simples — 8 novembre 2026

## Décision

Antoine propose un outil pour reformuler son anglais, avec une formulation et
une explication qui suivent le skill `expliquer` de Sophos. Le modèle de départ ne propose
que la correction et la traduction : la reformulation est un ajout.

1. **Mode Reformuler.** Un troisième mode, entre Corriger et Traduire, avec le
   raccourci ⇧⌘R. Le modèle corrige les erreurs, puis réécrit le texte dans sa
   langue pour le rendre clair et naturel. Il garde le sens, les faits, l'ordre
   des idées et le niveau de détail. Le style choisi (Standard, Décontracté,
   Formel) fixe le registre. La réponse suit le format de la correction : texte,
   explication et au plus huit changements expliqués. Le panneau les affiche et
   permet de remplacer la sélection.
2. **Explications simples.** En correction et en reformulation, l'explication
   et chaque raison suivent les règles 1, 2, 4, 5, 6 et 11 d'`expliquer` 0.2.1 :
   l'essentiel d'abord, une idée par phrase, 20 mots au plus, voix active,
   mots courants, un mot par concept, terme de grammaire défini, rien de superflu.
   Ces règles sont réécrites en consignes pour le modèle dans `RequestFactory`.
   Le skill reste dans Sophos ; seule son application vit ici.

Le format JSON de la révision est écrit une seule fois et sert aux deux modes.

## Options écartées

- Rendre la correction plus poussée : elle ne serait plus minimale. Corriger et
  Reformuler répondent à deux besoins distincts.
- Passer par l'affinage (« reformule plus naturellement ») : il faut le taper à
  chaque fois, après une première correction.
- Demander au modèle de placer l'essentiel en tête du texte reformulé : il
  changerait l'ordre des idées d'un courriel ou d'un message.

## Conséquences et limites

Le raccourci global ⇧⌘R prend la place de ⇧⌘R dans les autres applications
(recharger une page dans Chrome, mode Lecteur dans Safari). Il se change dans
Réglages → Raccourcis.

`Configuration` gagne le champ `rephrasingKey`. Des préférences enregistrées
avant ce changement ne se décodent plus : l'application affiche l'erreur des
préférences illisibles et repart des réglages par défaut. Aucune migration
n'est ajoutée.

Non vérifié : la qualité des reformulations et le respect des règles
d'explication par Gemini, DeepSeek ou un autre modèle. Les tests vérifient la
consigne envoyée, pas la réponse du modèle.
