include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

struct MonteCarloTreeSearch
    N::Dict{Any, Int64} # visit counts
    Q::Dict{Any, Float64} # action value estimates 
    d::Int16 # depth
    m::Int32 # number of simulations 
    c::Float64 # exploration constant
    γ::Float64 # discount
end 

function choose_action(game::UTicTacToe, algo::MonteCarloTreeSearch)
    for k in 1:algo.m
        simulate!(game, algo, game.current_player)
    end
    valid_mvs = u_valid_moves(game)
    return argmax(a->algo.Q[(get_s(game), a)], valid_mvs)
end 

function simulate!(game::UTicTacToe, algo::MonteCarloTreeSearch, player, d=algo.d)
    if (algo.d <= 0 || u_has_won(game) != 0 || isempty(u_valid_moves(game)))
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
    
    a = explore(algo, s, valid_mvs)
    game′ = randstep(game, a)
    q = U(game′, player) + algo.γ * simulate!(game′, algo, player, algo.d - 1)
    algo.N[(s, a)] += 1
    algo.Q[(s, a)] += (q - algo.Q[(s, a)])/algo.N[(s, a)]
    return q
end

bonus(Nsa, Ns) = Nsa == 0 ? Inf : sqrt(log(Ns)/Nsa)

function explore(algo::MonteCarloTreeSearch, s, valid_mvs) 
    Ns = sum(algo.N[(s,a)] for a in valid_mvs)
    return argmax(a->algo.Q[(s,a)] + algo.c*bonus(algo.N[(s,a)], Ns), valid_mvs)
end 