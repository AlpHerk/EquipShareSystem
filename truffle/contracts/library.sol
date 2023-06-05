// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18; 

library LibArray {
 
    function removeByValue(uint[] storage array, uint value) public {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == value) {
                for (uint j = i; j < array.length-1; j++) {
                    array[j] = array[j+1];
                }
                array.pop();
            }
        } 
    }
    
}

