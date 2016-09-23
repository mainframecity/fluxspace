defmodule Fluxspace.FOV do
  @moduledoc """
  Functions for dealing with FOV.
  """

  def is_blocking?(0), do: false
  def is_blocking?(_), do: true

  # Transformations for different FOV quadrants

  @directions [
    :n_nw,
    :nw_w,
    :w_sw,
    :sw_s,
    :s_se,
    :se_e,
    :e_ne,
    :ne_n
  ]

  @n_nw {1, 0, 0, -1}
  @nw_w {0, -1, 1, 0}
  @w_sw {0, -1, -1, 0}
  @sw_s {1, 0, 0, 1}
  @s_se {-1, 0, 0, 1}
  @se_e {0, 1, -1, 0}
  @e_ne {0, 1, 1, 0}
  @ne_n {-1, 0, 0, -1}

  def denormalize_coordinates(:n_nw, coords) do
    denormalize_coordinates(@n_nw, coords)
  end

  def denormalize_coordinates(:nw_w, coords) do
    denormalize_coordinates(@nw_w, coords)
  end

  def denormalize_coordinates(:w_sw, coords) do
    denormalize_coordinates(@w_sw, coords)
  end

  def denormalize_coordinates(:sw_s, coords) do
    denormalize_coordinates(@sw_s, coords)
  end

  def denormalize_coordinates(:s_se, coords) do
    denormalize_coordinates(@s_se, coords)
  end

  def denormalize_coordinates(:se_e, coords) do
    denormalize_coordinates(@se_e, coords)
  end

  def denormalize_coordinates(:e_ne, coords) do
    denormalize_coordinates(@e_ne, coords)
  end

  def denormalize_coordinates(:ne_n, coords) do
    denormalize_coordinates(@ne_n, coords)
  end

  @doc """
  Translates local coordinates to grid coordinates.
  """
  def denormalize_coordinates({xx, xy, yx, yy}, {local_x, local_y, grid_position_x, grid_position_y}) do
    grid_x = grid_position_x + (local_x * xx) + (local_y * xy)
    grid_y = grid_position_y + (local_x * yx) + (local_y * yy)
    {grid_x, grid_y}
  end

  @doc """
  Gets the height of a map.
  """
  def get_height(map), do: Enum.count(map)

  @doc """
  Gets the width of a map.
  """
  def get_width(map) do
    map
    |> Enum.at(0)
    |> Enum.count()
  end

  @doc """
  Calculates the FOV of a map.
  """
  def calculate_fov(map, {_start_x, _start_y} = entity_position, radius) do
    height = get_height(map)
    width = get_width(map)

    light_map =
      Range.new(0, height)
      |> Enum.reduce([], fn(_, acc) ->
        [Range.new(0, width)
        |> Enum.reduce([], fn(_, acc) ->
          [0 | acc]
        end) | acc]
      end)

    @directions
    |> Enum.reduce(light_map, fn(direction, acc) ->
      merge_matrice(
        acc,
        scan(direction, 1, map, light_map, -1, 1, entity_position, {height, width}, radius)
      )
    end)
  end

  def merge_matrice(a1, a2) do
    a1
    |> Enum.with_index
    |> Enum.reduce([], fn({a1_row, a1_row_idx}, acc) ->
      a2_row = Enum.at(a2, a1_row_idx)

      new_row =
        a1_row
        |> Enum.with_index
        |> Enum.map(fn({a1_cell, col_idx}) ->
          case a1_cell do
            0 -> Enum.at(a2_row, col_idx)
            1 -> 1
          end
        end)

      acc ++ [new_row]
    end)
  end

  def scan(direction, current_row, map, light_map, start_slope, end_slope, {origin_x, origin_y}, {map_height, map_width}, radius) do
    new_light_map =
      Range.new(0, -current_row)
      |> Enum.reduce(light_map, fn(current_column, acc) ->
        {grid_x, grid_y} = denormalize_coordinates(direction, {current_column, current_row, origin_x, origin_y})

        if (grid_x < 0) or (grid_y < 0) or (grid_x > map_width - 1) or (grid_y > map_height - 1) do
          acc
        else
          tile_id =
            map
            |> Enum.at(grid_y)
            |> Enum.at(grid_x)

          List.update_at(acc, grid_y, &(List.update_at(&1, grid_x, fn(_) -> 1 end)))
        end
      end)

    if current_row < radius do
      scan(direction, current_row + 1, map, new_light_map, start_slope, end_slope, {origin_x, origin_y}, {map_height, map_width}, radius)
    else
      new_light_map
    end
  end
end
