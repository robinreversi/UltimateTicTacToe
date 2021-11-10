using LinearAlgebra

Base.@kwdef mutable struct TicTacToe
    board::Matrix{Int8} = zeros(Int8, 3, 3) # 3x3 array
    winner::Int32 = nothing # nothing if no one has won, becomes 1 or 2 if someone has won

    function take_turn(current_player::Int8, xloc::Int8, yloc::Int8) 
        board[xloc][yloc] = current_player; 
    end 
    
    function valid_moves()
        # returns a list of tuples of valid positions to play
        return findall(x->x==0, board)
    end

    function display_board()
        displayable_board = zeros(Int8, 3, 3)
        for i=1:3, j=1:3
            if (board[i, j] == 1) 
                displayable_board[i, j] = "x"
            elseif (board[i, j] == -1)
                displayable_board[i, j] = "o"
            end
        end
        display(displayable_board)
    end

end

function has_won(board::Matrix{Int8})
    # returns an Int8 if someone's won, otherwise nothing
    vert_sum = sum(board, 1)
    hori_sum = sum(board, 2)
    diag_sum = tr(board)
    other_diag_sum = tr(reverse(board, dims = 1))
    if (diag_sum == 3 || other_diag_sum == 3 || 3 in vert_sum || 3 in hori_sum) return 1 end
    if (diag_sum == -3 || other_diag_sum == -3 || -3 in vert_sum || -3 in hori_sum) return -1 end
    return 0
end
