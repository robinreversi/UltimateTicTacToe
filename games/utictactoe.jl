include("tictactoe.jl")

mutable struct UTicTacToe
    ttt_boards::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int64 # 1 or -1
    ttt_boards_x::Int64 # designated x ultimate board idx
    ttt_boards_y::Int64 # designated y board idx
    previous_move::Tuple{Int64, Int64, Int64, Int64}
end

function take_turn(uttt::UTicTacToe, a::Tuple{Int64, Int64, Int64, Int64}) 
    uttt.previous_move = a
    board_xidx, board_yidx, xloc, yloc = a[1], a[2], a[3], a[4]

    # should make sure to update designated board idx
    # also accounting for if they've won the board (-1 then)
    take_turn(uttt.ttt_boards[board_xidx, board_yidx], uttt.current_player, xloc, yloc)
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

function u_valid_moves(uttt::UTicTacToe)
    valid_mvs = [] #Array{Tuple{Int64, Int64, Int64, Int64}}[]
    # valid_mvs = Matrix(undef, 0, 3)
    if uttt.ttt_boards_x == -1
        for i = 1:3, j = 1:3
            board_valid_mvs = valid_moves(uttt.ttt_boards[i,j])
            for move in board_valid_mvs
                push!(valid_mvs, (i, j, move[1], move[2]))
            end
        end
    else 
        board_valid_mvs = valid_moves(uttt.ttt_boards[uttt.ttt_boards_x, uttt.ttt_boards_y])
        for move in board_valid_mvs
            push!(valid_mvs, (uttt.ttt_boards_x, uttt.ttt_boards_y, move[1], move[2]))
        end
    end
    return valid_mvs
end

function display_board(uttt::UTicTacToe)
    for j=1:9, i=1:9
        xloc = (i-1) ÷ 3 + 1
        yloc = (j-1) ÷ 3 + 1
        inner_xloc = (i-1) % 3 + 1
        inner_yloc = (j-1) % 3 + 1
        inner_board_val = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
        if (inner_board_val == 1)
            printstyled(" X "; color = :light_blue)
        elseif (inner_board_val == -1)
            if uttt.previous_move == (xloc, yloc, inner_xloc, inner_yloc)
                printstyled(" O "; color = :light_red)
            else
                printstyled(" O "; color = :light_magenta)
            end
        else
            print("   ")
        end
        if inner_xloc < 3
            print("|")
        elseif xloc < 3
            print("  ")
        else
            print("\n")
            if inner_yloc < 3
                print("---|---|---  ---|---|---  ---|---|---\n")
            else
                print("\n")
            end
        end
    end
end



# # Initialize 9 individual TicTacToe boards
# ttt_boards = [TicTacToe(zeros(Int64, 3, 3)) for i = 1:3, j = 1:3]

# # Initialize Ultimate TicTacToe game
# uttt_game = UTicTacToe(ttt_boards, 1, -1, -1)

# while(u_has_won(uttt_game) == 0)
#     run(`clear`)

#     println("Current board:")
#     println()

#     display_board(uttt_game)

#     println()
#     println("Player $(Int8(-(uttt_game.current_player)/2 + 1.5))'s turn...")
#     println()

#     if uttt_game.ttt_boards_x != -1
#         println("You must play in TicTacToe board $(uttt_game.ttt_boards_x), $(uttt_game.ttt_boards_y)")
#     end

#     println()

#     print("Player $(Int8(-(uttt_game.current_player)/2 + 1.5))'s move is: ")
#     move = (-1,-1,-1,-1)
#     while true 
#         board_xidx, board_yidx, xloc, yloc = -1, -1, -1, -1
#         while true
#             move_str = readline()
            
#             move_str_vec = split(move_str, ",")
#             board_xidx, board_yidx, xloc, yloc = tryparse(Int64, move_str_vec[1]), tryparse(Int64, move_str_vec[2]), tryparse(Int64, move_str_vec[3]), tryparse(Int64, move_str_vec[4])
#             if board_xidx !== nothing  && board_yidx !== nothing && xloc !== nothing && yloc !== nothing
#                 break
#             end
#             println()
#             print("Please enter your move in the form of \"int,int,int,int\" \"1,1,1,1\": ")
#         end

#         move = (board_xidx, board_yidx, xloc, yloc)
#         is_valid = false
#         valid_mvs = u_valid_moves(uttt_game)
#         for a in valid_mvs
#             if move == a
#                 is_valid = true
#             end
#         end
        
#         if is_valid
#             break
#         end
#         println()
#         print("Please enter a valid move: ")
#     end
#     take_turn(uttt_game, move)
# end

# println("Current board:")
# println()

# display_board(uttt_game)

# println("Player $(u_has_won(uttt_game)) has won the game.") 

