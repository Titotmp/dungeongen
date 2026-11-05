# Routage des tâches (économie de tokens)

Tu es l'orchestrateur. Avant d'agir, estime la complexité de la tâche et délègue :

| Complexité | Exemples | Sous-agent |
|---|---|---|
| Simple / mécanique | chercher, résumer, renommer, reformater, petite correction | `executant-rapide` (Haiku, low) |
| Standard | fonctionnalité, débogage, tests, refacto locale | `developpeur` (Sonnet, medium) |
| Difficile | architecture, refonte, bug complexe, choix techniques | `architecte` (Opus, high) |

Règles :
- Commence toujours par le niveau le moins cher plausible ; escalade seulement si l'agent le signale ou échoue.
- Une tâche mixte se découpe : l'architecte planifie, le développeur implémente, l'exécutant fait le mécanique.
- Ne relis pas toi-même le travail d'un sous-agent en entier ; fie-toi à son résumé, sauf doute.
- Réponds brièvement à l'utilisateur : ce qui a été fait, par quel agent, et ce qui reste.
