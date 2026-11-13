# Clavier iOS — installation et tests manuels

Usage personnel sur iPhone avec compte développeur Apple. Pas de CI GitHub requise.

## Prérequis

- macOS avec **Xcode 16** ou plus, iOS **18** ou plus sur l’appareil
- Branche avec `ios/Imi.xcodeproj` et le package Swift à la racine

## Ouvrir le projet

```sh
cd /chemin/vers/uchi
open ios/Imi.xcodeproj
```

1. Sélectionner le target **Imi** → **Signing & Capabilities** : choisir **Team**, bundle `local.imi.personnel.ios` (ou le vôtre + App Group aligné).
2. Même Team pour **ImiKeyboard** : `local.imi.personnel.ios.keyboard`.
3. Créer / activer l’App Group **`group.local.imi.personnel`** sur les deux cibles (entitlements déjà dans le dépôt).
4. Brancher l’iPhone, choisir l’appareil, **Run** sur **Imi**. Le nom affiché sur l’iPhone est imi.

## Activer le clavier

1. Dans l’app imi : **Réglages** → **Fournisseur IA** → valider clé et modèle.
2. iOS : **Réglages** → **Général** → **Clavier** → **Claviers** → **Ajouter** → **imi**.
3. Touche imi → **Autoriser l’accès complet** (réseau vers le fournisseur).

## Checklist de test

| # | Scénario | Résultat attendu |
|---|----------|------------------|
| 1 | App : coller et corriger | Résultat + copie OK |
| 2 | Mail : sélectionner une phrase, clavier imi, **Corriger** | Remplacement local + copie presse-papiers |
| 3 | Notes : sélection, **Reformuler** / **Traduire** | Idem |
| 4 | Aucune sélection, toucher un mode | Message « Sélectionnez du texte… », pas d’appel API |
| 5 | Sans clé configurée | Erreur invitant à ouvrir l’app |
| 6 | Sans accès complet au clavier | Erreur réseau visible |
| 7 | Une app réseau de votre usage | Noter si `selectedText` est vide (comportement hôte) |

## Dépannage

- **Clavier absent** : réinstaller l’app depuis Xcode après changement de bundle ou d’App Group.
- **Clé introuvable** : la clé est lue dans le groupe partagé ; revalider le fournisseur dans l’app hôte.
- **Sélection perdue** en passant au clavier imi : sélectionner **après** avoir affiché le clavier imi.

## Décision produit

Voir [docs/decisions/2026-11-13-clavier-ios.md](../docs/decisions/2026-11-13-clavier-ios.md).
