## Dépôt modèle pour le cours BIO 2045

# Description du mandat
# Ce projet vise à simuler l'aménagement d'un corridor écologique de 200 parcelles situé sous une ligne électrique à haute tension. L'objectif est de créer un code qui simule une stratégie d'intervention humaine et 
# d'identifier une dynamique écologique permettant d'atteindre un équilibre durable entre la biodiversité et la sécurité des infrastructures.
# Le succès du projet est défini par le respect des critères suivants dans au moins 80% des simulations stochastiques :
# 1. Végétalisation: 20 %% des parcelles doivent être occupées par de la végétation à l'équilibre.
# 2. Composition : Parmi les parcelles végétalisées, 30% doivent être des herbes et 70% des buissons.
# 3. Diversité des buissons : La variété de buisson la moins abondante doit représenter au moins 30% du total des buissons.
# 4. Contrainte initiale : Le corridor est initialement vide, mais une intervention permet de planter un maximum de 50 parcelles au départ.
# L'efficacité du modèle est alors comparée et validée par la comparaison entre des simulations stochastiques (incluant le hasard écologique) et un modèle déterministe.

## Organisation du projet
# travail.jl : Ce document contient l'intégralité du code de simulation, les analyses statistiques et le rapport final. 
# references.bib : Fichier au format BibTeX contenant l'ensemble des sources et références scientifiques citées dans le rapport.

## ETC
# Le projet est réalisé avec le langage Julia et les résultats sont présentés sous forme de graphiques temporels et de cartes spatiales (heatmaps) générés avec CairoMakie.
