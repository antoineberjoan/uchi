# Contrat réseau

Exemples officiels lus le 7 novembre 2026 :

- [Compatibilité OpenAI de Gemini](https://ai.google.dev/gemini-api/docs/openai) :
  base `https://generativelanguage.googleapis.com/v1beta/openai/`, clé Bearer,
  modèle explicite et `chat.completions.create`.
- [OpenAI Cookbook : streaming](https://github.com/openai/openai-cookbook/blob/main/examples/How_to_stream_completions.ipynb) :
  `choices[0].delta.content`, delta initial vide, dernier delta sans contenu et
  `finish_reason: stop`. Le transport traite les événements SSE et `[DONE]`.

Le client envoie `model`, `messages`, `stream: true`. Il n'impose ni température,
ni `max_tokens`, ni option de JSON propre à un fournisseur. Il exige la fin du
protocole et refuse un résultat interrompu. Les réponses de correction sont
validées séparément du transport. Le texte progressif n'autorise aucun remplacement.

Le client découpe lui-même les octets en lignes avec `LineDecoder`. Une ligne
vide ferme un événement SSE. `URLSession.AsyncBytes.lines` saute ces lignes
([forum Apple](https://developer.apple.com/forums/thread/725162)) : les
événements fusionnent et le JSON devient illisible. Le texte progressif est
transmis à l'affichage au plus toutes les 80 ms.

Les URL n'acceptent ni identifiant intégré, ni paramètres, ni fragment. HTTP est
réservé au loopback explicitement configuré. Le transport refuse les redirections.
La clé reste associée à l'adresse configurée dans le trousseau ; modifier une
adresse ne récupère pas la clé d'une autre adresse. Pas de télémétrie ni de logs
de requête, pas de cache HTTP, pas de cookies, pas de fournisseur de secours.

Les modèles suggérés sont des champs modifiables. Leur disponibilité dépend du
compte du fournisseur. Aucun appel authentifié n'a été effectué lors de la
construction sous Linux ; les exemples sont des contrats, pas des preuves
qu'une clé ou un modèle particulier fonctionne.
