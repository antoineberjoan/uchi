# Fondation — 7 novembre 2026

## Décision

Construire une application macOS 15 en SwiftUI. Employer AppKit seulement pour
les fenêtres, le presse-papiers et l'activation ; Accessibilité pour la sélection ;
Carbon pour les raccourcis globaux. L'utilisateur a accepté la base native avec
ses clés API dans ce chat, puis demandé pourquoi AppKit apparaît.

Trois directions examinées : interface native ; coque SwiftUI et WebView
Tailwind ; interface web locale avec compagnon natif. La première évite deux
systèmes de vues et suit l'interface de la référence. La WebView apporte
Tailwind, au prix d'un pont supplémentaire et de deux modèles d'accessibilité.
Une interface web seule ne peut pas remplacer la sélection d'une autre app.

## Qualité et preuve

Facettes, chacune notée de 1 à 5 sur Mac : discrète (alerte : fenêtre qui gêne
la saisie), claire (action ambiguë), fiable (sélection remplacée à tort), rapide
à manipuler (étape inutile), soignée (état d'erreur ou clavier incomplet).
Minimum 3 partout ; fiabilité minimum 4. Pas de note inventée sans observation.
Le prototype Linux ne reçoit pas de note visuelle native.

Observer d'abord la structure, puis l'interaction, puis la finition. La référence
publiée montre un panneau arrondi translucide, saisie au-dessus, barre de modes,
résultat, explication et champ d'affinage. Les réglages ont une barre latérale.
Pas d'animation sur l'action fréquente au clavier ; transitions standard macOS
seulement sur les surfaces occasionnelles. Accent bleu réservé à l'action et au
focus. Rouge et vert servent aux états, pas à une seconde marque.

## Tokens et couches

Source unique : `Design/tokens.css`. Primitives en OKLCH, gris chaud et bleu,
échelles de clarté ; chaque rôle est défini en clair et en sombre. Base d'espace
de 4 points, rayons en peu de pas, typographie système, dimensions de panneau
440 et 840 points comme le journal de Graker. Les points SwiftUI reprennent
les valeurs logiques du fichier CSS ; aucune page web ni Tailwind à l'exécution.
Le générateur convertit les couleurs en sRGB et fabrique les rôles SwiftUI.
Les primitives restent privées au générateur. Les variantes n'apparaissent
qu'avec leurs composants. Le vérificateur contrôle les usages, les renvois, les
contrastes AA du texte, 3:1 du focus et l'absence de valeurs visuelles brutes.

Le noyau pur reçoit toutes ses entrées. Réseau, préférences, trousseau et
accessibilité vivent dans des adaptateurs. Les vues ne construisent pas les
requêtes. Les résultats IA sont variables ; le transport ne promet aucun
déterminisme du modèle, seulement des règles reproductibles de préparation,
validation et traitement des erreurs.

## Contrats

| Module | Entrée | Sortie | Refus et erreurs visibles |
|---|---|---|---|
| Configuration | fournisseur, base HTTPS, modèle, clé | configuration validée | adresse avec identifiant, query, fragment, modèle vide ; HTTP sauf loopback |
| Requête | source, mode, scène, langues, affinage, résultat précédent | requête chat compatible OpenAI | source vide, taille excessive ; source isolée comme donnée JSON |
| SSE | lignes reçues | texte incrémental et fin | JSON invalide, événement d'erreur, fin prématurée, refus ou troncature |
| Révision | réponse JSON de correction | texte corrigé et changements expliqués | format incomplet ou corrections incohérentes ; aucun résultat factice |
| Sélection | application active et permission | élément, plage, texte et ancre | permission absente, sélection vide, champ protégé |
| Remplacement | sélection capturée, texte résultat | écriture dans la sélection d'origine | application fermée, sélection changée, attribut non modifiable ; aucun collage simulé |
| Trousseau | compte lié à l'adresse validée | clé | erreur OS visible ; rien dans UserDefaults |
| Réseau | requête et clé, délai 240 s | flux ou erreur | HTTP non réussi, redirection, réponse non SSE, délai dépassé ; aucun repli |
| Historique | résultat réussi | dix entrées en mémoire | aucune sauvegarde des textes sur disque |

Schémas réseau : format Chat Completions et SSE OpenAI ; Gemini via son endpoint
de compatibilité OpenAI ; DeepSeek via son endpoint compatible. Un modèle peut
refuser ce contrat : l'erreur remonte, sans changer de modèle. Les exemples
officiels consultés sont cités dans le README de `Platform` lors de l'implémentation.

## Limites assumées

Aucun accès au code source de Graker. Pas de promesse d'identité interne.
La fidélité se juge par observation sur Mac. Pas de mise à jour automatique
depuis un serveur pour cet outil local. Pas de conservation garantie des images
et styles internes d'une sélection HTML. Pas de dépôt distant, issue ou PR
inventés ; le circuit GitHub de Sophos attend un éventuel hébergement ultérieur.
