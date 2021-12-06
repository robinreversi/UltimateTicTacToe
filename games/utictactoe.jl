
include("tictactoe.jl")
using Base.Iterators
mutable struct UTicTacToe
    ttt_boards::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int64 # 1 or -1
    ttt_boards_x::Int64 # designated x ultimate board idx
    ttt_boards_y::Int64 # designated y board idx
    previous_move::Tuple{Int64, Int64, Int64, Int64}
end

const ORIENTATION_MATRIX = transpose(reshape(collect(1:81), 9,9))

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

function create_9x9_board(uttt::UTicTacToe)
    uttt_board = zeros(Int8, (9, 9))
    for  j=1:9, i=1:9
        xloc = (i-1) ÷ 3 + 1
        yloc = (j-1) ÷ 3 + 1
        inner_xloc = (i-1) % 3 + 1
        inner_yloc = (j-1) % 3 + 1
        inner_board_val = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
        uttt_board[i, j] = inner_board_val 
    end
    return uttt_board
end

function get_s(uttt::UTicTacToe)
    uttt_board = create_9x9_board(uttt)
    uttt_board *= uttt.current_player
    # return gen_symmetric_states(uttt_board, uttt.ttt_boards_x, uttt.ttt_boards_y)
    str_board = join(collect(Iterators.flatten(uttt_board)))
    return str_board * string(uttt.ttt_boards_x) * string(uttt.ttt_boards_y)
end

function fix_orientation(board::Matrix{Int64})
    best_score = sum(board .* ORIENTATION_MATRIX)
    best_board = board
    for i in 1:4
        rotated_board = board
        for j in 1:i
            rotated_board = rotr90(rotated_board)
        end
        rotate_score = sum(rotated_board .* ORIENTATION_MATRIX)
        if (rotate_score < best_score)
            best_score = rotate_score
            best_board = rotated_board
        end

        flipped_board = reverse(rotated_board, dims=1)
        flipped_score = sum(flipped_board .* ORIENTATION_MATRIX)
        if (flipped_score < best_score)
            best_score = flipped_score
            best_board = flipped_board
        end
    end
    return best_board
end

function gen_symmetric_states(board::Matrix{Int64}, x::Int64, y::Int64) 
    symmetric_states = Set{String}()
    pos = zeros(Int64, 3, 3)
    if (x != -1)
        pos[x, y] = 1
    end

    for i in 1:4
        rotated_board = board
        rotated_pos = pos
        for j in 1:i
            rotated_board = rotr90(rotated_board)
            rotated_pos = rotr90(rotated_pos)
        end
        new_pos = (-1, -1)
        if (x != -1)
            new_pos = findall(val->val==1, rotated_pos)[1]
        end
        rotated_state = join(collect(Iterators.flatten(rotated_board))) * string(new_pos[1]) * string(new_pos[2])
        
        flipped_board = reverse(rotated_board, dims=1)
        flipped_pos = reverse(rotated_pos, dims=1)
        if (x != -1)
            new_pos = findall(val->val==1, flipped_pos)[1]
        end
        flipped_state = join(collect(Iterators.flatten(flipped_board))) * string(new_pos[1]) * string(new_pos[2])
        push!(symmetric_states, rotated_state)
        push!(symmetric_states, flipped_state)
    end
    return symmetric_states
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

function add_moves_from_board(i::Int64, j::Int64, uttt::UTicTacToe, filtered_mvs::Dict{String, Tuple{Int64, Int64, Int64, Int64}})
    board_valid_mvs = valid_moves(uttt.ttt_boards[i,j])
    board = create_9x9_board(uttt)
    board *= uttt.current_player
    for move in board_valid_mvs
        board_xidx, board_yidx, xloc, yloc = i, j, move[1], move[2]
        a = (board_xidx, board_yidx, xloc, yloc)
        board[xloc + 3 * (board_xidx - 1), yloc + 3 * (board_yidx - 1)] = 1
        symmetric_states = gen_symmetric_states(board::Matrix{Int64}, xloc, yloc) 
        match_found = false
        for s in symmetric_states
            if (haskey(filtered_mvs, s))
                match_found = true
                break
            end
        end
        if (!match_found)
            filtered_mvs[first(symmetric_states)] = a
        end
        board[xloc + 3 * (board_xidx - 1), yloc + 3 * (board_yidx - 1)] = 0
    end
end

function u_valid_moves(uttt::UTicTacToe)
    """
    We filter the non-unique moves out to reduce the search space
    + save memory. We do so by assuming each move is taken in valid moves
    and check whether the resulting state (or any symmetric derivative) is
    contained in the filtered move set. If none are, then we add one of the states 
    to the filtered_mvs. Everything is done from the perspective of player 1
    """
    filtered_mvs = Dict{String, Tuple{Int64, Int64, Int64, Int64}}()
    if uttt.ttt_boards_x == -1
        for i = 1:3, j = 1:3
            add_moves_from_board(i, j, uttt, filtered_mvs)
        end
    else 
        add_moves_from_board(uttt.ttt_boards_x, uttt.ttt_boards_y, uttt, filtered_mvs)
    end
    return vec(collect(values(filtered_mvs)))
end

function display_board(uttt::UTicTacToe)
    for j=1:9, i=1:9
        xloc = (i-1) ÷ 3 + 1
        yloc = (j-1) ÷ 3 + 1
        inner_xloc = (i-1) % 3 + 1
        inner_yloc = (j-1) % 3 + 1
        inner_board_val = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
        if (inner_board_val == 1)
            reverse = (uttt.previous_move == (xloc, yloc, inner_xloc, inner_yloc)) # highlight previous move
            printstyled(" X "; color = :blue, reverse=reverse)
        elseif (inner_board_val == -1)
            reverse = (uttt.previous_move == (xloc, yloc, inner_xloc, inner_yloc)) # highlight previous move
            printstyled(" O "; color = :red, reverse=reverse)
        else
            print("   ")
        end
        if inner_xloc < 3
            color = :white
            if has_won(uttt.ttt_boards[xloc, yloc].board) == 1
                color = :blue
            elseif has_won(uttt.ttt_boards[xloc, yloc].board) == -1
                color = :red
            end
            printstyled("|"; color = color)
        elseif xloc < 3
            print("  ")
        else
            print("\n")
            if inner_yloc < 3
                color = :white
                if has_won(uttt.ttt_boards[xloc-2, yloc].board) == 1
                    color = :blue
                elseif has_won(uttt.ttt_boards[xloc-2, yloc].board) == -1
                    color = :red
                end
                printstyled("---|---|---  ", color = color)
                
                color = :white
                if has_won(uttt.ttt_boards[xloc-1, yloc].board) == 1
                    color = :blue
                elseif has_won(uttt.ttt_boards[xloc-1, yloc].board) == -1
                    color = :red
                end
                printstyled("---|---|---  ", color = color)

                color = :white
                if has_won(uttt.ttt_boards[xloc, yloc].board) == 1
                    color = :blue
                elseif has_won(uttt.ttt_boards[xloc, yloc].board) == -1
                    color = :red
                end
                printstyled("---|---|---\n", color = color)
            else
                print("\n")
            end
        end
    end
end