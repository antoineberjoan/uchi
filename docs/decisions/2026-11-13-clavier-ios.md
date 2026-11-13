# Clavier iOS

Date : 2026-11-13 · Statut : acceptée
Décidé par : Antoine (saisie ailleurs, sélection prioritaire)

## Contexte

Sur iOS, pas d’équivalent Accessibilité pour lire la sélection dans Mail ou les réseaux. L’app intégrée couvre collage et saisie ; l’objectif est d’agir pendant la rédaction ailleurs.

## Décision

Ajouter une **extension clavier** iOS. Actions **Corriger**, **Reformuler**, **Traduire** sur **`selectedText`** quand l’app hôte l’expose ; sinon message explicite sans appel API. Résultat par **`insertText`**. Préférences et trousseau via **App Group** `group.local.imi.personnel` ; clés saisies dans l’app hôte seulement. **Accès complet** au clavier requis pour le réseau. Projet Xcode sous `ios/` pour install sur appareil développeur.

## Options

| Option | Risque |
| --- | --- |
| App seule + collage | Écarté : trop de gestes |
| Extension Partager | Complément ultérieur, pas le flux « pendant la saisie » |
| Clavier personnalisé | Retenu |
| AX système | Impossible tierce partie |

## Conséquences

Pas de `RevisionView` complète dans le clavier ; copie / insertion. Comportement variable selon l’app hôte. Mac inchangé (panneau + AX).

## Trace

- Code : `Sources/ImiKeyboard/`, `ios/`
- Lié : [plateformes Apple](2026-11-13-plateformes-apple.md), tests : [Documentation/iOS-Keyboard.md](../../Documentation/iOS-Keyboard.md)
