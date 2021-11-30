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
    println("===============")
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
        board_winner = has_won(game.ttt_boards[i,j].board)
        board_u = 0
        if (board_winner != 0) 
            board_u += w[i, j] * 15 * board_winner
            macro_uttt_state[i, j] = board_winner
        else 
            board_u += w[i, j] * eval_ttt_board_global(game.ttt_boards[i,j].board, 1)
            board_u -= w[i, j] * eval_ttt_board_global(game.ttt_boards[i,j].board, -1)
            board_u += w[i, j] * eval_ttt_board_opposites(game.ttt_boards[i, j].board, 1)
            board_u -= w[i, j] * eval_ttt_board_opposites(game.ttt_boards[i, j].board, -1)
        end
        u += board_u
        println("DEBUG: Utility for board " * string(i) * ", " * string(j) * " :" * string(board_u))
    end
    u += eval_ttt_board_opposites(macro_uttt_state, 1)
    u -= eval_ttt_board_opposites(macro_uttt_state, -1)

    # adjusts for if the player is the -1 player
    # does nothing if the player is the 1 player
    u *= player
    println("===============")
    println("DEBUG: Utility for the following game from player " * string(player) * "'s perspective: " * string(u))
    display_board(game)
    println()
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

    if (board[3, 1] == board[3, 3] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[1, 3] == board[3, 3] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[2, 1] == board[2, 3] && board[1, 1] == player)
        opposite_score += 2
    end

    if (board[1, 2] == board[3, 2] && board[1, 1] == player)
        opposite_score += 2
    end
    return opposite_score
end