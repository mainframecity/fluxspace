### Chat Packets

`chat_list (Server-bound)`

```elixir
%{
  "type" => "chat_list"
}
```

---

`chat_list (Client-bound)`

```elixir
%{
  "type" => "chat_list",
  "data" => %{
    "channel_count" => 2,
    "channels" => [
      %{
        "name" => "general",
        "user_count" => 50
      },
      %{
        "name" => "offtopic",
        "user_count" => 25
      }
    ]
  }
}
```

---

`chat_history (Server-bound)`

```elixir
%{
  "type" => "chat_history"
}
```

---

`chat_history (Server-bound)`

```elixir
%{
  "type" => "chat_history"
}
```

---

`chat_message (Server-bound)`

```elixir
```
