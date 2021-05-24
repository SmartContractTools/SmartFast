contract Uninitialized{

    struct St{
        uint a;
    }

    modifier ceshi_modi(uint ss) {
	St st_bug1;
	if(st_bug1.a == ss) {}
	   _;
    }

    function func() {
        St st; // non init, but never read so its fine
        St memory st2;
        St st_bug;
        st_bug.a += 1;
    }    

}
