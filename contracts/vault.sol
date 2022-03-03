// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol';
import "./Uniswap.sol";

// interface IUniswapV2Router01 {
//         function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);
//     }


contract Vault {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public depositsCount;

    // make a data structure to store the token allocation on lp pools

    struct Items {
        IERC20 token1;
        IERC20 token2;
        address withdrawer;
        uint256 amount1;
        uint256 amount2;
    }
   
    mapping (uint256 => Items) public lockedToken;
    

    // on polygon
    address constant factory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address constant router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address constant token1 = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; //WETH
    address constant token2 = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174; //USDC
    // address constant pair_address = address(uint(keccak256(abi.encodePacked(
    //     hex'ff',
    //     factory,
    //     keccak256(abi.encodePacked(token1, token2)),
    //     hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'
    // ))));

    
    function approve(IERC20 _token1, IERC20 _token2, address spender, uint256 _amount1, uint256 _amount2) external returns (bool) {
        _token1.safeApprove(spender,_amount1);
        _token2.safeApprove(spender,_amount2);
    }

    function lockTokens(IERC20 _token1, IERC20 _token2, address _withdrawer, uint256 _amount1, uint256 _amount2) external returns (uint256 _id) {
        require(IERC20(_token1).allowance(msg.sender, address(this)) >= _amount1, 'Approve tokens first!');
        require(IERC20(_token2).allowance(msg.sender, address(this)) >= _amount2, 'Approve tokens first!');
        IERC20(_token1).safeTransferFrom(msg.sender, address(this), _amount1);
        IERC20(_token2).safeTransferFrom(msg.sender, address(this), _amount2);

        _id = ++depositsCount;
        lockedToken[_id].token1 = _token1;
        lockedToken[_id].token2 = _token2;
        lockedToken[_id].withdrawer = _withdrawer;
        lockedToken[_id].amount1 = _amount1;
        lockedToken[_id].amount2 = _amount2;
        
    }


    // function addLiquidity(
    //     address tokenA,     
    //     address tokenB,
    //     uint amountADesired,
    //     uint amountBDesired,
    //     uint amountAMin,
    //     uint amountBMin,
    //     address to,
    //     uint deadline
    // ) external returns (uint amountA, uint amountB, uint liquidity);

    
    
    function allocateToPool(uint256 _id) external returns (bool) {
        (uint amount1, uint amount2, uint liquidity) =
      IUniswapV2Router(router).addLiquidity(
        token1,
        token2,
        amount1,
        amount2,
        1,
        1,
        address(this),
        block.timestamp
      );
    }

}
