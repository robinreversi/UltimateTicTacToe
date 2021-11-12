using TicTacToe

Base.@kwdef mutable struct UTicTacToe
    u_board::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int8 = 1 # 1 or -1
    u_board_x::Int8 = -1 # designated x ultimate board idx
    u_board_y::Int8 = -1 # designated y board idx
    winner::Int8 = nothing # nothing if no one has won, becomes 1 or 2 if someone has won

    function set_up()
        # initialize board of boards
        for i = 1:3, j = 1:3
            u_board[i,j] = TicTacToe
        end
    end

    function take_turn(board_xidx, board_yidx, xloc, yloc) 
        # should make sure to update designated board idx
        # also accounting for if they've won the board (-1 then)
        u_board[board_xidx, board_yidx].take_turn(current_player, xloc, yloc)
        if has_won(u_board[xloc,yloc].board) == 0
            u_board_x = xloc
            u_board_y = yloc
        else
            u_board_x = -1
            u_board_y = -1
        end
        current_player = -current_player # switches current player
    end 
    
    function has_won_global()
        # iterate through boards & check
        win_arr = zeros(Int8, 3, 3)
        for i = 1:3, j = 1:3
            win_arr[i,j] = has_won(u_board[i,j].board)
        end
        return has_won(win_arr)
    end
    
    function whose_turn()
        return current_player
    end
    
    function valid_moves(player)
        # should account for -1 designated board idx
        valid_mvs = Matrix(undef, 0, 3)
        if u_board_x == -1
            for i = 1:3, j = 1:3
                board_valid_mvs = hcat(i, j, u_board[i,j].valid_moves()) # 9x3 Matrix{Any} with elements formated as [i,j,CartesianIndex]
                valid_mvs = vcat(valid_mvs, board_valid_mvs)
            end
        else 
            board_valid_mvs = hcat(u_board_x, u_board_y, board[u_board_x,u_board_y].valid_moves()) # 9x3 Matrix{Any} with elements formated as [i,j,CartesianIndex]
            valid_mvs = vcat(valid_mvs, board_valid_mvs)
        end
        return valid_mvs
    end

    function display_board()
        
    end
end



