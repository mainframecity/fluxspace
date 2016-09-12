The Entity System reflects a similar approach by [Entice](https://github.com/entice).

Entities are spawned processes that can have:

- additional behaviour callbacks/implementations (via messages)
- attributes

---

Entities can be "started", which creates a unique process and a unique id for the instance.

Attributes are held separately outside of the entity process.

Behaviours are added modules of code that implement a GenServer-type model, except they are synchronized on the same entity instance's state.
