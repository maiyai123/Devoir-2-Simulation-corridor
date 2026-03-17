# title: Simulation d'aménagement d'un corridor écologique sous ligne haute tension
# repository: Devoir-2-Simulation-corridor
# auteurs:
#    - nom: Koné
#      prenom: Maimouna
#      matricule: 20234378
#      github: maiyai123

# # Introduction

# Dans les écosystèmes naturels, la répartition de la végétation change et progresse constamment sous divers effets de processus écologiques tels que la colonisation, la compétition, 
# la mortalité et les polluants environnementaux ou atmosphériques. Dans un corridor écologique, ces interactions déterminent en général si certaines espèces végétales ont un progrès 
# linéaire, disparaissent ou alors évoluent pour ensuite dominer le paysage. Malheureusement les méthodes scientifiques écologiques ne permettent pas de bien étudier les systèmes naturels
# à long terme sans interventions humaines. Pour remédier à ce souci, les modèles informatiques simulent ces dynamiques écologiques afin de mieux comprendre l’évolution spatiale et temporelle 
# des communautés végétales. Plus spécifiquement, certains modèles probabilistes permettent de représenter les divergences (ou similarités) possibles entre différents états écologiques. 

# L'enjeu central de cette simulation réside dans l'équilibre entre la sécurité des infrastructures de transport d'énergie (lignes à haute tension) et le maintien d'une biodiversité fonctionnelle. 
# Le corridor de 200 parcelles, initialement nu, représente une opportunité de gestion active où l'intervention humaine (plantation initiale de 50 parcelles) doit anticiper les successions naturelles.
# Le succès est évalué selon un mandat strict : atteindre un équilibre de 20% de végétalisation (30% d'herbes, 70% de buissons) avec une diversité interne où la variété de buisson la moins 
# représentée occupe au moins 30% de l'espace arbustif. Ensuite une comparaison d’un modèle déterministe (équilibre théorique) à un modèle stochastique sera faite pour vérifier que ces critères
# sont respectés dans au moins 80% des cas.

# Ce code tente de démontrer un corridor écologique modélisé comme une série de parcelles pouvant contenir différents types de végétation. Cette simulation tente alors de comprendre comment et à 
# quelle intensité les probabilités de processus écologiques (colonisation, mortalité, etc.) influencent la proportion de parcelles vides, d'herbes et de deux types de buissons au fil des années.
# En théorie, des systèmes dynamiques stochastiques équilibrés, ayant des probabilités de transition constantes, devraient s'incliner vers un état d’équilibre statistique. Donc avec des paramètres
# conforme, ce code, dans cet état, et à la suite d’années de génération, démontrât que les proportions moyennes des différents types de végétation deviennent relativement stables malgré les fluctuations aléatoires.

# # Présentation du modèle

# Les packages nécessaires pour simuler le code.
using Random 
using CairoMakie # Pour créer des graphiques.
using StatsBase # Fournit des fonctions statistiques (tirage aléatoire avec probabilités).
using ProgressMeter # Affiche une barre de progression pendant les simulations.

Random.seed!(123456) # Garantit des résultats reproductibles.

# Les paramètres pour le corridor.
taille_corridor = 200 # Établie le nombre de parcelles.
epochs = 1:500 # Intervalle représentant les générations au fil du temps.
n_simulations = 100 ## Nombre de simulations qui seront exécuter afin de comparer avec un 
# résultats d'un modèle non stochastique.

# Population initiale
s_initial = [150, 0, 25, 25]

states_names  = ["Vide", "Herbe", "Buisson A", "Buisson B"]
states_colors = [:grey90, :lightgreen, :darkgreen, :saddlebrown]

# La matrice des mandats pour le code.
P_matrice = [
    0.975  0.0075 0.00875 0.00875  # Parcelle : Vide (V)
    0.10   0.90   0.00    0.00     # Parcelle : Herbe (H)
    0.10   0.00   0.90    0.00     # Parcelle : Buisson A (BA)
    0.10   0.00   0.00    0.90     # Parcelle : Buisson B (BB)
    ]
# Explication première ligne ou la parcelle est Vide (V): 
# 97.5% chance de rester vide 
# 0.75% chance de devenir herbe 
# 0.875% chance de devenir buisson A 
# 0.875% chance de devenir buisson B

# Fonction pour vérifier la matrice des transitions.
function check_transition_matrix!(T)
    for ligne in axes(T, 1) # Boucle sur toutes les lignes de la matrice
        if abs(sum(T[ligne, :]) - 1.0) > 1e-8 # V/rification que la sommme 
            # des elements de la ligne est ~ proche de 1. Ici, 1e-8 est un seuil de tolérance 
            # en calcul numérique
            T[ligne, :] ./= sum(T[ligne, :]) # Normalise la ligne en divisant chaque 
            # élément par la somme totale.
        end
    end
    return T
end
check_transition_matrix!(P_matrice)

# Fonctions afin d'executer les paramètres initiaux.
function _gerer_transition!(change, pos, etat, matrice) # fonction qui calcule les états 
    # d'une seule parcelle. Le point d'exclamation signifie que la fonction modifie 
    # les tableaux passés en arguments.
    poids = StatsBase.Weights(matrice[etat[pos] + 1, :]) # Cette fonction identifie la ligne 
    # de la matrice correspondant à l'état actuel. etat[pos] + 1 donne l'état de la parcelle 
    # et transforme les probabilités en poids pour l'échantillonnage.
    change[pos] = StatsBase.sample(0:3, poids) # Cette fonction tire aléatoirement un nouvel 
    # état parmi 0,1,2,3 et le tirage est pondéré par les probabilités de la matrice.
end

function sim_corridor!(change, etat, matrice) # Cette fonction applique une transformation 
    # stochastique à tout le corridor.
    for i in eachindex(etat) # Donne une boucle sur toutes les parcelles du corridor.
        _gerer_transition!(change, i, etat, matrice) # Et ensuite, applique la fonction
        # de transformation à chaque parcelle
    end
    etat .= change # Permet de mettre à jour l'état du corridor avec les nouveaux états 
    # calculés. .= dans Julia signifie modification élément par élément.
    return (count(iszero, etat), count(isequal(1), etat),
            count(isequal(2), etat), count(isequal(3), etat)) 
    # Cette fonction compte combien de parcelles sont dans chaque état et retourne une liste
    # de programmation contenant le bilan de nombres de vides, d'herbes, de buissons A et B.
end

function evaluer_mandat(etat)
    # Vérifie si le corridor respecte le mandat écologique
    V = count(iszero, etat)
    H = count(isequal(1), etat)
    BA = count(isequal(2), etat)
    BB = count(isequal(3), etat)

    veg = H + BA + BB # Calcule le nombre total de parcelles végétalisées (tout sauf vide).
    buissons = BA + BB # Calcule le nombre total de buissons.

    cond1 = 37 <= veg <= 43 #Vérifie que le corridor a entre 37 et 43 parcelles 
    # végétalisées (20 % du corridor de 200 parcelles).
    cond2 = veg > 0 && isapprox(H/veg,0.30, atol=0.05) && isapprox(buissons/veg,0.70, atol=0.05)
    # Vérifie que : Il y a au moins une parcelle végétalisée. La proportion d’herbe est
    # proche de 30 % (tolérance ±5 %). La proportion de buissons est proche de 70 % 
    # (tolérance +/- 5 %).
    cond3 = buissons > 0 && (min(BA,BB)/buissons) >= 0.3
    # Vérifie que la variété de buissons est respectée : la moins abondante 
    # des deux espèces représente au moins 30 % du total des buissons.

    return cond1 && cond2 && cond3 #Retourne true seulement si toutes les conditions du
    # mandat écologique sont respectées, sinon false.
end

function simulation_deterministe(states::Vector{Float64}, transitions::Matrix{Float64}, generations::Int)
    # Cette fonction va calculer l’évolution déterministe (moyenne théorique) des états
    # du corridor.
    timeseries = zeros(Float64, length(states), generations+1) # Crée une matrice timeseries
    # pour stocker l’évolution de chaque état dans le temps. Chaque ligne correspond à 
    # un état (V, H, BA, BB), chaque colonne à une génération.
    timeseries[:,1] .= states #Initialise la première colonne de timeseries avec les 
    # valeurs initiales de states.".=" signifie assignation élément par élément.
    for gen in 1:generations # Boucle sur toutes les générations à simuler
        timeseries[:, gen+1] .= (timeseries[:, gen]' * transitions)' # Calcule l’évolution 
        # déterministe pour la génération suivante. Cette opération donne le nombre attendu
        # de parcelles dans chaque état à la génération suivante.
    end
    return timeseries
end

# Rassemlbe les paramètres du mandats.
global succes_count = 0 # Compte le nombre de simulations respectant le mandat.
historique_spatial = zeros(Int64, taille_corridor, length(epochs)) # Elle établit une matrice 
# qui stocke l'état spatial du corridor dans le temps ou 
# lignes (axe Y) = parcelles et colonnes (axe X) = générations
V_evo = zeros(Int64, length(epochs))
H_evo = zeros(Int64, length(epochs))
BA_evo = zeros(Int64, length(epochs))
BB_evo = zeros(Int64, length(epochs))
# Les quatre tableaux pour stocker l'évolution du nombre de parcelles vides, 
# d'herbes, de buissons A et B.

@showprogress "Simulations..." for s in 1:n_simulations # La boucle qui exécute toutes 
    # les simulations et affiche une barre de progression.
    corridor = zeros(Int64, taille_corridor)
    corridor_change = zeros(Int64, taille_corridor)
# Les deux corridors du départ qui affiche les parcelles vides et celles à venir.

    # Initialisation des buissons (plantation)
    corridor[1:25] .= 2  # Buisson A
    corridor[26:50] .= 3 # Buisson B
# En se basant sur le mandat, les 25 premières parcelles deviennent Buisson A 
# et les parcelles 26 à 50 deviennent Buisson B.
    for t in epochs # Boucle sur les générations qui met à jour l'état du corridor
        # à chaque étape.
        res = sim_corridor!(corridor_change, corridor, P_matrice) # Afin de mettre à 
        # jour l'état de chaque parcelle en fonction de la matrice de transition P_matrice.
        if s == n_simulations
            # Stocke les évolutions pour la dernière simulation
            V_evo[t], H_evo[t], BA_evo[t], BB_evo[t] = res # Stocke le nombre de parcelles 
            # dans chaque état (V, H, BA,B) dans les tableaux V_evo, H_evo, BA_evo, BB_evo.
            historique_spatial[:, t] .= corridor # Enregistre la configuration spatiale 
            # dans historique_spatial pour la visualisation finale.
        end
    end

    # Vérification du mandat écologique
    if evaluer_mandat(corridor)
        global succes_count += 1
    end
end

println("Proportion de simulations respectant le mandat : ", round(succes_count/n_simulations*100, digits=1), "%")


deterministe = simulation_deterministe(Float64.(s_initial), P_matrice, length(epochs))

# Visualisation finale.
palette_corridor = cgrad([:white, :lightgreen, :darkgreen, :saddlebrown], 4; categorical=true)
fig = Figure(resolution=(1600,900), fontsize=16)
# Ces deux fonctions etablie les vouleurs du graphiques et les dimensions du texts.

# Heatmap stochastique
ax_map = Axis(fig[1:4, 1], title="Évolution du corridor", xlabel="Générations", ylabel="Parcelles")
heatmap!(ax_map, historique_spatial, colormap=palette_corridor)

# Graphiques par état
ax_v  = Axis(fig[1, 2], title="Vides")
ax_h  = Axis(fig[2, 2], title="Herbes")
ax_ba = Axis(fig[3, 2], title="Buissons A")
ax_bb = Axis(fig[4, 2], title="Buissons B")

# Lignes d’évolution stochastiques
lines!(ax_v, epochs, V_evo, color=:black, label="Stochastique")
lines!(ax_h, epochs, H_evo, color=:lightgreen, label="Stochastique")
lines!(ax_ba, epochs, BA_evo, color=:darkgreen, label="Stochastique")
lines!(ax_bb, epochs, BB_evo, color=:saddlebrown, label="Stochastique")

# Lignes déterministes
lines!(ax_v, epochs, deterministe[1,2:end], color=:black, linewidth=3, linestyle=:dash, label="Déterministe")
lines!(ax_h, epochs, deterministe[2,2:end], color=:lightgreen, linewidth=3, linestyle=:dash, label="Déterministe")
lines!(ax_ba, epochs, deterministe[3,2:end], color=:darkgreen, linewidth=3, linestyle=:dash, label="Déterministe")
lines!(ax_bb, epochs, deterministe[4,2:end], color=:saddlebrown, linewidth=3, linestyle=:dash, label="Déterministe")

axislegend(ax_bb, position=:rb)
current_figure()
# Finalement l'affiche de la figure finale

# # Présentation des résultats

# La simulation du corridor de 200 parcelles avec deux espèces de buissons et des herbes montre une dynamique stochastique complexe. La heatmap qui montre l’évolution spatiale du corridor sur
# 500 générations et les graphiques de séries temporelles montrent que les proportions moyennes des parcelles vides, d’herbes et de buissons oscillent autour de valeurs stables avec de petites 
# fluctuations aléatoires. Comparées au système déterministe (ligne pointillée) , les fréquences stochastiques présentent des variations notables d’une génération à l’autre, attestant que même # 
# avec des probabilités de transition établies, l’atteinte du mandat est incertaine. En effet, seules 31 % des simulations respectent le mandat écologique de 20 % de végétalisation et de 30/70 % 
# herbes/buissons, ce qui indique que les probabilités choisies ne garantissent pas la conformité à l’objectif dans la majorité des cas. La comparaison avec le modèle déterministe montre que ce dernier 
# atteint l’équilibre théorique attendu, mais que les fluctuations stochastiques rendent cet équilibre difficilement réalisable à chaque simulation individuelle.

# Discussion
# Les résultats indiquent la différence entre la prévision théorique et la dynamique réelle stochastique. Le faible taux de succès (31 %) met en évidence la sensibilité du corridor aux variations
# aléatoires et la difficulté de gérer un corridor écologique dans un contexte probabiliste. La structure de plantation initiale (25 parcelles pour chaque buisson) permet un équilibre initial, mais 
# les probabilités de colonisation et de maintien des états (97,5 % pour vide, 90 % pour buissons et herbes) favorisent la dominance des parcelles vides et limitent la réussite du mandat. Cela suggère
# que la gestion active d’un corridor nécessite des ajustements continus et que la simple plantation initiale peut être insuffisante pour garantir un objectif strict.

# Limite
# Bien que ce code permette d’illustrer les dynamiques écologiques probabilistes, il comporte plusieurs simplifications importantes.
# Les parcelles évoluent indépendamment les unes des autres, alors que dans la réalité les interactions entre plantes peuvent influencer fortement les dynamiques locales. De plus, pour cette simulation,
# il est forcément supposé que l'environnement est constant et homogène au long de plusieurs années alors qu'en vrai, un écosystème fait face à des conditions environnementales qui peuvent varier 
# drastiquement et en conséquence y bénéficier ou non. Similairement, le modèle ne considère pas la dispersion des graines, la compétition interspécifique ou les perturbations naturelles. Avec seulement 200 parcelles, 
# la variabilité stochastique est amplifiée, ce qui peut exagérer les fluctuations par rapport à des corridors plus étendus. Ces limitations expliquent pourquoi le taux de réussite du mandat est inférieur à 50 %,
# malgré des paramètres théoriques qui devraient, en moyenne, permettre d’atteindre l’équilibre.

# Conclusion
# Cette simulation montre que, même avec un plan de plantation initial complexe et une matrice de transition définie, l’atteinte des objectifs écologiques dans un corridor est fortement influencée par 
# la stochasticité naturelle. La majorité des parcelles restent vides, tandis que les herbes et les buissons persistent à faible densité. Le faible taux de succès (31 %) indique qu’un mandat strict
# nécessite des interventions répétées ou des ajustements des probabilités de transition pour augmenter les chances de réussite. Le modèle reste cependant un outil utile pour explorer les dynamiques
# végétales et tester différents scénarios de gestion, permettant de visualiser les effets de la stochasticité et de mieux comprendre les défis associés à l’aménagement de corridors écologiques sous
# lignes à haute tension. 

