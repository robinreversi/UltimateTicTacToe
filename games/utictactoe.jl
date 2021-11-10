using TicTacToe

Base.@kwdef mutable struct UTicTacToe
    board::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    turn::Int8 = 1 # 1 or -1
    designated_board_idx::Int8 = -1
    winner::Int32 = nothing # nothing if no one has won, becomes 1 or 2 if someone has won

    function set_up()
        # initialize board
    end

    function take_turn(board_idx, loc) 
        # should make sure to update designated board idx
        # also accounting for if they've won the board (-1 then)
    end 
    
    function has_won()
        # iterate through boards & check
    end
    
    function whose_turn()
    end
    
    function valid_moves(player)
        # should account for -1 designated board idx
    end

    function display_board()
    end

end



