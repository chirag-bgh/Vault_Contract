// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

library Balances {
    function move(mapping(address => uint256) storage balances, address from, address to, uint amount) internal {
        require(balances[from] >= amount);
        require(balances[to] + amount >= balances[to]);
        balances[from] -= amount;
        balances[to] += amount;
    }
}

contract Pool {
    mapping(address => uint256) balances;
    using Balances for *;
    mapping(address => mapping (address => uint256)) allowed;

    //UniswapV2
    address private USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;
    address private ETH = 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2;
    address private pair_add = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;
    

    event Transfer(address from, address to, uint amount);
    event Approval(address owner, address spender, uint amount);
    

    //approval to this contract to spend on behalf of caller
    function approve(address spender, uint tokens) external returns (bool success) {
        
        require(allowed[msg.sender][spender] == 0, "");
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    //transfer to Vault contract
    function transfer(address to, uint amount) external returns (bool success) {
        
        balances.move(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    //tranfer to pool
    function transferFrom(address from, address to, uint amount) external returns (bool success) {
        
        require(allowed[from][msg.sender] >= amount);
        allowed[from][msg.sender] -= amount;
        balances.move(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }    
}
}