pragma solidity ^0.4.24;

import "./EthBondingCurvedToken.sol";
import "./Power.sol";

/// @title  EthPolynomialCurvedToken - A polynomial bonding curve
///         implementation that is backed by ether.
contract EthPolynomialCurvedToken is EthBondingCurvedToken, Power {

  uint256 public baseN;
  uint256 public baseD;
  uint32 public expN;
  uint32 public expD;

    /// @dev constructor        Initializes the bonding curve
    /// @param _name            The name of the token
    /// @param _decimals        The number of decimals to use
    /// @param _symbol          The symbol of the token
    /// @param _baseN           The base numerator of the curve
    /// @param _baseD           The base denominator of the curve
    /// @param _expN            The exponent numerator of the curve
    /// @param _expN            The exponent denominator of the curve
    constructor(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _baseN,
        uint256 _baseD,
        uint32 _expN,
        uint32 _expD
    ) EthBondingCurvedToken(_name, _symbol, _decimals) public {
        baseN = _baseN;
        baseD = _baseD;
        expN = _expN;
        expD = _expD;
    }

    /// @dev        Calculate the integral from 0 to t
    /// @param x    The number to integrate to
    function curveIntegral(uint256 x) internal returns (uint256) {
        uint32 nExpN = expN + expD;
        uint256 result;
        uint8 precision;

        // Calculate integral of t^exponent
        (result, precision) = power(x.mul(expD), baseD.mul(nExpN), nExpN, expD);
        return result >> precision;
    }

    function priceToMint(uint256 numTokens) public returns(uint256) {
        return curveIntegral(totalSupply_.add(numTokens)).sub(poolBalance);
    }

    function rewardForBurn(uint256 numTokens) public returns(uint256) {
        // Special case for selling entire supply,
        // since Bancor power formula is an approximation
        if (numTokens == totalSupply_) {
          return poolBalance;
        }

        return poolBalance.sub(curveIntegral(totalSupply_.sub(numTokens)));
    }
}
