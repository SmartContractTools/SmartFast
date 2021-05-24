pragma solidity ^0.5.2;
contract RLPEncode {
    uint8 constant STRING_SHORT_PREFIX = 0x80;
    uint8 constant STRING_LONG_PREFIX = 0xb7;
    uint8 constant LIST_SHORT_PREFIX = 0xc0;
    uint8 constant LIST_LONG_PREFIX = 0xf7;


    function encodeBytes(bytes memory self) internal  returns (bytes memory) {
        bytes memory encoded;
        if(self.length == 1 && uint8(self[0]) < 0x80) {
            encoded = new bytes(1);
            encoded = self;
        } else {
            encoded = encode(self, STRING_SHORT_PREFIX, STRING_LONG_PREFIX);
        }
        return encoded;
    }

    /// @dev Rlp encodes a bytes[]. Note that the items in the bytes[] will not automatically be rlp encoded.
    /// @param self The bytes[] to be encoded
    /// @return The rlp encoded bytes[]
    function encodeList(bytes[] memory self) internal  returns (bytes memory) {
        bytes memory list = flatten(self);
        bytes memory encoded = encode(list, LIST_SHORT_PREFIX, LIST_LONG_PREFIX);
        return encoded;
    }

    function encode(bytes memory self, uint8 prefix1, uint8 prefix2) private  returns (bytes memory) {
        uint selfPtr;
        assembly { selfPtr := add(self, 0x20) }

        bytes memory encoded;
        uint encodedPtr;

        uint len = self.length;
        uint lenLen;
        uint i = 0x1;
        while(len/i != 0) {
            lenLen++;
            i *= 0x100;
        }

        if(len <= 55) {
            encoded = new bytes(len+1);

            // length encoding byte
            encoded[0] = byte(uint8(prefix1+len));

            // string/list contents
            assembly { encodedPtr := add(encoded, 0x21) }
            memcpy(encodedPtr, selfPtr, len);
        } else {
            // 1 is the length of the length of the length
            encoded = new bytes(1+lenLen+len);

            // length of the length encoding byte
            encoded[0] = byte(uint8(prefix2+lenLen));

            // length bytes
            for(i=1; i<=lenLen; i++) {
                encoded[i] = byte(uint8((len/(0x100**(lenLen-i)))%0x100));
            }

            // string/list contents
            assembly { encodedPtr := add(add(encoded, 0x21), lenLen) }
            memcpy(encodedPtr, selfPtr, len);
        }
        return encoded;
    }

    function flatten(bytes[] memory self) private  returns (bytes memory) {
        if(self.length == 0) {
            return new bytes(0);
        }

        uint len;
        for(uint i=0; i<self.length; i++) {
            len += self[i].length;
        }

        bytes memory flattened = new bytes(len);
        uint flattenedPtr;
        assembly { flattenedPtr := add(flattened, 0x20) }

        for(uint i=0; i<self.length; i++) {
            bytes memory item = self[i];

            uint selfPtr;
            assembly { selfPtr := add(item, 0x20)}

            memcpy(flattenedPtr, selfPtr, item.length);
            flattenedPtr += self[i].length;
        }

        return flattened;
    }

    /// This function is from Nick Johnson's string utils library
    function memcpy(uint dest, uint src, uint len) private {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    function strToBytes(string memory data)internal pure returns (bytes memory){
        uint _ascii_0 = 48;
        uint _ascii_A = 65;
        uint _ascii_a = 97;

        bytes memory a = bytes(data);
        uint[] memory b = new uint[](a.length);

        for (uint i = 0; i < a.length; i++) {
            uint _a = uint8(a[i]);

            if (_a > 96) {
                b[i] = _a - 97 + 10;
            }
            else if (_a > 66) {
                b[i] = _a - 65 + 10;
            }
            else {
                b[i] = _a - 48;
            }
        }

        bytes memory c = new bytes(b.length / 2);
        for (uint _i = 0; _i < b.length; _i += 2) {
            c[_i / 2] = byte(uint8(b[_i] * 16 + b[_i + 1]));
        }

        return c;
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint8(b[i])*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

    function addressToBytes(address a) internal pure returns (bytes memory b){
        assembly {
            let m := mload(0x40)
            mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, a))
            mstore(0x40, add(m, 52))
            b := m
        }
    }

    function stringToUint(string memory s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) {
           if (uint8(b[i]) >= 48 && uint8(b[i]) <= 57){
                result = result * 16 + (uint8(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
            else if(uint8(b[i]) >= 97 && uint8(b[i]) <= 122)
            {
                result = result * 16 + (uint8(b[i]) - 87);
            }
        }
        return result;
    }

    function subString(string memory str, uint startIndex, uint endIndex) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ab = new string(_ba.length + _bb.length);
        bytes memory bab = bytes(ab);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) bab[k++] = _ba[i];
            for (uint i = 0; i < _bb.length; i++) bab[k++] = _bb[i];
                return string(bab);
        }

    function stringToAddr(string memory _input) internal pure returns (address){
        string memory _a = strConcat("0x",_input);
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint8(tmp[i]);
            b2 = uint8(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
            return address(iaddr);
    }

    function addressToString(address _addr) internal pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(40);

        for (uint i = 0; i < 20; i++) {
            str[i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[1+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
    function toHexDigit(uint8 d) pure internal returns (byte) {                                                                                      
        if (0 <= d && d <= 9) {                                                                                                                      
            return byte(uint8(byte('0')) + d);                                                                                                       
        } else if (10 <= uint8(d) && uint8(d) <= 15) {                                                                                               
            return byte(uint8(byte('a')) + d - 10);                                                                                                  
        }                                                                                                                                            
    }   
    
    function fromCode(bytes4 code) public pure returns (string memory) {                                                                                    
        bytes memory result = new bytes(8);                                                                                                         
        //result[0] = byte('0');
        //result[1] = byte('x');
        for (uint i=0; i<4; ++i) {
            result[2*i+0] = toHexDigit(uint8(code[i])/16);
            result[2*i+1] = toHexDigit(uint8(code[i])%16);
        }
        return string(result);
    }
    
    
    function getMsgHash(address _destination, string memory _value, string memory _strTransactionData)  internal returns (bytes32){

        bytes[] memory rawTx = new bytes[](9);
        bytes[] memory bytesArray = new bytes[](9);

        rawTx[0] = hex"09";
        rawTx[1] = hex"09502f9000";
        rawTx[2] = hex"5208";
        rawTx[3] = addressToBytes(_destination);
        rawTx[4] = strToBytes(_value);
        rawTx[5] = strToBytes(_strTransactionData);
        rawTx[6] = hex"01"; //03=testnet,01=mainnet

        for(uint8 i = 0; i < 9; i++){
            bytesArray[i] = encodeBytes(rawTx[i]);
        }

        bytes memory bytesList = encodeList(bytesArray);

        return keccak256(bytesList);
    }
}

/**
 * @title IVTPermission
 * @dev Contract for Permission applications.
 */
contract IVTPermission is RLPEncode {

    /// @dev  (==)
    mapping (address => bool) public signers;
    /// @dev  ==
    mapping (uint256 => bool) public transactions;
    /// @dev  
    uint8 public required;

/// @dev  Emitted by successful `upgrade` calls.
    event Completed(
        bytes4 _callbackSelector,
        address _newAddress,
        address _sender
    );

    constructor(address[] memory _signers, uint8 _required) public {
        require(_required <= _signers.length && _required > 0 && _signers.length > 0);

        for (uint8 i = 0; i < _signers.length; i++){
            require(_signers[i] != address(0));
            signers[_signers[i]] = true;
        }
        required = _required;
    }

/**
 * @dev    
 * @param  _callbackSelector 
 * @param  _newAddress 
 * @param  _strTransactionData v4 [proxy]+[]
 * @param  _v v[27,28,28]
 * @param  _r r["","",""]
 * @param  _s s["","",""]
 * @return 
 */
    function confirmChange(bytes4 _callbackSelector, address _newAddress, string memory _strTransactionData, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s) public {
        processAndCheckParam(_newAddress, _strTransactionData, _v, _r, _s);
        _strTransactionData = RLPEncode.strConcat(_strTransactionData, RLPEncode.fromCode(_callbackSelector));
        //value 03e8
        bytes32 _msgHash = getMsgHash(_newAddress, "03e8", _strTransactionData);
        
        verifySignatures(_msgHash, _v, _r, _s);

        msg.sender.call(abi.encodeWithSelector(_callbackSelector, _newAddress));
        emit Completed(_callbackSelector, _newAddress, msg.sender);
    }


/**
 * @dev    
 * @param  _destination 
 * @param  _strTransactionData v4 [proxy]+[]
 * @param  _v 
 * @param  _r 
 * @param  _s 
 * @return 
 */
    function processAndCheckParam(address _destination, string memory _strTransactionData, uint8[] memory _v, bytes32[] memory _r, bytes32[] memory _s)  internal {
        require(_destination != address(0)  && _v.length == _r.length && _v.length == _s.length && _v.length > 0);

        string memory strTransactionTime = RLPEncode.subString(_strTransactionData, 40, 48);
        uint256 transactionTime = RLPEncode.stringToUint(strTransactionTime);
        require(!transactions[transactionTime]);

        string memory strTransactionAddress = RLPEncode.subString(_strTransactionData, 0, 40);
        address contractAddress = RLPEncode.stringToAddr(strTransactionAddress);
        // == proxy
        require(contractAddress == address(msg.sender));

        transactions[transactionTime] = true;
    }


/**
 * @dev   
 * @param _msgHash Hash
 * @param  _v  
 * @param  _r  
 * @param  _s  
 * @return 
 */
    function verifySignatures(bytes32 _msgHash, uint8[] memory _v, bytes32[] memory _r,bytes32[] memory _s) view internal {
        uint8 hasConfirmed = 0;
        address[] memory  tempAddresses = new address[](_v.length);

        for (uint8 i = 0; i < _v.length; i++){
            tempAddresses[i]  = ecrecover(_msgHash, _v[i], _r[i], _s[i]);
       
            require(signers[tempAddresses[i]]);
            hasConfirmed++;
        }

        for (uint8 m = 0; m < _v.length; m++){
            for (uint8 n = m + 1; n< _v.length; n++){
                require(tempAddresses[m] != tempAddresses[n]);
            }
        }

        require(hasConfirmed >= required);
    }

}