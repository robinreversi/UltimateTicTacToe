using LinearAlgebra

include("tictactoe.jl")
using Base.Iterators
mutable struct UTicTacToe
    ttt_boards::Matrix{TicTacToe}  # 3x3 array of tic tac toe boards
    current_player::Int8 # 1 or -1
    ttt_boards_x::Int8 # designated x ultimate board idx
    ttt_boards_y::Int8 # designated y board idx
    previous_move::Tuple{Int8, Int8, Int8, Int8}
end

const ORIENTATION_MATRIX = transpose(reshape(collect(1:81), 9,9))

function randstep(uttt::UTicTacToe, a)
    uttt_copy = deepcopy(uttt)
    take_turn(uttt_copy, a)
    next_valid_mvs = u_valid_moves(uttt_copy)
    if (u_has_won(uttt_copy) == 0 && !isempty(next_valid_mvs))
        rand_move = rand(next_valid_mvs)
        take_turn(uttt_copy, rand_move)
    end
    return uttt_copy
end

function randomized_rollout(uttt::UTicTacToe, player)
    uttt_copy = deepcopy(uttt)
    valid_moves = u_valid_moves(uttt_copy)
    while (u_has_won(uttt_copy) == 0 && !isempty(valid_moves))
        valid_moves = u_valid_moves(uttt_copy)
        if (!isempty(valid_moves))
            rand_move = rand(valid_moves)
            take_turn(uttt_copy, rand_move)
        end
    end
    if (u_has_won(uttt_copy) == 0) 
        return 0
    elseif (u_has_won(uttt_copy) == player)
        return 1
    else
        return -1
    end
end

function nine_by_nine_to_4_tuple(x::Int8, y::Int8)
    xloc = (x-1) ÷ 3 + 1
    yloc = (y-1) ÷ 3 + 1
    inner_xloc = (x-1) % 3 + 1
    inner_yloc = (y-1) % 3 + 1
    return Int8(xloc), Int8(yloc), Int8(inner_xloc), Int8(inner_yloc)
end

function create_9x9_board(uttt::UTicTacToe)
    uttt_board = zeros(Int8, (9, 9))
    for  x=1:9, y=1:9
        yloc, xloc, inner_yloc, inner_xloc = nine_by_nine_to_4_tuple(Int8(x),Int8(y))
        uttt_board[x, y] = uttt.ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc]
    end
    return uttt_board
end

function create_ttt_boards(uttt_board::Matrix{Int8})
    ttt_boards = [TicTacToe(zeros(Int8, 3, 3)) for i = 1:3, j = 1:3]
    for  x=1:9, y=1:9
        yloc, xloc, inner_yloc, inner_xloc = nine_by_nine_to_4_tuple(Int8(x),Int8(y))
        ttt_boards[xloc, yloc].board[inner_xloc, inner_yloc] = uttt_board[x, y]
    end
    return ttt_boards
end



function to_bot_orientation(board::Matrix{Int8})
    # I: 1
    # R: 2
    # RR: 3
    # RRR: 4
    # H: 5
    # RH: 6
    # RRH: 7
    # RRRH: 8

    # I
    best_score = sum(abs.(board) .* ORIENTATION_MATRIX)
    best_board = board
    transform_idx = Int8(1) 

    # R, RR, RRR
    rotated_board = board
    for i in 2:4 
        rotated_board = rotr90(rotated_board)
        score = sum(rotated_board .* ORIENTATION_MATRIX)
        if (score < best_score) 
            best_score = score 
            best_board = rotated_board 
            transform_idx = Int8(i) 
        end
    end

    # H
    rotated_board = reverse(board, dims=2)
    score = sum(rotated_board .* ORIENTATION_MATRIX)
    if (score < best_score)
        best_score = score 
        best_board = rotated_board
        transform_idx = Int8(5) 
    end

    # RH = HL, RRH = HLL, RRRH (LH) = HLLL (HR) (a = rand(9,9); b = reverse(rotr90(rotr90(rotr90(a))),dims=1); c = rotl90(rotl90(rotl90(reverse(a, dims=1)))) )
    for i in 6:8 
        rotated_board = rotl90(rotated_board) 
        score = sum(rotated_board .* ORIENTATION_MATRIX)
        if (score < best_score) 
            best_score = score; 
            best_board = rotated_board; 
            transform_idx = Int8(i) 
        end
    end

    return best_board, transform_idx
end

function to_player_orientation(board::Matrix{Int8}, transform_idx::Int8)
    if transform_idx == 1 # I
        return board
    elseif transform_idx == 2 # R
        return rotl90(board)
    elseif transform_idx == 3 # RR
        return rot180(board)
    elseif transform_idx == 4 # RRR
        return rotr90(board)
    elseif transform_idx == 5 # H
        return reverse(board, dims=2)
    elseif transform_idx == 6 # RH
        return rotl90(reverse(board, dims=2))
    elseif transform_idx == 7 # RRH
        return rot180(reverse(board, dims=2))
    else # RRRH
        return rotr90(reverse(board, dims=2))
    end
end

function to_bot_move(a::Tuple{Int8, Int8, Int8, Int8}, transform_idx::Int8)
    if transform_idx == 1 # I
        return a
    end
    
    # Get equivalent 9x9 placement of a (the move)
    i = (a[1]-1) * 3 + a[3]
    j = (a[2]-1) * 3 + a[4]

    transform_mat = [0 1; -1 0] # R
    if transform_idx == 3 # RR
        transform_mat = [-1 0; 0 -1]
    elseif transform_idx == 4 # RRR
        transform_mat = [0 -1; 1 0]
    elseif transform_idx == 5 # H
        transform_mat = [-1 0; 0 1]
    elseif transform_idx == 6 # RH
        transform_mat = [0 1; 1 0]
    elseif transform_idx == 7 # RRH
        transform_mat = [1 0; 0 -1]
    elseif transform_idx == 8 # RRRH
        transform_mat = [0 -1; -1 0]
    end

    # Convert coordinates to distance vector from center (5,5)
    vec = [i - 5 j - 5]

    transformed_vec = vec * transform_mat

    # Convert from distance vector to coordinates
    transformed_i = transformed_vec[1] + 5
    transformed_j = transformed_vec[2] + 5
    return nine_by_nine_to_4_tuple(Int8(transformed_i), Int8(transformed_j))
end

function to_player_move(a::Tuple{Int8, Int8, Int8, Int8}, transform_idx::Int8) # undoing the transform performed by transform_idx
    if transform_idx == 1 # I needs I    
        return a
    elseif transform_idx == 2 # R needs L (RRR)
        return(to_bot_move(a, Int8(4)))
    elseif transform_idx == 3 # RR needs LL (or RR)
        return(to_bot_move(a, Int8(3)))
    elseif transform_idx == 4 # RRR needs R
        return(to_bot_move(a, Int8(2)))
    elseif transform_idx == 5 # H needs H
        return(to_bot_move(a, Int8(5)))
    elseif transform_idx == 6 # RH needs HL = RH
        return(to_bot_move(a, Int8(6)))
    elseif transform_idx == 7 # RRH needs HLL = RRH
        return(to_bot_move(a, Int8(7)))
    else # RRRH needs HLLL = RRRH
        return(to_bot_move(a, Int8(8)))
    end
end

function gen_symmetric_states(board::Matrix{Int8}, x::Int8, y::Int8) 
    symmetric_states = Set{String}()
    pos = zeros(Int8, 3, 3)
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
        
        flipped_board = reverse(rotated_board, dims=2)
        flipped_pos = reverse(rotated_pos, dims=2)
        if (x != -1)
            new_pos = findall(val->val==1, flipped_pos)[1]
        end
        flipped_state = join(collect(Iterators.flatten(flipped_board))) * string(new_pos[1]) * string(new_pos[2])
        push!(symmetric_states, rotated_state)
        push!(symmetric_states, flipped_state)
    end
    return symmetric_states
end

function take_turn(uttt::UTicTacToe, a::Tuple{Int8, Int8, Int8, Int8}) 
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
    win_arr = zeros(Int8, 3, 3)
    for i = 1:3, j = 1:3
        win_arr[i,j] = has_won(uttt.ttt_boards[i,j].board)
    end
    return has_won(win_arr)
end

function whose_turn(uttt::UTicTacToe)
    return uttt.current_player
end

function add_moves_from_board(i::Int8, j::Int8, uttt::UTicTacToe, filtered_mvs::Dict{String, Tuple{Int8, Int8, Int8, Int8}})
    board_valid_mvs = valid_moves(uttt.ttt_boards[i,j])
    board = create_9x9_board(uttt)
    board *= uttt.current_player
    for move in board_valid_mvs
        board_xidx, board_yidx, xloc, yloc = i, j, move[1], move[2]
        a = (board_xidx, board_yidx, xloc, yloc)
        board[xloc + 3 * (board_xidx - 1), yloc + 3 * (board_yidx - 1)] = 1
        symmetric_states = gen_symmetric_states(board::Matrix{Int8}, convert(Int8, xloc), convert(Int8, yloc))
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
    filtered_mvs = Dict{String, Tuple{Int8, Int8, Int8, Int8}}()
    
    if uttt.ttt_boards_x == -1
        for i::Int8 = 1:3, j::Int8 = 1:3
            add_moves_from_board(i, j, uttt, filtered_mvs)
        end
    else 
        add_moves_from_board(uttt.ttt_boards_x, uttt.ttt_boards_y, uttt, filtered_mvs)
    end
    return vec(collect(values(filtered_mvs)))
end

function display_board(uttt::UTicTacToe)
    for j=1:9, i=1:9
        xloc, yloc, inner_xloc, inner_yloc = nine_by_nine_to_4_tuple(Int8(i),Int8(j))
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