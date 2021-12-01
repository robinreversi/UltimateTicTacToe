include("../games/utictactoe.jl")

struct ExpectiMiniMax
    d # depth
    g # gamma discount factor
end

function U(s, player)
    """
    TODO: heuristic function
    should return 
        inf if the player wins
        -inf if the player lost
        heuristic if the neither
    
    possibly move into separate heuristic file?
    """
    return 0
end

function choose_action(game::UTicTacToe, algo::ExpectiMiniMax)
    best = expectiminimax(game, algo.d, algo.g, game.player, false)
    return best.a
end

function expectiminimax(game::UTicTacToe, d, g, player, is_adversary)
    if (d <= 0)
        return (a=nothing, u=U(game, player))
    end
    if (is_adversary)
        worst = (a=nothing, u=Inf)
        for a in u_valid_moves(game)
            updated_game = deepcopy(game)
            take_turn(updated_game, a)
            new_a, next_utility = expectiminimax(updated_game, d-1, g, player, !is_adversary) # MEMOIZE!
            r = U(updated_game, player)
            u = r + g * next_utility
            if (u < worst.u)
                worst = (a=a, u=u)
            end
        end
        return worst
    else
        best = (a=nothing, u=-Inf)
        for a in u_valid_moves(game)
            updated_game = deepcopy(game)
            take_turn(updated_game, a)
            new_a, next_utility = expectiminimax(updated_game, d-1, g, player, !is_adversary)
            r = U(updated_game, player)
            u = r + g * next_utility
            if (u > best.u)
                best = (a=a, u=u)
            end
        end
        return best
    end
end

function choose_action_helper(game::UTicTacToe, d, g, player)
    if (d <= 0)
        return (a=nothing, u=U(game, player))
    end
    best = (a=nothing, u=-Inf)
    for a in u_valid_moves(game)
        u = 0.0
        updated_game = choose_adversarial_action(game, a)
        r = U(update_game, player)
        new_a, next_utility = choose_action_helper(updated_game, d-1, g, player)
        u += (r + g * next_utility)
        if (u > best.u)
            best = (a=a, u=u)
        end
    end
    return best
end

function choose_adversarial_action(uttt::UTicTacToe, a)
    uttt_copy = deepcopy(uttt)
    board_xidx, board_yidx, xloc, yloc = convert_action_to_idxs(a)
    take_turn(uttt_copy, board_xidx, board_yidx, xloc, yloc)
    adversarial_move = 
    board_xidx, board_yidx, xloc, yloc = convert_action_to_idxs(rand_move)
    take_turn(uttt_copy, board_xidx, board_yidx, xloc, yloc)
    return uttt_copy
end