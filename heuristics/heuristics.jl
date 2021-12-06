#using BSON
include("../games/utictactoe.jl")

function U(game, player)
    """
    Heuristic function for evaluating 
    positions in Ultimate TTT 
    should return 
        10000 if the player wins
        -10000 if the player lost
        heuristic if the neither
    currently evaluates the global positions 

    """
    game_winner = u_has_won(game)
    if (game_winner == player)
        return 10000
    elseif (game_winner == -1 * player)
        return -10000
    end

    w = [[2, 1, 2] [1, 3, 1] [2, 1, 2]]
    u = 0

    macro_uttt_state = [[0, 0, 0] [0, 0, 0] [0, 0, 0]]

    for i = 1:3, j = 1:3
        u += w[i, j] * ttt_util_dict[game.ttt_boards[i,j].board]
        macro_uttt_state[i, j] = has_won(game.ttt_boards[i,j].board)
    end
    
    u += 3 * ttt_util_dict[macro_uttt_state]

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

function eval_ttt_board_2_in_row(board, player)
    """
    Evaluates a ttt board to return a bonus for holding positions
    that "line up" a future 3-in-a-row.
    """
    score = 0

    # Top left corner (TLC) 3-in-row setups
    if (board[1, 1] == board[1, 2] && board[1, 1] == player && board[1,3] != -player) # TLC and LEFT
        score += 2
    end

    if (board[1, 1] == board[1, 3] && board[1, 1] == player && board[1,2] != -player) # TLC and BLC
        score += 2
    end    

    if (board[1, 1] == board[2, 1] && board[1, 1] == player && board[3,1] != -player) # TLC and TOP
        score += 2
    end

    if (board[1, 1] == board[3, 1] && board[1, 1] == player && board[2,1] != -player) # TLC and TRC
        score += 2
    end

    if (board[1, 1] == board[2, 2] && board[1, 1] == player && board[3,3] != -player) # TLC and MID
        score += 2
    end    

    if (board[1, 1] == board[3, 3] && board[1, 1] == player && board[2,2] != -player) # TLC and BRC
        score += 2
    end 

    # Left 3-in-row setups
    if (board[1, 2] == board[1, 3] && board[1, 2] == player && board[1,1] != -player) # LEFT and BLC
        score += 2
    end

    if (board[1, 2] == board[2, 2] && board[1, 2] == player && board[3,2] != -player) # LEFT and MID
        score += 2
    end

    if (board[1, 2] == board[3, 2] && board[1, 2] == player && board[2,2] != -player) # LEFT and RIGHT
        score += 2
    end

    # Bottom left corner (BLC) 3-in-row setups
    if (board[1, 3] == board[2, 3] && board[1, 3] == player && board[3,3] != -player) # BLC and BOT
        score += 2
    end

    if (board[1, 3] == board[3, 3] && board[1, 3] == player && board[2,3] != -player) # BLC and BRC
        score += 2
    end

    if (board[1, 3] == board[2, 2] && board[1, 3] == player && board[3,1] != -player) # BLC and MID
        score += 2
    end

    if (board[1, 3] == board[3, 1] && board[1, 3] == player && board[2,2] != -player) # BLC and TRC
        score += 2
    end

    # Top 3-in-row setups
    if (board[2, 1] == board[2, 2] && board[2, 1] == player && board[2,3] != -player) # TOP and MID
        score += 2
    end

    if (board[2, 1] == board[2, 3] && board[2, 1] == player && board[2,2] != -player) # TOP and BOT
        score += 2
    end

    if (board[2, 1] == board[3, 1] && board[2, 1] == player && board[1,1] != -player) # TOP and TRC
        score += 2
    end

    # Middle (MID) 3-in-row setups
    if (board[2, 2] == board[2, 3] && board[2, 2] == player && board[2,1] != -player) # Mid and BOT
        score += 2
    end

    if (board[2, 2] == board[3, 1] && board[2, 2] == player && board[1,3] != -player) # Mid and TRC
        score += 2
    end

    if (board[2, 2] == board[3, 2] && board[2, 2] == player && board[1,2] != -player) # Mid and RIGHT
        score += 2
    end

    if (board[2, 2] == board[3, 3] && board[2, 2] == player && board[1,1] != -player) # Mid and BRC
        score += 2
    end
    
    # Bottom (BOT) 3-in-row setups
    if (board[2, 3] == board[3, 3] && board[2, 3] == player && board[1,3] != -player) # BOT and BRC
        score += 2
    end

    # Top Right Corner (TRC) 3-in-row setups
    if (board[3, 1] == board[3, 2] && board[3, 1] == player && board[3,3] != -player) # TRC and RIGHT
        score += 2
    end

    if (board[3, 1] == board[3, 3] && board[3, 1] == player && board[3,2] != -player) # TRC and BRC
        score += 2
    end

    # Right 3-in-row setups
    if (board[3, 2] == board[3, 3] && board[3, 2] == player && board[3,1] != -player) # RIGHT and BRC
        score += 2
    end

    return score
end


function precompute_ttt_heuristics()
    w = [[2, 1, 2] [1, 3, 1] [2, 1, 2]]
    dict = Dict{Matrix{Int8}, Int8}()
    for i in 1:(3^9)
        board = zeros(Int8, 3, 3)
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
            board_u += 15 * board_winner
        else 
            board_u += eval_ttt_board_global(board, 1)
            board_u -= eval_ttt_board_global(board, -1)
            board_u += eval_ttt_board_2_in_row(board, 1)
            board_u -= eval_ttt_board_2_in_row(board, -1)
        end
        dict[board] = board_u
    end
    return dict
end

ttt_util_dict = precompute_ttt_heuristics()