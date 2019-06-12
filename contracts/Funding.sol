// contracts/Funding.sol
pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Funding is Ownable {
  using SafeMath for uint;

  uint public raised;
  uint public goal;
  uint public finishesAt;
  mapping(address => uint) public balances;

/*
Modifiers are used as an extention of a function.
Modifier code is ran before the function code
 `_;` continues to execution of the function
Results in less duplicated code for common conditions
*/
  modifier onlyNotFinished() {
    require(!isFinished());
    _;
  }

  modifier onlyFinished() {
    require(isFinished());
    _;
  }

  modifier onlyNotFunded() {
    require(!isFunded());
    _;
  }

  modifier onlyFunded() {
    require(isFunded());
    _;
  }
/*
This unnammed function is a fallback function
It recieves ether in case ether is sent to this contract without a function call
I am removing it because it creates a sink with no way to get the ether out.
*/
  // function () public payable {}

  constructor(uint _duration, uint _goal) public {
    finishesAt = now + _duration;
    goal = _goal;
  }

  function isFinished() public view returns (bool) {
    return finishesAt <= now;
  }

  function isFunded() public view returns (bool) {
    return raised >= goal;
  }

  function donate() public onlyNotFinished payable {
    balances[msg.sender] = balances[msg.sender].add(msg.value);
    raised = raised.add(msg.value);
  }

  function withdraw() public onlyOwner onlyFunded {
    owner.transfer(address(this).balance);
  }

  function refund() public onlyFinished onlyNotFunded {
    uint amount = balances[msg.sender];
    require(amount > 0);
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
  }
}
