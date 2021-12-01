include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

struct MonteCarloTreeSearch
    N # visit counts
    Q # action value estimates 
    d # depth
    m # number of simulations 
    c # exploration constant
    γ # discount
end 

function choose_action(game::UTicTacToe, algo::MonteCarloTreeSearch)
    for k in 1:algo.m
        simulate!(game, algo, game.current_player)
    end
    valid_mvs = u_valid_moves(game)
    return argmax(a->algo.Q[(get_s(game), a)], valid_mvs)
end 

function simulate!(game::UTicTacToe, algo::MonteCarloTreeSearch, player, d=algo.d)
    if (algo.d <= 0 || has_won(game) != 0 || isempty(u_valid_moves(game)))
        return U(game, player)
    end
    s = get_s(game)
    valid_mvs = u_valid_moves(game)
    
    if (!haskey(algo.N, (s, first(valid_mvs))))
        for a in valid_mvs
            algo.N[(s, a)] = 0
            algo.Q[(s, a)] = 0.0
        end
        return U(game, player)
    end
    
    a = explore(algo, s)
    game′ = randstep(game, a)
    q = U(game′, player) + algo.γ * simulate!(game′, algo, player, algo.d - 1)
    algo.N[(s, a)] += 1
    algo.Q[(s, a)] += (q - algo.Q[(s, a)])/algo.N[(s, a)]
    return q
end

bonus(Nsa, Ns) = Nsa == 0 ? Inf : sqrt(log(Ns)/Nsa)

function explore(algo::MonteCarloTreeSearch, s) 
    valid_mvs = u_valid_moves(game)
    Ns = sum(N[(s,a)] for a in valid_mvs)
    return argmax(a->algo.Q[(s,a)] + algo.c*bonus(algo.N[(s,a)], Ns), valid_mvs)
end 