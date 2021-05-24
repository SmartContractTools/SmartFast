contract Hardaddress {
    uint[] aa;
    function ss() {
	aa.length = 5;
	aa.length++;
	aa.length--;
	aa.length += 5;
	aa.length -= 5;
	aa.length *= 5;
	aa.length /= 5;
    }
}
