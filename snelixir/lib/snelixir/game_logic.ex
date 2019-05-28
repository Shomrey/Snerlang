defmodule Snelixir.GameLogic do
  @length 23
  @max_snake_count 2

  def length, do: @length
  def max_snake_count, do: @max_snake_count

  def init_board(snakes) do
    # snakes - list of pids
    apples = [{5,5}, {7,8}]

    starting_positions = [
      [{3, 3}, {3, 2}, {3, 1}],
      [{3, 20}, {4, 20}, {5, 20}]
    ]

    # ,[{20,20},{20,19}],[{20,3},{21,3}]]  #[head body body tail]
    newSnakes = Enum.zip(snakes, starting_positions)

    snakes_positions =
      for {snakeId, position} <- newSnakes, into: %{} do
        {snakeId, position}
      end

    snakes_directions =
      for snake <- snakes, into: %{} do
        {snake, :front}
      end

    {snakes_positions, snakes_directions, apples}
  end

  def move_snakes(board) do
    length = length()
    {snakes_positions, snakes_directions, apples} = board
    # move snakes
    updated_snakes_positions =
      for snek <- snakes_positions, into: %{} do
        {id, body} = snek
        [head, neck | tail] = body
        direction = Map.get(snakes_directions, id)

        id
        #|> IO.inspect(label: "id")

        head
        #|> IO.inspect(label: "head")

        neck
        #|> IO.inspect(label: "neck")

        {x1, y1} = head
        {x2, y2} = neck
        dx = delta(x1, x2, length)
        dy = delta(y1, y2, length)

        dx
        #|> IO.inspect(label: "dx")

        dy
        #|> IO.inspect(label: "dy")

        body
        #|> IO.inspect(label: "body before direction")

        newHead =
          case direction do
            :front ->
              case {dx, dy} do
                {-1, 0} -> {x1 - 1, y1}
                {1, 0} -> {x1 + 1, y1}
                {0, -1} -> {x1, y1 - 1}
                {0, 1} -> {x1, y1 + 1}
              end

            :right ->
              case {dx, dy} do
                {-1, 0} -> {x1, y1 - 1}
                {1, 0} -> {x1, y1 + 1}
                {0, -1} -> {x1 + 1, y1}
                {0, 1} -> {x1 - 1, y1}
              end

            :left ->
              case {dx, dy} do
                {-1, 0} -> {x1, y1 + 1}
                {1, 0} -> {x1, y1 - 1}
                {0, -1} -> {x1 - 1, y1}
                {0, 1} -> {x1 + 1, y1}
              end
          end

        #newHead
        #|> IO.inspect(label: "body after direction")

        {newx, newy} = newHead
        newHead = {rem(newx + length, length), rem(newy + length, length)}

        result =
          if Enum.member?(apples, newHead) do
            {id, [newHead | body]}
          else
            {id, [newHead | List.delete(body, List.last(body))]}
          end

        result
      end

    updated_snakes_directions =
      for snek <- snakes_directions, into: %{} do
        {id, direction} = snek
        direction = :front
        {id, direction}
      end

    headList =
      for {id, body} <- updated_snakes_positions, into: [] do
        List.first(body) #id,
      end

    updated_snakes_positions |> IO.inspect(label: "sneks")
    deadSnakes = Enum.filter(headList, fn el -> amount(el, updated_snakes_positions) end)
    apples |> IO.inspect(label: "apples")
    headList |> IO.inspect(label: "head list")
    updated_apples = Enum.filter(apples, fn apple -> not(apple in headList)  end) #!Enum.member?(headList, apple)
    apples_to_add = apples -- updated_apples
    new_apples = for apple <- apples_to_add, into: [] do
      {Enum.random(1..23), Enum.random(1..23)}
    end
    updated_apples = updated_apples ++ new_apples
    #deadSnakes
    #|> IO.inspect(label: "dead Snakes")
    #updated_apples
    #|> IO.inspect(label: "updated apples")
    # return -> {new state, list of pids of dead snakes}
    # {board, []}
    {{updated_snakes_positions, updated_snakes_directions, updated_apples}, deadSnakes}
  end

  defp amount(value, updated_snakes_positions) do
    acc = 0
    #updated_snakes_positions |> IO.inspect(label: "snakes")
    for {snakeId, segment} <- updated_snakes_positions do
      for cube <- segment do
        #IO.write("-------------")
        #cube |> IO.inspect(label: "one cube")
        #value |> IO.inspect(label: "value")
        #IO.write("------------")
        if cube == value do
          acc = acc + 1
          #acc |> IO.inspect(label: "appearance")
        end
      end
    end

    acc > 1
  end

  defp delta(x1, x2, length) do
    d =
      case x1 - x2 do
        d when d > 1 -> d - length
        d when d < -1 -> d + length
        d -> d
      end

    d
  end

  def remove_snake({segments, directions, apples}, snake) do
    {
      Map.delete(segments, snake),
      Map.delete(directions, snake),
      apples
    }
  end

  def set_direction({segments, directions, apples}, snake, direction) do
    {
      segments,
      Map.put(directions, snake, direction),
      apples
    }
  end
end
