# Debug utilities
# Fast debug system with minimal overhead when disabled

"""
    DEBUG_LEVEL

Global debug level reference. Set to 0 to disable all debug output.
Levels:
- 0: No debug output
- 1: Basic parsing progress
- 2: Detailed field parsing
- 3: Verbose byte-level operations
"""
const DEBUG_LEVEL = Ref(0)

"""
    @pdebug level msg

Print debug message if DEBUG_LEVEL[] >= level.

Named `@pdebug` to avoid conflicts with Julia's built-in `@debug` macro.

# Examples
```julia
PowerDynData.DEBUG_LEVEL[] = 1
@pdebug 1 "Parsing model: GENROU"  # Prints
@pdebug 2 "Field value: \$(val)"    # Does not print
```
"""
macro pdebug(level, msg)
    esc(quote
        if DEBUG_LEVEL[] >= $level
            println(string("DEBUG: ", $(QuoteNode(__source__.file)), ":",
                          $(QuoteNode(__source__.line)), " ", $msg))
        end
    end)
end
