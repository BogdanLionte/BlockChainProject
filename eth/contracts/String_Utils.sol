pragma solidity >=0.7.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract String_Utils {

    function compare_strings(string memory a, string memory b) public pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    function splitString(string memory stringToSplit) public pure returns(string[] memory) {

        uint256 wordCounter = 0;

        bytes memory stringAsBytesArray = bytes(stringToSplit);

        for(uint index = 0; index < stringAsBytesArray.length; index++) {
            if(stringAsBytesArray[index] == "&") {
                wordCounter++;
            }
        }


        string[] memory finalWordsArray = new string[](wordCounter + 1);
        wordCounter = 0;

        uint i = 0;
        uint j = 0;

        while(i < stringAsBytesArray.length && j < stringAsBytesArray.length) {
            if(stringAsBytesArray[j] != "&") {
                j++;
            }
            else {
                bytes memory tmpWord = new bytes(j - i);
                for(uint k = i; k < j; k++) {
                    tmpWord[k - i] = stringAsBytesArray[k];
                }
                finalWordsArray[wordCounter] = string(tmpWord);
                wordCounter ++;
                i = j + 1;
                j ++;
            }
        }
        if(i < stringAsBytesArray.length) {
            bytes memory tmpWord = new bytes(stringAsBytesArray.length - i);
            for(uint k = i; k < stringAsBytesArray.length; k++) {
                tmpWord[k - i] = stringAsBytesArray[k];
            }
            finalWordsArray[wordCounter] = string(tmpWord);
            wordCounter++;
        }

        return finalWordsArray;
    }

    function arr2str(string[] memory arr) public pure returns (string memory){
        if(arr.length == 0) {
            return "[]";
        }
        string memory json = "[\"";
        for(uint i = 0; i < arr.length - 1; i++) {
            json = concatenate(json, arr[i]);
            json = concatenate(json, "\", \"");
        }
        json = concatenate(json, arr[arr.length - 1]);
        json = concatenate(json, "\"]");
        return json;
    }

    function concatenate(string memory a, string memory b) public pure returns (string memory) {

        return string(abi.encodePacked(a, b));
    }

    function uint2str(uint _i) public pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}