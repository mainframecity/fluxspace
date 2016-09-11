---

The world of Fluxspace is split into different regions of the map, with each region containing rooms.

```
- Fluxspace.RegionSupervisor
  - RegionManager
    - Room(1)
    - Room(2)
  - RegionManager(2)
    - Room(3)
  - RegionManager(3)
    - Room(4)
    - Room(5)
```

`RegionManager` will manage inter-room communication within its Region, while `Room` holds the state for the current room.

---

A `PlayerRegistry` contains the location / PID of a Player entity (location of region, location of room).

This allows us to completely destroy the current room process while preserving the player process.

```
- PlayerRegistry
```

---

An `InventoryRegistry` will contain the inventory process for a given player.

```
InventoryRegistry
```

---
