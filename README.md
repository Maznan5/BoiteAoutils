# BoiteAoutils
# BoiteAoutils

Nom Prénom Pseudonyme GitHub Rôle
Sitouah Abdeslam abd3l06 Étudiant 1
Lorthios Maximilien Maznan5 Étudiant 2
Le Lirzin Emilien emilien-24 Étudiant 3


Gestion d'un conflit Git

Deux développeurs (A et B) ont travaillé en parallèle sur le fichier monitoring.ps1.

- Le A a amélioré la présentation des informations CPU, RAM et disques.
- Le B a ajouté une fonctionnalité de journalisation avec l'option -Journal.

Les deux modifications concernaient certaines parties communes du fichier, ce qui a provoquer un conflit lors de la fusion.

Le conflit a été résolu en conservant les deux fonctionnalités :
- Présentation améliorée des informations système.
- Enregistrement des mesures et des erreurs dans surveillance.log.

Questions : 
1. Quel est l’intérêt de séparer développements en cours et versions stables ?
Eviter tout problème dans la version en production. Il ne faut pas que la version en production soit modifié à chaud sans vérification. Au risque de causer un conflit et rendre le projet non fonctionnel.

2. Pourquoi imposer une revue de code avant intégration ?
Imposer une revue de code permet une sécurité avant la mise en production, ça permet une vérification supplémentaire et potentiellement moins de conflit. 

3. Quelles situations provoquent un conflit Git et pourquoi sa résolution n’est-elle pas toujours automatique ?
Lorsqu'un même élément modifié par plusieurs personnes et avec un contenu différent est pull sur une même branche. Car Git ne sait pas toujours quelle version choisir et garder.   

4. Quelle différence entre correction classique et correction urgente de production ?
La différence entre fix et hotfix est dans la branche dans laquelle elle est effectuée, lorsqu'une correction doit être faite dans main, il faut créer une hotfix car la correction est urgente et met en péril la production. Quand une correction doit être faite dans develop, on crée une branche fix car ce n'est pas urgent, la branche develop n'étant pas en production.

5. Pourquoi répercuter une correction de production dans les développements en cours ?
Pour éviter que le bug corrigé réapparaisse dans les prochaines versions.


6. Quel est le rôle d’une branche de release ?
Elle permet de préparer une nouvelle version avant sa mise en production.


7. Comment GitHub Projects et les Issues facilitent-ils organisation et traçabilité ?
Grâce aux issues, on peut suivre les différentes tâches du projet et les organiser dans Projects. 

8. Comment retrouver l’origine d’une modification dans l’historique GitHub ?
En regardant l'historique des commits. 
