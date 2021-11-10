Base.@kwdef mutable struct TicTacToe
    board::Matrix{Int8} = zeros(Int8, 3, 3) # 3x3 array
    winner::Int32 = nothing # nothing if no one has won, becomes 1 or 2 if someone has won

    function take_turn(xloc, yloc) 
        
    end 
    
    function has_won()
    end
    
    function valid_moves(player)
    end

    function display_board()
    end

end



