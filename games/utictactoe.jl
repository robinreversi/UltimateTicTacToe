using TicTacToe

Base.@kwdef mutable struct UTicTacToe
    board::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int8 = 1 # 1 or -1
    designated_board_xidx::Int8 = -1
    designated_board_yidx::Int8 = -1
    winner::Int8 = nothing # nothing if no one has won, becomes 1 or 2 if someone has won

    function set_up()
        # initialize board of boards
        for i in 1:3
            for j in 1:3
                board[i,j] = TicTacToe
            end
        end
    end

    function take_turn(board_xidx, board_yidx, xloc, yloc) 
        # should make sure to update designated board idx
        # also accounting for if they've won the board (-1 then)
        board[board_xidx, board_yidx].take_turn(current_player, xloc, yloc)
        if has_won(board[xloc,yloc].board) == 0
            designated_board_xidx = xloc
            designated_board_yidx = yloc
        else
            designated_board_xidx = -1
            designated_board_yidx = -1
        end
    end 
    
    function has_won_global()
        # iterate through boards & check
        win_arr = zeros(Int8, 3, 3)
        for i in 1:3
            for j in 1:3
                win_arr[i,j] = has_won(board[i,j].board)
            end
        end
        return has_won(win_arr)
    end
    
    function whose_turn()
        return current_player
    end
    
    function valid_moves(player)
        # should account for -1 designated board idx

    end

    function display_board()
        
    end

end



