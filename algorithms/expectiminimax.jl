include("../games/utictactoe.jl")
include("../heuristics/heuristics.jl")

struct ExpectiMiniMax
    d # depth
    g # gamma discount factor
end

function choose_action(game::UTicTacToe, algo::ExpectiMiniMax)
    bot_game, transform_idx = setup_bot_game(game)
    best = expectiminimax(bot_game, algo.d, algo.g, bot_game.current_player, false)
    return to_player_move(best.a, transform_idx)
end

function expectiminimax(game::UTicTacToe, d, g, player, is_adversary)
    if (d <= 0 || u_has_won(game) != 0 || isempty(u_valid_moves_all(game)))
        return (a=nothing, u=U(game, player))
    end
    if (is_adversary)
        worst = (a=nothing, u=Inf)
        for a in u_valid_moves_unique(game)
            updated_game = deepcopy(game)
            take_turn(updated_game, a)
            new_a, next_utility = expectiminimax(updated_game, d, g, player, !is_adversary)
            r = U(updated_game, player)
            u = r + g * next_utility
            if (u <= worst.u)
                worst = (a=a, u=u)
            end
        end
        return worst
    else
        best = (a=nothing, u=-Inf)
        for a in u_valid_moves_unique(game)
            updated_game = deepcopy(game)
            take_turn(updated_game, a)
            new_a, next_utility = expectiminimax(updated_game, d-1, g, player, !is_adversary)
            r = U(updated_game, player)
            u = r + g * next_utility
            if (u >= best.u)
                best = (a=a, u=u)
            end
        end
        return best
    end
end