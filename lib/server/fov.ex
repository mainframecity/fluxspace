defmodule Fluxspace.FOV do
  @moduledoc """
  Functions for dealing with FOV.
  """

  def is_blocking?(0), do: false
  def is_blocking?(_), do: true

  # Transformations for different FOV quadrants

  @directions [
    :e_ne,
    :ne_n,
    :n_nw,
    :nw_w,
    :w_sw,
    :sw_s,
    :s_se,
    :se_e
  ]

  @nw_n { 1, 0, 0, -1 }
  @w_nw { 0, 1, -1, 0 }

  @e_ne { 1,  0,  0,  1}
  @ne_n { 0,  1,  1,  0}
  @n_nw { 0, -1,  1,  0}
  @nw_w {-1,  0,  0,  1}
  @w_sw {-1,  0,  0, -1}
  @sw_s { 0, -1, -1,  0}
  @s_se { 0,  1, -1,  0}
  @se_e { 1,  0,  0, -1}

  def denormalize_coordinates(:e_ne, coords) do
    denormalize_coordinates(@e_ne, coords)
  end

  def denormalize_coordinates(:ne_n, coords) do
    denormalize_coordinates(@ne_n, coords)
  end

  def denormalize_coordinates(:n_nw, coords) do
    denormalize_coordinates(@n_nw, coords)
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

    @directions
    |> Enum.map(fn(direction) ->
      cast_light(map, entity_position, radius)
    end)
    |> overlay_light_maps()
  end

  def cast_light(map, entity_position, view_radius) do
  end

  def overlay_light_maps(light_maps) do
    light_maps
  end
end
