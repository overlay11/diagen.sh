BEHAVIOR DIAGRAM
    INITIAL_NODE(in)
    FINAL_NODE(fn)
    DECISION(foo)
    MERGE(m)

    in -> foo
    TRANSITION(foo -> bar, true)
    TRANSITION(foo -> baz, false)
    {bar baz} -> m -> fn
END
