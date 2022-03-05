// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Uniswap.sol";

contract Vault {

    using SafeERC20 for IERC20;
    // data structure to store token allocation on LP pools
    mapping (address => mapping(address => uint256)) public tokenAllocated; // user address -> token address -> amount
    event Log(string message, uint indexed amountA, uint indexed amountB, uint indexed LP);    

    // on polygon quickswap
    address constant factory = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;
    address constant router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address constant token1 = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; //WETH
    address constant token2 = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC

    //lock tokens to this vault contract     
    function lockTokens( uint256 _amount1, uint256 _amount2) public {
        IERC20(token1).safeTransferFrom(msg.sender, address(this), _amount1);
        IERC20(token2).safeTransferFrom(msg.sender, address(this), _amount2);
        tokenAllocated[msg.sender][token1] = _amount1;      
        tokenAllocated[msg.sender][token2] = _amount2;            
    }
  
    function allocateToPool() public {
      //approving the Quickswap router
      IERC20(token1).approve(router, tokenAllocated[msg.sender][token1]);
      IERC20(token2).approve(router, tokenAllocated[msg.sender][token2]);

      //adding liquidity to the WETH/USDC pool on polygon
        (uint amountA, uint amountB, uint liquidity) =
      IUniswapV2Router(router).addLiquidity(
        token1,
        token2,
        tokenAllocated[msg.sender][token1],
        tokenAllocated[msg.sender][token2],        
        1,
        1,
        address(this),
        block.timestamp
      );

      emit Log("amountA; amountB; Liquidity;", amountA, amountB, liquidity);
      
    }
}
