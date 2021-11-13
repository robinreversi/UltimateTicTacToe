include("/Users/robincheong/Documents/Stanford/CS238/UltimateTicTacToe/games/tictactoe.jl")

mutable struct UTicTacToe
    ttt_boards::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int64 # 1 or -1
    ttt_boards_x::Int64 # designated x ultimate board idx
    ttt_boards_y::Int64 # designated y board idx
end

function set_up(uttt::UTicTacToe)
    # initialize board of boards
    for i = 1:3, j = 1:3
        uttt.ttt_boards[i,j] = TicTacToe(zeros(Int64, 3, 3))
    end
end

function take_turn(uttt::UTicTacToe, board_xidx, board_yidx, xloc, yloc) 
    # should make sure to update designated board idx
    # also accounting for if they've won the board (-1 then)
    uttt.ttt_boards[board_xidx, board_yidx].take_turn(uttt.current_player, xloc, yloc)
    if has_won(uttt.ttt_boards[xloc,yloc].board) == 0
        uttt.ttt_boards_x = xloc
        uttt.ttt_boards_y = yloc
    else
        uttt.ttt_boards_x = -1
        uttt.ttt_boards_y = -1
    end
    uttt.current_player = -uttt.current_player # switches current player
end 

function u_has_won(uttt::UTicTacToe)
    # iterate through boards & check
    win_arr = zeros(Int64, 3, 3)
    for i = 1:3, j = 1:3
        win_arr[i,j] = has_won(uttt.ttt_boards[i,j].board)
    end
    return has_won(win_arr)
end

function whose_turn(uttt::UTicTacToe)
    return uttt.current_player
end

function u_valid_moves(uttt::UTicTacToe, player)
    valid_mvs = Matrix(undef, 0, 3)
    if uttt.ttt_boards_x == -1
        for i = 1:3, j = 1:3
            board_valid_mvs = hcat(i, j, valid_moves(uttt.ttt_boards[i,j])) # 9x3 Matrix{Any} with elements formated as [i,j,CartesianIndex]
            valid_mvs = vcat(valid_mvs, board_valid_mvs)
        end
    else 
        board_valid_mvs = valid_moves(utt.ttt_boards[ttt_boards_x,ttt_boards_y])
        board_valid_mvs = hcat(uttt.ttt_boards_x, uttt.ttt_boards_y, board_valid_mvs) # 9x3 Matrix{Any} with elements formated as [i,j,CartesianIndex]
        valid_mvs = vcat(valid_mvs, board_valid_mvs)
    end
    return valid_mvs
end

function display_board(uttt::UTicTacToe)
    displayable_board = Matrix{Union{Nothing, String}}(nothing, 9, 9)
    for i=1:9, j=1:9
        xloc = (i-1) ÷ 3 + 1
        yloc = (j-1) ÷ 3 + 1
        inner_xloc = (i-1) % 3 + 1
        inner_yloc = (j-1) % 3 + 1
        inner_board_val = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
        if (inner_board_val == 1)
            displayable_board[i, j] = "x"
        elseif (inner_board_val == -1)
            displayable_board[i, j] = "o"
        end
    end
end
ttt_boards = Matrix{Union{Nothing, TicTacToe}}(nothing, 3, 3)
uttt_game = UTicTacToe(ttt_boards, -1, -1, -1)