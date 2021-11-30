include("../games/utictactoe.jl")

struct SparseSampling
    m # number of samples
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

function choose_action(game::UTicTacToe, algo::SparseSampling) 
    player = game.current_player
    best = choose_action_helper(game, algo.d, algo.m, algo.g, player)
    return best.a
end

function choose_action_helper(game::UTicTacToe, d, m, g, player)
    if (d <= 0)
        return (a=nothing, u=U(game, player))
    end
    best = (a=nothing, u=-Inf)
    for a in u_valid_moves(game)
        u = 0.0
        for i in 1:m
            updated_game = randstep(game, a)
            r = U(updated_game, player)
            new_a, next_utility = choose_action_helper(updated_game, d-1, m, g, player)
            u += (r + g *next_utility) / m
        end
        if (u > best.u)
            best = (a=a, u=u)
        end
    end
    return best
end

function randstep(uttt::UTicTacToe, a)
    uttt_copy = deepcopy(uttt)
    take_turn(uttt_copy, a)
    rand_move = rand(u_valid_moves(uttt_copy))
    take_turn(uttt_copy, rand_move)
    return uttt_copy
end