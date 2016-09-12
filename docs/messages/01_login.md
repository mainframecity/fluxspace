### Login Packets

`server_status (Server-bound)`

```elixir
%{
  "type" => "server_status"
}
```

---

`server_status (Client-bound)`

```elixir
%{
  "type" => "server_status",
  "data" => %{
    "player_count" => integer
  }
}
```

---

`login_request (Server-bound)`

```elixir
%{
  "type" => "login_request",
  "data" => %{
    "username" => String.t,
    "password" => String.t
  }
}
```

---

`login_request (Client-bound)`

```elixir
%{
  "type" => "login_request",
  "data" => %{
    "status" => 401 | 200,
    "access_token" => String.t,
    "message" => "Could not find player with that username/password"
  }
}
```
