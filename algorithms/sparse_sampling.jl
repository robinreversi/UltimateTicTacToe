include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

struct SparseSampling
    m # number of samples
    d # depth
    g # gamma discount factor
end

function choose_action(game::UTicTacToe, algo::SparseSampling) 
    best = choose_action_helper(game, algo.d, algo.m, algo.g, game.current_player)
    return best.a
end

function choose_action_helper(game::UTicTacToe, d, m, g, player)
    if (d <= 0 || u_has_won(game) != 0 || isempty(u_valid_moves(game)))
        return (a=nothing, u=U(game, player))
    end
    best = (a=nothing, u=-Inf)
    valid_moves = u_valid_moves(game)
    for a in valid_moves
        u = 0.0
        for i in 1:m
            updated_game = randstep(game, a)
            r = U(updated_game, player)
            next_utility = 0
            new_a, next_utility = choose_action_helper(updated_game, d-1, m, g, player)
            u += (r + g * next_utility) / m
        end
        if (u >= best.u)
            best = (a=a, u=u)
        end
    end
    return best
end
