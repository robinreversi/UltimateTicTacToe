#using BSON
include("../games/utictactoe.jl")

function U(game, player)
    """
    Heuristic function for evaluating 
    positions in Ultimate TTT 
    should return 
        inf if the player wins
        -inf if the player lost
        heuristic if the neither
    currently evaluates the global positions 

    """
    game_winner = u_has_won(game)
    if (game_winner == player)
        return Inf
    elseif (game_winner == -1 * player)
        return -Inf
    end

    w = [[2, 1, 2] [1, 3, 1] [2, 1, 2]]
    u = 0

    macro_uttt_state = [[0, 0, 0] [0, 0, 0] [0, 0, 0]]

    for i = 1:3, j = 1:3
        u += w[i, j] * ttt_util_dict[game.ttt_boards[i,j].board]
        macro_uttt_state[i, j] = has_won(game.ttt_boards[i,j].board)
    end
    
    u += 2 * ttt_util_dict[macro_uttt_state]

    # adjusts for if the player is the -1 player
    # does nothing if the player is the 1 player
    u *= player

    if game.ttt_boards_x == -1 # if free board choice
        if game.current_player == player
            u += 15
        else
            u -= 15
        end
    end
    return u
end

function eval_ttt_board_global(board, player)
    """
    Evaluates a global score for a ttt board 
    Calculated as the relative values of each
    position 
    """
    w = [[2, 1, 2] [1, 3, 1] [2, 1, 2]]
    player_positions = deepcopy(board)
    player_positions[player_positions.!= player] .= 0
    return sum(broadcast(abs, player_positions) .* w)
end

function eval_ttt_board_opposites(board, player)
    """
    Evaluates opposite_score on a ttt board 
    to return a bonus for holding positions
    that are opposite each other 
    """
    opposite_score = 0
    if (board[1, 1] == board[3, 3] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[1, 3] == board[3, 1] && board[1, 3] == player)
        opposite_score += 2
    end

    if (board[1, 1] == board[1, 3] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[1, 1] == board[3, 1] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[3, 1] == board[3, 3] && board[3, 1] == player)
        opposite_score += 2
    end

    if (board[1, 3] == board[3, 3] && board[1, 3] == player)
        opposite_score += 2
    end

    if (board[2, 1] == board[2, 3] && board[2, 1] == player)
        opposite_score += 2
    end

    if (board[1, 2] == board[3, 2] && board[1, 2] == player)
        opposite_score += 2
    end
    return opposite_score
end


function precompute_ttt_heuristics()
    w = [[2, 1, 2] [1, 3, 1] [2, 1, 2]]
    dict = Dict{Matrix{Int64}, Int64}()
    for i in 1:(3^9)
        board = zeros(Int64, 3, 3)
        c = i
        for j in 1:9
            mark = 0
            if c%3 == 1
                mark = 1
            elseif c%3 == 2
                mark = -1
            end
            board[(j-1) ÷ 3 + 1, (j-1) % 3 + 1] = mark
            c ÷= 3
        end
        board_winner = has_won(board)
        board_u = 0
        if (board_winner != 0) 
            #board_u += w[i, j] * 15 * board_winner # REMOVED w[i,j], WILL HAVE TO INCLUDE THAT OUTSIDE DICT
            board_u += 15 * board_winner
            #macro_uttt_state[i, j] = board_winner
        else 
            board_u += eval_ttt_board_global(board, 1)
            board_u -= eval_ttt_board_global(board, -1)
            board_u += eval_ttt_board_opposites(board, 1)
            board_u -= eval_ttt_board_opposites(board, -1)
        end
        dict[board] = board_u
    end
    return dict
end

ttt_util_dict = precompute_ttt_heuristics()