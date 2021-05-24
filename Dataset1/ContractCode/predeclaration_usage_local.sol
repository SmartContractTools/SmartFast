contract C {
    function f(uint z) public {
        uint y;
        y = x + 9 + z; // x is being used before declaration
        uint x = 7;

        for (uint j = 0; j < z; j++) {
            for (uint i = 10; i > 0; i--) {
                x += i;
            }
        }

        // On lines below, 'i' could be used pre-declaration if the outer loop above did not enter to declare it.
        for (i = 10; i > 0; i--) {
            x += i;
        }
    }
}

contract D {
    function f(uint z) public returns (uint) {
        uint y = x + 9 + z; // 'z' is used pre-declaration
        uint x = 7;

        if (z % 2 == 0) {
            uint max = 5;
            // ...
        }

        // 'max' was intended to be 5, but it was mistakenly declared in a scope and not assigned (so it is zero).
        for (uint i = 0; i < max; i++) {
            x += 1;
        }

        return x;
    }
}

