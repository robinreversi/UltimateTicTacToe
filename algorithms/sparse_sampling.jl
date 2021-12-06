include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

struct SparseSampling
    m # number of samples
    d # depth
    g # gamma discount factor
end

function choose_action(game::UTicTacToe, algo::SparseSampling) 
    bot_game, transform_idx = setup_bot_game(game)
    best = simulate!(bot_game, algo.d, algo.m, algo.g, bot_game.current_player)
    return to_player_move(best.a, transform_idx)
end

function simulate!(game::UTicTacToe, d, m, g, player)
    if (d <= 0 || u_has_won(game) != 0 || isempty(u_valid_moves_all(game)))
        return (a=nothing, u=U(game, player))
    end
    best = (a=nothing, u=-Inf)
    valid_moves = u_valid_moves_unique(game)
    for a in valid_moves
        u = 0.0
        for i in 1:m
            updated_game = randstep(game, a)
            r = U(updated_game, player)
            next_utility = 0
            new_a, next_utility = simulate!(updated_game, d-1, m, g, player)
            u += (r + g * next_utility) / m
        end
        if (u >= best.u)
            best = (a=a, u=u)
        end
    end
    return best
end
