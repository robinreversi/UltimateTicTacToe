using LinearAlgebra

mutable struct TicTacToe
    board::Matrix{Int8} # 3x3 array
end

function take_turn(ttt::TicTacToe, current_player::Int8, xloc::Int8, yloc::Int8) 
    ttt.board[xloc, yloc] = current_player; 
end 

function valid_moves(ttt::TicTacToe)
    # returns a list of tuples of valid positions to play
    if (has_won(ttt.board) != 0)
        return []
    end
    return findall(x->x==0, ttt.board)
end

function display_board(ttt::TicTacToe)
    displayable_board = Matrix{Union{Nothing, String}}(nothing, 3, 3)
    for i=1:3, j=1:3
        if (ttt.board[i, j] == 1)
            displayable_board[i, j] = "x"
        elseif (ttt.board[i, j] == -1)
            displayable_board[i, j] = "o"
        end
    end
    display(displayable_board)
end

function has_won(board::Matrix{Int8})
    return ttt_has_won_dict[board]
end

function precompute_ttt_has_won()
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
        # returns an Int8 if someone's won, otherwise nothing
        vert_sum = sum(board, dims=1)
        hori_sum = sum(board, dims=2)
        diag_sum = tr(board)
        other_diag_sum = tr(reverse(board, dims = 1))
        if (diag_sum == 3 || other_diag_sum == 3 || 3 in vert_sum || 3 in hori_sum) dict[board] = 1 
        elseif (diag_sum == -3 || other_diag_sum == -3 || -3 in vert_sum || -3 in hori_sum) dict[board] = -1
        else dict[board] = 0 end
    end
    return dict
end

ttt_has_won_dict = precompute_ttt_has_won()

