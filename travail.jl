# ---
# title: Intervention - Feu de fôret
# repository: Devoir-2-Feux-de-F-ret
# auteurs:
#    - nom: Koné
#      prenom: Maimouna
#      matricule: 20234378
#      github: maiyai123

# # Introduction

# # Présentation du modèle

# # Implémentation

# ## Packages nécessaires

import Random
Random.seed!(123456)
using CairoMakie

# ## Une autre section

"""
    foo(x, y)

Cette fonction ne fait rien.
"""
function foo(x, y)
    ## Cette ligne est un commentaire
    return nothing
end

# # Présentation des résultats

# La figure suivante représente des valeurs aléatoires:

hist(randn(100))

# # Discussion

# On peut aussi citer des références dans le document `references.bib`,
# @ermentrout1993cellular -- la bibliographie sera ajoutée automatiquement à la
# fin du document.
