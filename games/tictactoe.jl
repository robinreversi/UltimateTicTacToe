using LinearAlgebra

Base.@kwdef mutable struct TicTacToe
    board::Matrix{Int64} = zeros(Int64, 3, 3) # 3x3 array
end

function take_turn(ttt::TicTacToe, current_player::Int64, xloc::Int64, yloc::Int64) 
    ttt.board[xloc, yloc] = current_player; 
end 

function valid_moves(ttt::TicTacToe)
    # returns a list of tuples of valid positions to play
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

function has_won(ttt::TicTacToe)
    # returns an Int8 if someone's won, otherwise nothing
    vert_sum = sum(ttt.board, dims=1)
    hori_sum = sum(ttt.board, dims=2)
    diag_sum = tr(ttt.board)
    other_diag_sum = tr(reverse(ttt.board, dims = 1))
    if (diag_sum == 3 || other_diag_sum == 3 || 3 in vert_sum || 3 in hori_sum) return 1 end
    if (diag_sum == -3 || other_diag_sum == -3 || -3 in vert_sum || -3 in hori_sum) return -1 end
    return 0
end