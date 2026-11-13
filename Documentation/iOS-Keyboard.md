# Clavier iOS — installation et tests manuels

Usage personnel sur iPhone avec compte développeur Apple. Pas de CI GitHub requise.

## Prérequis

- macOS avec **Xcode 16** ou plus, iOS **18** ou plus sur l’appareil
- Branche avec `ios/Graker.xcodeproj` et le package Swift à la racine

## Ouvrir le projet

```sh
cd /chemin/vers/uchi
open ios/Graker.xcodeproj
```

1. Sélectionner le target **Graker** → **Signing & Capabilities** : choisir **Team**, bundle `local.graker.personnel.ios` (ou le vôtre + App Group aligné).
2. Même Team pour **GrakerKeyboard** : `local.graker.personnel.ios.keyboard`.
3. Créer / activer l’App Group **`group.local.graker.personnel`** sur les deux cibles (entitlements déjà dans le dépôt).
4. Brancher l’iPhone, choisir l’appareil, **Run** sur **Graker**.

## Activer le clavier

1. Dans l’app Graker : **Réglages** → **Fournisseur IA** → valider clé et modèle.
2. iOS : **Réglages** → **Général** → **Clavier** → **Claviers** → **Ajouter** → **Graker**.
3. Touche Graker → **Autoriser l’accès complet** (réseau vers le fournisseur).

## Checklist de test

| # | Scénario | Résultat attendu |
|---|----------|------------------|
| 1 | App : coller et corriger | Résultat + copie OK |
| 2 | Mail : sélectionner une phrase, clavier Graker, **Corriger** | Remplacement local + copie presse-papiers |
| 3 | Notes : sélection, **Reformuler** / **Traduire** | Idem |
| 4 | Aucune sélection, toucher un mode | Message « Sélectionnez du texte… », pas d’appel API |
| 5 | Sans clé configurée | Erreur invitant à ouvrir l’app |
| 6 | Sans accès complet au clavier | Erreur réseau visible |
| 7 | Une app réseau de votre usage | Noter si `selectedText` est vide (comportement hôte) |

## Dépannage

- **Clavier absent** : réinstaller l’app depuis Xcode après changement de bundle ou d’App Group.
- **Clé introuvable** : la clé est lue dans le groupe partagé ; revalider le fournisseur dans l’app hôte.
- **Sélection perdue** en passant au clavier Graker : sélectionner **après** avoir affiché le clavier Graker.

## Décision produit

Voir [docs/decisions/2026-11-13-clavier-ios.md](../docs/decisions/2026-11-13-clavier-ios.md).
