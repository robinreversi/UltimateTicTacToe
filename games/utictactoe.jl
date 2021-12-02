
include("tictactoe.jl")
using Base.Iterators
mutable struct UTicTacToe
    ttt_boards::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int64 # 1 or -1
    ttt_boards_x::Int64 # designated x ultimate board idx
    ttt_boards_y::Int64 # designated y board idx
    previous_move::Tuple{Int64, Int64, Int64, Int64}
end

function randstep(uttt::UTicTacToe, a)
    uttt_copy = deepcopy(uttt)
    take_turn(uttt_copy, a)
    next_valid_mvs = u_valid_moves(uttt_copy)
    if (u_has_won(uttt) == 0 && !isempty(next_valid_mvs))
        rand_move = rand(next_valid_mvs)
        take_turn(uttt_copy, rand_move)
    end
    return uttt_copy
end

function get_s(uttt::UTicTacToe)
    uttt_board = zeros(Int8, (9, 9))
    for  j=1:9, i=1:9
        xloc = (i-1) ÷ 3 + 1
        yloc = (j-1) ÷ 3 + 1
        inner_xloc = (i-1) % 3 + 1
        inner_yloc = (j-1) % 3 + 1
        inner_board_val = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
        uttt_board[i, j] = inner_board_val
    end
    return (join(collect(Iterators.flatten(uttt_board))), uttt.current_player, uttt.ttt_boards_x, uttt.ttt_boards_y)
end

function take_turn(uttt::UTicTacToe, a::Tuple{Int64, Int64, Int64, Int64}) 
    uttt.previous_move = a
    board_xidx, board_yidx, xloc, yloc = a[1], a[2], a[3], a[4]

    take_turn(uttt.ttt_boards[board_xidx, board_yidx], uttt.current_player, xloc, yloc)
    if has_won(uttt.ttt_boards[xloc,yloc].board) == 0
        uttt.ttt_boards_x = xloc
        uttt.ttt_boards_y = yloc
        if isempty(u_valid_moves(uttt))
            uttt.ttt_boards_x = -1
            uttt.ttt_boards_y = -1
        end
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
            color = :light_magenta
            if uttt.previous_move == (xloc, yloc, inner_xloc, inner_yloc) # highlight previous move
                color = :light_red
            end
            printstyled(" O "; color = color)
        else
            print("   ")
        end
        if inner_xloc < 3
            color = :white
            if has_won(uttt.ttt_boards[xloc, yloc].board) == 1
                color = :light_blue
            elseif has_won(uttt.ttt_boards[xloc, yloc].board) == -1
                color = :light_magenta
            end
            printstyled("|"; color = color)
        elseif xloc < 3
            print("  ")
        else
            print("\n")
            if inner_yloc < 3
                color = :white
                if has_won(uttt.ttt_boards[xloc-2, yloc].board) == 1
                    color = :light_blue
                elseif has_won(uttt.ttt_boards[xloc-2, yloc].board) == -1
                    color = :light_magenta
                end
                printstyled("---|---|---  ", color = color)
                
                color = :white
                if has_won(uttt.ttt_boards[xloc-1, yloc].board) == 1
                    color = :light_blue
                elseif has_won(uttt.ttt_boards[xloc-1, yloc].board) == -1
                    color = :light_magenta
                end
                printstyled("---|---|---  ", color = color)

                color = :white
                if has_won(uttt.ttt_boards[xloc, yloc].board) == 1
                    color = :light_blue
                elseif has_won(uttt.ttt_boards[xloc, yloc].board) == -1
                    color = :light_magenta
                end
                printstyled("---|---|---\n", color = color)
                #print("---|---|---  ---|---|---  ---|---|---\n")
            else
                print("\n")
            end
        end
    end
end