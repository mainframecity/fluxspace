defmodule Transform do
  def calculate do
    origin = {3, 3}

    [
      {:n_nw, {-1,  2}, {2, 1}},
      {:nw_w, {-2,  1}, {1, 2}},
      {:w_sw, {-2, -1}, {1, 4}},
      {:sw_s, {-1, -2}, {2, 5}},
      {:s_se, { 1, -2}, {4, 5}},
      {:se_e, { 2, -1}, {5, 4}},
      {:e_ne, { 2,  1}, {5, 2}},
      {:ne_n, { 1,  2}, {4, 1}}
    ]
    |> Enum.map(fn({direction, {local_x, local_y}, {global_x, global_y}}) ->
      {origin_x, origin_y} = origin

      [
        { 1,  0,  0,  1},
        { 0,  1,  1,  0},
        { 0, -1,  1,  0},
        {-1,  0,  0,  1},
        {-1,  0,  0, -1},
        { 0, -1, -1,  0},
        { 0,  1, -1,  0},
        { 1,  0,  0, -1}
      ]
      |> Enum.find(fn({xx, xy, yx, yy} = transformation) ->
         {test_x, test_y} = {
           (origin_x + (local_x * xx) + (local_y * xy)),
           (origin_y + (local_x * yx) + (local_y * yy)),
         }

         if (test_x == global_x and test_y == global_y) do
           IO.inspect({direction, transformation})
         end
      end)
    end)
  end
end

Transform.calculate
