//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Ownable.sol";
import "hardhat/console.sol";
// interface Aion
/*interface Aion {
  uint256 serviceFee;
  function ScheduleCall(uint256 blocknumber, address to, uint256 value, uint256 gaslimit, uint256 gasprice, bytes memory data, bool schedType) payable external returns (uint,address);
}*/


//ver bien si necesitamos heredar de Context
contract CryptoChip is IERC20, IERC20Metadata, Ownable{
  mapping(address => uint256) private _chipCount;

  uint256 private _totalSupply;

  string private _name;
  string private _symbol;
  address private _casinoAddress;
  //Aion aion;

  constructor(string memory name_, string memory symbol_, uint256 initialSupply_, address casinoAddress_) {
    _name = name_;
    _symbol = symbol_;
    _totalSupply = initialSupply_;
    _casinoAddress = casinoAddress_;
    _chipCount[_casinoAddress] = _totalSupply;
    //scheduleDailyMint();
  }

 /* function scheduleDailyMint() internal {
    aion = Aion(0xFcFB45679539667f7ed55FA59A15c8Cad73d9a4E); //ropsten address - verify if works 
    bytes memory data = abi.encodeWithSelector(bytes4(keccak256('dailyMint()')));
    uint callCost = 200000*1e9 + aion.serviceFee();
    aion.ScheduleCall{value:callCost}( block.timestamp + 1 days, address(this), 0, 200000, 1e9, data, true);
  }

  function dailyMint() internal {
    _mint(_casinoAddress, 100);
    scheduleDailyMint();
  }
*/
  function setCasinoAddress(address casinoAdress) public onlyOwner{
    _casinoAddress = casinoAdress;
  }

  function name() public view virtual override returns (string memory) {
    return _name;
  }

  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }

  function decimals() public view virtual override returns (uint8) {
    return 0;
  }

  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) public view virtual override returns (uint256) {
    return _chipCount[account];
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) public view virtual override returns (uint256) {
    return spender == _casinoAddress ? _chipCount[owner] : 0;
  }

  
  function approve(address, uint256) public virtual override returns (bool) {
    return false;
  }

  /**
    * @dev See {IERC20-transferFrom}.
    *
    * Emits an {Approval} event indicating the updated allowance. This is not
    * required by the EIP. See the note at the beginning of {ERC20}.
    *
    * Requirements:
    *
    * - `sender` and `recipient` cannot be the zero address.
    * - `sender` must have a balance of at least `amount`.
    * - the caller must have allowance for ``sender``'s tokens of at least
    * `amount`.
    */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) public virtual override returns (bool) {
    require(recipient == _casinoAddress, "ERC20: you are not the casino");
    _transfer(sender, recipient, amount);
    return true;
  }

  /**
    * @dev Atomically increases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    */
  function increaseAllowance(address, uint256) public virtual returns (bool) {
    return false;
  }

  /**
    * @dev Atomically decreases the allowance granted to `spender` by the caller.
    *
    * This is an alternative to {approve} that can be used as a mitigation for
    * problems described in {IERC20-approve}.
    *
    * Emits an {Approval} event indicating the updated allowance.
    *
    * Requirements:
    *
    * - `spender` cannot be the zero address.
    * - `spender` must have allowance for the caller of at least
    * `subtractedValue`.
    */
  function decreaseAllowance(address, uint256) public virtual returns (bool) {
    return false;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");


    uint256 senderBalance = _chipCount[sender];
    console.log(senderBalance, amount);
    require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        _chipCount[sender] = senderBalance - amount;
    }
    _chipCount[recipient] += amount;

    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    * the total supply.
    *
    * Emits a {Transfer} event with `from` set to the zero address.
    *
    * Requirements:
    *
    * - `account` cannot be the zero address.
    */
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");
    _totalSupply += amount;
    _chipCount[account] += amount;
    emit Transfer(address(0), account, amount);
  }

  /**
    * @dev Destroys `amount` tokens from `account`, reducing the
    * total supply.
    *
    * Emits a {Transfer} event with `to` set to the zero address.
    *
    * Requirements:
    *
    * - `account` cannot be the zero address.
    * - `account` must have at least `amount` tokens.
    */
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");

    uint256 accountBalance = _chipCount[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
        _chipCount[account] = accountBalance - amount;
    }
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);
  }

}
