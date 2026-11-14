# iPhone : le clavier seul

Date : 2026-11-14 · Statut : acceptée
Décidé par : Antoine (simple, sauf si une autre surface a de la valeur)

## Contexte

L’iPhone a une app éditeur et un clavier. Antoine écrit dans Mail et les autres apps. Il demande si un historique ou une autre surface vaut mieux qu’un clavier seul.

## Décision

Le geste iPhone est le clavier : Corriger, Reformuler, Traduire sur la sélection. L’app ne contient plus d’éditeur. Elle enregistre la clé et le fournisseur, et dit comment activer le clavier. Apple n’installe pas un clavier sans app. L’historique de session reste dans le menu Mac.

## Options

| Option | Effet |
| --- | --- |
| Éditeur iPhone en plus du clavier | Écartée : le même geste deux fois |
| Historique des changements sur iPhone | Écartée : le texte est déjà dans l’app où il a été écrit |
| Clavier, app limitée à la clé | Retenue |

## Conséquences

`ImiHost` et `ImiIOS` ouvrent les réglages. Le panneau et les dix résultats récents restent sur Mac.

## Trace

- Code : `ios/ImiHost/ImiHostApp.swift`, `Sources/ImiIOS/ImiIOSApp.swift`.
- Lié : [clavier iOS](2026-11-13-clavier-ios.md).
